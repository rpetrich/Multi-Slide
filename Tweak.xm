#import <UIKit/UIView.h>

#import <SpringBoard/SpringBoard.h>
/*@interface TPBottomLockBar : UIView 
-(void)_setLabel:(id)label;
-(void)launchApplication:(int)slideState; // Custom Function
-(void)launchApplicationWithBundle:(NSString *)bundleId; // Custom
-(void)loadSettings;
@end*/

@interface SBUIController (iOS40)
- (void)activateApplicationFromSwitcher:(SBApplication *)application;
@end

/* Whole Bunch Of Shit */
static BOOL DragStopped;
static BOOL allowUnlock;
NSString * settingsPath;
NSMutableDictionary * settingsDictionary;
static float dragAmount;
static int dragCount = 0;
NSString *slideOne = [NSString alloc];
NSString *slideTwo = [NSString alloc];
NSString *slideThree = [NSString alloc];
NSString *slideFour = [NSString alloc];
NSString *slideFive = [NSString alloc];
/* End Shit */

@interface SBAwayLockBar (MultiSlide)
- (void)loadSettings;
- (void)launchApplication:(int)index;
- (void)launchApplicationWithBundle:(NSString *)bundleIdentifier;
@end

%hook SBAwayLockBar
	
-(void)downInKnob {
	if( dragCount == 1) { dragCount = 2; [self _setLabel:@"One"];  }	
	if(dragCount == 3) { dragCount = 4; [self _setLabel:@"Three"];  }
	if(dragCount == 5) { dragCount = 6; [self _setLabel:@"Slide Five"]; }
}

-(id)initWithFrame:(CGRect)frame knobImage:(id)image {
	[self loadSettings];
	NSLog(@"Unding Screen");
	return %orig;
	
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
		[self launchApplication:2];
		break;
		
		case 3:
		[self launchApplication:3];
		break;
		
		case 4:
		[self launchApplication:4];
		break;
		
		case 5:
		[self launchApplication:5];
		break;
		
		case 6:
		[self launchApplication:6];
		break;
		
		default:
		dragCount = 0;
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
-(void)loadSettings {
	settingsPath = @"/var/mobile/Library/Preferences/com.legendcoders.Multi-Slide.plist";
	settingsDictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:settingsPath];
	slideOne = [settingsDictionary objectForKey:@"SlideOne"];
	slideTwo = [settingsDictionary objectForKey:@"SlideTwo"];
	slideThree = [settingsDictionary objectForKey:@"SlideThree"];
	slideFour = [settingsDictionary objectForKey:@"SlideFour"];
	slideFive = [settingsDictionary objectForKey:@"SlideFive"];
	[settingsPath release];
	[settingsDictionary release];
	
}
%new(v@:c)
-(void)launchApplication:(int)slideState {


	switch (slideState) {
		
		case 2:
		
		NSLog(@"Launching %@", slideOne);
		[self launchApplicationWithBundle:slideOne];
		break;
		
		case 3:
		NSLog(@"Launching %@", slideTwo);
		[self launchApplicationWithBundle:slideTwo];
		break;
		
		case 4:
		[self launchApplicationWithBundle:slideThree];
		NSLog(@"Launching %@", slideThree);
		break;
		
		case 5:
		NSLog(@"Launching %@", slideFour);
		[self launchApplicationWithBundle:slideFour];
		break;
		
		case 6:
		[self launchApplicationWithBundle:slideFive];
		NSLog(@"Launching %@", slideFive);
		break;
	}
	
	/* Clean up */
	[slideOne release];
	[slideTwo release];
	[slideThree release];
	[slideFour release];
	[slideFive release];

	
}

	

-(void)knobDragged:(float)dragged
{
	dragAmount = dragged;
	if(dragAmount == 1.0f && dragCount == 0) { dragCount = 1;  [self _setLabel:@"Unlocking..."]; }	
	if(dragAmount == 1.0f && dragCount == 2) { dragCount = 3;  [self _setLabel:@"Two"]; }
	if(dragAmount == 1.0f && dragCount == 4) { dragCount = 5;  [self _setLabel:@"Four"]; }
}
	
-(void)unlock {
	if (allowUnlock) {
		%orig;
		allowUnlock = NO;
	}
}
	
%end
