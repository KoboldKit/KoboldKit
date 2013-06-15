//
//
// Created by Steffen Itterheim on 15.06.13.
//
//

#import "KoboldKit.h"

@implementation KoboldKit

+(NSString*) pathForBundleFile:(NSString*)file
{
	NSString* filename = [file stringByDeletingPathExtension];
	NSString* extension = [file pathExtension];
	return [[NSBundle mainBundle] pathForResource:filename ofType:extension];
}

+(NSString*) pathForAppSupportFile:(NSString*)file
{
	return [KoboldKit pathForFile:file inDirectory:NSApplicationSupportDirectory];
}

+(NSString*) pathForDocumentsFile:(NSString*)file
{
	return [KoboldKit pathForFile:file inDirectory:NSDocumentDirectory];
}

+(NSString*) pathForLibraryFile:(NSString*)file
{
	return [KoboldKit pathForFile:file inDirectory:NSLibraryDirectory];
}

+(NSString*) pathForFile:(NSString*)file inDirectory:(NSSearchPathDirectory)directory
{
	NSString* path = [NSSearchPathForDirectoriesInDomains(directory, NSUserDomainMask, YES) lastObject];
	return [path stringByAppendingPathComponent:file];
}

+(NSString*) searchPathsForFile:(NSString*)file
{
	NSFileManager* fileManager = [NSFileManager defaultManager];

	NSString* path = [KoboldKit pathForAppSupportFile:file];
	if ([fileManager fileExistsAtPath:path] == NO)
	{
		path = [KoboldKit pathForDocumentsFile:file];
		if ([fileManager fileExistsAtPath:path] == NO)
		{
			path = [KoboldKit pathForBundleFile:file];
		}
	}
	return path;
}

@end