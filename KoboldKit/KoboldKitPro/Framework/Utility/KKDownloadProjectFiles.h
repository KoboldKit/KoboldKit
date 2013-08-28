/*
 * Copyright (c) 2013 Steffen Itterheim.
 * Released under a PROPRIETARY License:
 * KoboldKit/KoboldKitPro/KoboldKitPro.License.txt
 */

#import <Foundation/Foundation.h>

/** The completion block called after all files have been downloaded. */
typedef void (^KKDownloadProjectFilesCompletionBlock)(NSDictionary* contents);

@class KKModel;

/** Class that handles downloading of a project's resource files to the app's documents directory.
 This enables updating of resource files at runtime to avoid having to recompile and relaunch the app
 for every resource file change. */
@interface KKDownloadProjectFiles : NSObject
{
	KKDownloadProjectFilesCompletionBlock _completionBlock;
}

/** Downloads all project resources files from the url.
 @param url The url where to download the resource files from. The URL is typically set in the devconfig.lua file.
 @param completionBlock The completion block to run after all files have been downloaded. */
+(id) downloadProjectFilesWithURL:(NSURL*)url completionBlock:(KKDownloadProjectFilesCompletionBlock)completionBlock;
/** Downloads all project resources files from the url.
 @param url The url where to download the resource files from. The URL is typically set in the devconfig.lua file.
 @param completionBlock The completion block to run after all files have been downloaded. */
-(id) initWithURL:(NSURL*)url completionBlock:(KKDownloadProjectFilesCompletionBlock)completionBlock;

@end
