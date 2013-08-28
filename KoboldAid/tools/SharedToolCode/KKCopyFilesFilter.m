//
//  KKCopyFilesFilter.m
//  KKNewProject
//
//  Created by Steffen Itterheim on 28.08.13.
//  Copyright (c) 2013 Steffen Itterheim. All rights reserved.
//

#import "KKCopyFilesFilter.h"

@implementation KKCopyFilesFilter

-(id) init
{
	self = [super init];
	if (self)
	{
		_fileManager = [NSFileManager defaultManager];
	}
	return self;
}

-(void) logFilteredItem:(NSString*)item
{
	if (_logFilteredItems)
	{
		NSLog(@"Not copying: '%@'", item);
	}
}

-(BOOL) shouldCopyItem:(NSString*)item
		containsFilter:(NSArray*)containsFilter
		  prefixFilter:(NSArray*)prefixFilter
		  suffixFilter:(NSArray*)suffixFilter
		   equalFilter:(NSArray*)equalFilter
{
	NSString* lowercaseItem = item.lowercaseString;
	
	for (NSString* filter in containsFilter)
	{
		if ([lowercaseItem rangeOfString:filter.lowercaseString].location != NSNotFound)
		{
			[self logFilteredItem:item];
			return NO;
		}
	}
	
	for (NSString* filter in prefixFilter)
	{
		if ([lowercaseItem hasPrefix:filter.lowercaseString])
		{
			[self logFilteredItem:item];
			return NO;
		}
	}
	
	for (NSString* filter in suffixFilter)
	{
		if ([lowercaseItem hasSuffix:filter.lowercaseString])
		{
			[self logFilteredItem:item];
			return NO;
		}
	}
	
	for (NSString* filter in equalFilter)
	{
		if ([lowercaseItem isEqualToString:filter.lowercaseString])
		{
			[self logFilteredItem:item];
			return NO;
		}
	}
	
	return YES;
}

-(BOOL) fileManager:(NSFileManager*)fileManager shouldCopyItemAtURL:(NSURL*)srcURL toURL:(NSURL*)dstURL
{
	BOOL isDirectory;
	[_fileManager fileExistsAtPath:srcURL.path isDirectory:&isDirectory];
	
	if (isDirectory)
	{
		NSString* directory = srcURL.lastPathComponent;
		return [self shouldCopyItem:directory
					 containsFilter:_directoryContainsStringFilter
					   prefixFilter:_directoryHasPrefixFilter
					   suffixFilter:_directoryHasSuffixFilter
						equalFilter:_directoryIsEqualFilter];
	}
	else
	{
		NSString* file = srcURL.lastPathComponent;
		return [self shouldCopyItem:file
					 containsFilter:_fileContainsStringFilter
					   prefixFilter:_fileHasPrefixFilter
					   suffixFilter:_fileHasSuffixFilter
						equalFilter:_fileIsEqualFilter];
	}
	
	return YES;
}

@end
