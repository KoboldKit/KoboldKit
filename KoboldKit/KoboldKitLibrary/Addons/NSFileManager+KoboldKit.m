//
//  NSFileManager+KoboldKit.m
//  KoboldKit
//
//  Created by Steffen Itterheim on 04.07.13.
//  Copyright (c) 2013 Steffen Itterheim. All rights reserved.
//

#import "NSFileManager+KoboldKit.h"

static NSString* CFBundleName = nil;

@implementation NSFileManager (KoboldKit)

+(NSString*) pathForBundleFile:(NSString*)file
{
	NSString* filename = [file stringByDeletingPathExtension];
	NSString* extension = [file pathExtension];
	return [[NSBundle mainBundle] pathForResource:filename ofType:extension];
}

+(NSString*) pathForAppSupportFile:(NSString*)file
{
	return [NSFileManager pathForFile:file inDirectory:NSApplicationSupportDirectory];
}

+(NSString*) pathForDocumentsFile:(NSString*)file
{
	return [NSFileManager pathForFile:file inDirectory:NSDocumentDirectory];
}

+(NSString*) pathForLibraryFile:(NSString*)file
{
	return [NSFileManager pathForFile:file inDirectory:NSLibraryDirectory];
}

+(NSString*) pathForFile:(NSString*)file inDirectory:(NSSearchPathDirectory)directory
{
	NSString* path = [NSSearchPathForDirectoriesInDomains(directory, NSUserDomainMask, YES) lastObject];
	return [path stringByAppendingPathComponent:file];
}

+(NSString*) pathForFile:(NSString*)file
{
	NSFileManager* fileManager = [NSFileManager defaultManager];
	
	NSString* path = [NSFileManager pathForAppSupportFile:file];
	if ([fileManager fileExistsAtPath:path] == NO)
	{
		path = [NSFileManager pathForDocumentsFile:file];
		if ([fileManager fileExistsAtPath:path] == NO)
		{
			path = [NSFileManager pathForBundleFile:file];
		}
	}
	return path;
}

@end
