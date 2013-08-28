/*
 * Copyright (c) 2013 Steffen Itterheim.
 * Released under the MIT License:
 * KoboldAid/licenses/KoboldKitFree.License.txt
 */


#import "NSBundle+KoboldKit.h"

static NSString* CFBundleName = nil;

@implementation NSBundle (KoboldKit)

+(NSString*) pathForBundleFile:(NSString*)file
{
	NSString* filename = [file stringByDeletingPathExtension];
	NSString* extension = [file pathExtension];
	return [[NSBundle mainBundle] pathForResource:filename ofType:extension];
}

/*
+(NSString*) pathForAppSupportFile:(NSString*)file
{
	return [NSFileManager pathForFile:file inDirectory:NSApplicationSupportDirectory];
}

+(NSString*) pathForLibraryFile:(NSString*)file
{
	return [NSFileManager pathForFile:file inDirectory:NSLibraryDirectory];
}
 */

+(NSString*) pathForDocumentsFile:(NSString*)file
{
	return [NSBundle pathForFile:file inDirectory:NSDocumentDirectory];
}

+(NSString*) pathForFile:(NSString*)file inDirectory:(NSSearchPathDirectory)directory
{
	NSString* path = [NSSearchPathForDirectoriesInDomains(directory, NSUserDomainMask, YES) lastObject];
#if !TARGET_OS_IPHONE
	path = [path stringByAppendingPathComponent:[NSBundle mainBundle].bundleIdentifier];
#endif
	return [path stringByAppendingPathComponent:file];
}

+(NSString*) pathToDocumentsDirectory
{
	return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

+(NSString*) pathForFile:(NSString*)file
{
	NSFileManager* fileManager = [NSFileManager defaultManager];
	NSString* path = nil;
	
	path = [NSBundle pathForDocumentsFile:file];
	if ([fileManager fileExistsAtPath:path] == NO)
	{
		path = [NSBundle pathForBundleFile:file];
	}

	return path;
}

@end
