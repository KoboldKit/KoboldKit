/*
 * Copyright (c) 2013 Steffen Itterheim.
 * Released under the MIT License:
 * KoboldAid/licenses/KoboldKitFree.License.txt
 */

#import "AppDelegate.h"

@implementation AppDelegate

#if TARGET_OS_IPHONE
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	BOOL returnValue = [super application:application didFinishLaunchingWithOptions:launchOptions];
	
    // Override point for customization after application launch.
    return returnValue;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
	[super applicationWillResignActive:application];
	
	// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
	[super applicationDidEnterBackground:application];
	
	// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
	// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
	[super applicationWillEnterForeground:application];
	
	// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
	[super applicationDidBecomeActive:application];
	
	// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	[super applicationWillTerminate:application];
	
	// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#else // Mac OS X specific

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	[super applicationDidFinishLaunching:aNotification];

    // Override point for customization after application launch.
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
	// Return yes if application should quit if user closes the app's window.
    return YES;
}

#endif

@end
