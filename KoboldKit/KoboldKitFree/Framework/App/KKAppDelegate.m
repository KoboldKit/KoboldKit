/*
 * Copyright (c) 2013 Steffen Itterheim.
 * Released under the MIT License:
 * KoboldAid/licenses/KoboldKitFree.License.txt
 */


#import "KKAppDelegate.h"
#import <AVFoundation/AVFoundation.h>

@implementation KKAppDelegate

#if TARGET_OS_IPHONE
- (void)applicationWillResignActive:(UIApplication *)application
{
	// prevent audio crash
	[[AVAudioSession sharedInstance] setActive:NO error:nil];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
	// prevent audio crash
	[[AVAudioSession sharedInstance] setActive:NO error:nil];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
	[[AVAudioSession sharedInstance] setActive:YES error:nil];
}

#else // Mac OS X specific

-(void) applicationDidFinishLaunching:(NSNotification *)aNotification
{
	Class viewControllerClass = NSClassFromString(@"ViewController");
	NSAssert(viewControllerClass, @"No class named 'ViewController' exists in project. Your KKViewController subclass must be named 'ViewController' in Mac apps.");

	_viewController = [[viewControllerClass alloc] initWithNibName:nil bundle:nil];
	NSAssert([_viewController isKindOfClass:[KKViewController class]], @"'ViewController' class is not a subclass of KKViewController.");
	
	_viewController.view = self.kkView;
	[_viewController viewDidLoad];
	[_viewController presentFirstScene];
}

-(BOOL) applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
	return YES;
}

#endif

@end
