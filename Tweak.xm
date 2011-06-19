#import <UIKit/UIView.h>

#import <SpringBoard/SpringBoard.h>
@interface TPBottomLockBar : UIView 
-(void)_setLabel:(id)label;
-(void)launchApplication:(int)slideState; // Custom Function
-(void)launchApplicationWithBundle:(NSString *)bundleId; // Custom
@end

@interface SBUIController (iOS40)
- (void)activateApplicationFromSwitcher:(SBApplication *)application;
@end

#define kSettingsPath @"/var/mobile/Library/Preferences/com.legendcoders.Multi-Slide.plist"

static BOOL DragStopped;
static BOOL allowUnlock;
static CGFloat dragAmount;
static NSInteger dragCount;

%hook SBAwayLockBar
	
-(void)downInKnob {
	if( dragCount == 1) { dragCount = 2; [self _setLabel:@"Slide Two"];  }	
	if(dragCount == 3) { dragCount = 4; [self _setLabel:@"Slide Four"];  }
	if(dragAmount == 1.0f && dragCount == 5) { dragCount = 6; [self _setLabel:@"Slide Five"]; }
}

-(void)upInKnob {
	%orig;
	DragStopped = YES;

	switch (dragCount)
	{
		case 1:
		NSLog(@"Unlocking Device....");
		allowUnlock = YES;
		[self unlock];
		break;
		
		case 2:
		case 3:
		case 4:
		case 5:
		case 6:
		[self launchApplication:dragCount];
		break;
	}
	
	dragCount = 0;
	NSLog(@"Drag Count now = 0");
	[self _setLabel:@"slide to unlock"];
}


%new(v@:c)
-(void)launchApplicationWithBundle:(NSString *)bundleId {
	SBApplication *app = [[%c(SBApplicationController) sharedInstance] applicationWithDisplayIdentifier:bundleId];
    [[%c(SBUIController) sharedInstance] activateApplicationFromSwitcher:app];
}


%new(v@:c)
-(void)launchApplication:(int)slideState {
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
	NSLog(@"Launching %@", displayIdentifier);
	[self launchApplicationWithBundle:displayIdentifier];
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
