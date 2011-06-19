#import <SpringBoard/SpringBoard.h>

@interface TPLockKnobView : UIImageView
@end

@interface SBUIController (iOS40)
- (void)activateApplicationFromSwitcher:(SBApplication *)application;
@end

#define kSettingsPath @"/var/mobile/Library/Preferences/com.legendcoders.Multi-Slide.plist"

static BOOL allowUnlock;
static CGFloat dragAmount;
static NSInteger dragCount;
static BOOL shouldCenterLabel;
static SBApplication *pendingApplication;

%hook TPLockKnobView

- (id)initWithImage:(UIImage *)image
{
	if ((self = %orig)) {
		// Cache a flipped image so we don't have to do this expensive operation every time the lock bar hits an edge
		CALayer *layer = self.layer;
		[layer setValue:image forKey:@"unflippedImage"];
		CGRect rect;
		rect.size = image.size;
		UIGraphicsBeginImageContextWithOptions(rect.size, NO, image.scale);
		CGContextScaleCTM(UIGraphicsGetCurrentContext(), -1.0f, 1.0f);
		rect.origin.x = -rect.size.width;
		rect.origin.y = 0.0f;
		[image drawInRect:rect];
		[layer setValue:UIGraphicsGetImageFromCurrentImageContext() forKey:@"flippedImage"];
		UIGraphicsEndImageContext();
	}
	return self;
}

%end

%hook SBAwayLockBar
	
static SBApplication *ApplicationForSlideState(int slideState)
{
	NSString *keyToOpen = [NSString stringWithFormat:@"Slide%d", slideState];
	NSDictionary *settingsDictionary = [NSDictionary dictionaryWithContentsOfFile:kSettingsPath];
	NSString *displayIdentifier = [settingsDictionary objectForKey:keyToOpen];
	if (displayIdentifier)
		return [[%c(SBApplicationController) sharedInstance] applicationWithDisplayIdentifier:displayIdentifier];
	return nil;
}

static NSString *DisplayNameForSlideState(int slideState, NSString *defaultName) {
	SBApplication *app = ApplicationForSlideState(slideState);
	NSString *result = [app displayName];
	if (result)
		return result;
	return defaultName;
}

static void ApplyCachedImage(UIImageView *imageView, NSString *name)
{
	imageView.image = [imageView.layer valueForKey:name];
}

static void ResetDimTimer()
{
	SBAwayController *ac = [%c(SBAwayController) sharedAwayController];
	[ac restartDimTimer:10.0];
}

-(void)downInKnob {
	ResetDimTimer();
}

-(void)upInKnob {
	%orig;
	ResetDimTimer();

	switch (dragCount)
	{
		case 0:
			break;

		default:
			[pendingApplication release];
			pendingApplication = [ApplicationForSlideState(dragCount) retain];
			allowUnlock = YES;
			[self unlock];
			break;
	}
	
	dragCount = 0;
	UIImageView *knob = [self knob];
	ApplyCachedImage(knob, @"unflippedImage");
	knob.alpha = 1.0f;

	if (shouldCenterLabel) {
		shouldCenterLabel = NO;
		[self _adjustLabelOrigin];
	}
	[self _setLabel:@"slide to unlock"];
}

-(void)knobDragged:(float)dragged
{
	dragAmount = dragged;
	ResetDimTimer();
	if (dragCount & 1) {
		if (dragged <= 0.02f) {
			dragCount++;
			[UIView beginAnimations:nil context:NULL];
			UIImageView *knob = [self knob];
			ApplyCachedImage(knob, @"unflippedImage");
			[UIView setAnimationDuration:0.5];
			[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:knob cache:YES];
			[UIView commitAnimations];
			[self _setLabel:DisplayNameForSlideState(dragCount, @"unlock")];
		}
	} else {
		if (dragged >= 0.98f) {
			dragCount++;
			if (!shouldCenterLabel) {
				shouldCenterLabel = YES;
				[self _adjustLabelOrigin];
			}
			[UIView beginAnimations:nil context:NULL];
			UIImageView *knob = [self knob];
			ApplyCachedImage(knob, @"flippedImage");
			knob.alpha = 0.5f;
			[UIView setAnimationDuration:0.5];
			[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:knob cache:YES];
			[UIView commitAnimations];
			[self _setLabel:DisplayNameForSlideState(dragCount, @"unlock")];
		}
	}
}

-(void)unlock {
	if (allowUnlock) {
		%orig;
		allowUnlock = NO;
	}
}

-(void)_adjustLabelOrigin {
	if (shouldCenterLabel) {
		%orig;
		void *value = NULL;
		object_getInstanceVariable(self, "_labelView", &value);
		UIView *label = (UIView *)value;
		CGPoint center = label.center;
		center.x = label.superview.bounds.size.width * 0.5f;
		label.center = center;
	} else {
		%orig;
	}
}
	
%end

%hook SBAwayController

- (void)_finishedUnlockAttemptWithStatus:(NSInteger)status
{
	// Defer activating application until we get notice that the unlock succeeded
	%orig;
	if ((status == 1) && pendingApplication) {
		[[%c(SBUIController) sharedInstance] activateApplicationFromSwitcher:pendingApplication];
		[pendingApplication release];
		pendingApplication = nil;
	}
}

%end
