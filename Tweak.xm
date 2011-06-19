#import <UIKit/UIView.h>

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
	
static void LaunchApplicationWithDisplayIdentifier(NSString *displayIdentifier) {
	NSLog(@"Multi-Slide: Launching %@", displayIdentifier);
	SBApplication *app = [[%c(SBApplicationController) sharedInstance] applicationWithDisplayIdentifier:displayIdentifier];
    [[%c(SBUIController) sharedInstance] activateApplicationFromSwitcher:app];
}

static void LaunchApplicationWithSlideState(int slideState) {
	NSString *keyToOpen;
	switch (slideState) {
		case 2:
			keyToOpen = @"SlideOne";
			break;
		case 3:
			keyToOpen = @"SlideTwo";
			break;
		case 4:
			keyToOpen = @"SlideThree";
			break;
		case 5:
			keyToOpen = @"SlideFour";
			break;
		case 6:
			keyToOpen = @"SlideFive";
			break;
		default:
			return;
	}

	NSDictionary *settingsDictionary = [NSDictionary dictionaryWithContentsOfFile:kSettingsPath];
	NSString *displayIdentifier = [settingsDictionary objectForKey:keyToOpen];
	LaunchApplicationWithDisplayIdentifier(displayIdentifier);
}

-(void)downInKnob {
	switch (dragCount) {
		case 1:
			dragCount = 2;
			[self _setLabel:@"Slide Two"];
			break;
		case 3:
			dragCount = 4;
			[self _setLabel:@"Slide Four"];
			break;
		case 5:
			if (dragAmount == 1.0f) {
				dragCount = 6;
				[self _setLabel:@"Slide Five"];
			}
			break;
	}
}

-(void)upInKnob {
	%orig;

	switch (dragCount)
	{
		case 1:
			NSLog(@"Multi-Slide: Unlocking Device....");
			allowUnlock = YES;
			[self unlock];
			break;
		
		case 2:
		case 3:
		case 4:
		case 5:
		case 6:
			LaunchApplicationWithSlideState(dragCount);
			break;
	}
	
	dragCount = 0;
	NSLog(@"Drag Count now = 0");
	[self _setLabel:@"slide to unlock"];
}


	

-(void)knobDragged:(float)dragged
{
	dragAmount = dragged;
	if(dragAmount == 1.0f && dragCount == 0) { dragCount = 1;  [self _setLabel:@"Slide One"]; }	
	if(dragAmount == 1.0f && dragCount == 2) { dragCount = 3;  [self _setLabel:@"Slide Three"]; }
	if(dragAmount == 1.0f && dragCount == 4) { dragCount = 5;  [self _setLabel:@"Slide Five"]; }
}
	
-(void)unlock {
	if (allowUnlock) {
		%orig;
		allowUnlock = NO;
	}
}
	
%end
