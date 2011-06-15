#import <UIKit/UIView.h>

#import <springboard_4.0/SBApplication.h>
@interface TPBottomLockBar : UIView 
-(void)_setLabel:(id)label;
-(void)launchApplication:(int)slideState; // Custom Function
-(void)launchApplicationWithBundle:(NSString *)bundleId; // Custom
@end

static BOOL DragStopped;
static BOOL allowUnlock;
NSString * settingsPath;
NSMutableDictionary * settingsDictionary;
static float dragAmount;
static int dragCount = 0;
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
	SBApplication *app = [[objc_getClass("SBApplicationController") sharedInstance] applicationWithDisplayIdentifier:bundleId];
    [[objc_getClass("SBUIController") sharedInstance] activateApplicationFromSwitcher:app];
}


%new(v@:c)
-(void)launchApplication:(int)slideState {

	settingsPath = @"/var/mobile/Library/Preferences/com.legendcoders.Multi-Slide.plist";
	settingsDictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:settingsPath];
	NSString *slideOne = [NSString alloc];
	NSString *slideTwo = [NSString alloc];
	NSString *slideThree = [NSString alloc];
	NSString *slideFour = [NSString alloc];
	NSString *slideFive = [NSString alloc];

	switch (slideState) {
		
		case 2:
		slideOne = [settingsDictionary objectForKey:@"SlideOne"];
		NSLog(@"Launching %@", slideOne);
		[self launchApplicationWithBundle:slideOne];

		break;
		
		case 3:
		slideTwo = [settingsDictionary objectForKey:@"SlideTwo"];
		NSLog(@"Launching %@", slideTwo);
		[self launchApplicationWithBundle:slideTwo];
		break;
		
		case 4:
		slideThree = [settingsDictionary objectForKey:@"SlideThree"];
		[self launchApplicationWithBundle:slideThree];
		NSLog(@"Launching %@", slideThree);
		break;
		
		case 5:
		slideFour = [settingsDictionary objectForKey:@"SlideFour"];
		NSLog(@"Launching %@", slideFour);
		[self launchApplicationWithBundle:slideFour];
		break;
		
		case 6:
		slideFive = [settingsDictionary objectForKey:@"SlideFive"];
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
	[settingsPath release];
	[settingsDictionary release];
	
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


