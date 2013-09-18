//
//  KKToolHelper.m
//  KKNewProject
//
//  Created by Steffen Itterheim on 27.08.13.
//  Copyright (c) 2013 Steffen Itterheim. All rights reserved.
//

#import "KKToolHelper.h"

@implementation KKToolHelper

static NSString* pathToKoboldKit = nil;
+(NSString*) pathToKoboldKit
{
	if (pathToKoboldKit == nil)
	{
		NSString* workingDir = [[NSUserDefaults standardUserDefaults] stringForKey:@"workingDir"];
		if (workingDir)
		{
			NSLog(@"workingDir provided as command line argument");
			// step back to KoboldKit root folder when launching the app from Xcode
			for (int i = 0; i < 3; i++)
			{
				workingDir = [workingDir stringByDeletingLastPathComponent];
			}
		}
		else
		{
			NSLog(@"workingDir obtained from bundle path");
			workingDir = [[NSBundle mainBundle].bundlePath stringByDeletingLastPathComponent];
		}
		
		pathToKoboldKit = workingDir;
		NSLog(@"pathToKoboldKit is: %@", pathToKoboldKit);
	}

	return pathToKoboldKit;
}

+(void) alertWithError:(NSError*)error
{
	if (error)
	{
		NSLog(@"ERROR: %@", error);
		NSAlert* alert = [NSAlert alertWithError:error];
		[alert runModal];
	}
}

static NSString* appSupportDirectory = nil;
+(NSString*) appSupportDirectory
{
	if (appSupportDirectory == nil)
	{
		NSArray* paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
		NSString* appSupportPath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
		
		appSupportDirectory = [NSString stringWithFormat:@"%@/KoboldKitTools", appSupportPath];
		NSLog(@"app support directory: '%@'", appSupportDirectory);
		
		// make sure the directory exists and is writable
		NSFileManager* fileManager = [NSFileManager defaultManager];
		BOOL pathExists = [fileManager fileExistsAtPath:appSupportDirectory];
		
		if (pathExists == NO)
		{
			// create it
			NSError* error = nil;
			[fileManager createDirectoryAtPath:appSupportDirectory withIntermediateDirectories:YES attributes:nil error:&error];
			[KKToolHelper alertWithError:error];
		}
	}
	
	return appSupportDirectory;
}

@end
