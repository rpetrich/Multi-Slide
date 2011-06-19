#import <SpringBoard/SpringBoard.h>

@interface TPBottomLockBar : UIView 
-(void)_setLabel:(id)label;
@end

@interface SBUIController (iOS40)
- (void)activateApplicationFromSwitcher:(SBApplication *)application;
@end

#define kSettingsPath @"/var/mobile/Library/Preferences/com.legendcoders.Multi-Slide.plist"

static BOOL allowUnlock;
static CGFloat dragAmount;
static NSInteger dragCount;

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

static BOOL LaunchApplicationWithSlideState(int slideState) {
	SBApplication *app = ApplicationForSlideState(slideState);
	if (app) {
		[[%c(SBUIController) sharedInstance] activateApplicationFromSwitcher:app];
		return YES;
	}
	return NO;
}

static NSString *DisplayNameForSlideState(int slideState, NSString *defaultName) {
	SBApplication *app = ApplicationForSlideState(slideState);
	NSString *result = [app displayName];
	if (result)
		return result;
	return defaultName;
}

-(void)downInKnob {
	if (dragCount & 1) {
		dragCount++;
		[self _setLabel:DisplayNameForSlideState(dragCount, @"unlock")];
	}
}

-(void)upInKnob {
	%orig;

	switch (dragCount)
	{
		case 0:
			break;

		default:
			if (!LaunchApplicationWithSlideState(dragCount)) {
				allowUnlock = YES;
				[self unlock];
			}
			break;
	}
	
	dragCount = 0;
	[self _setLabel:@"slide to unlock"];
}


	

-(void)knobDragged:(float)dragged
{
	dragAmount = dragged;
	if (dragged == 1.0f) {
		if (!(dragCount & 1)) {
			dragCount++;
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
	
%end
