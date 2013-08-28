//
//  KKCopyFilesFilter.h
//  KKNewProject
//
//  Created by Steffen Itterheim on 28.08.13.
//  Copyright (c) 2013 Steffen Itterheim. All rights reserved.
//

#import <Foundation/Foundation.h>

/** Case insensitive copy filter. Use as delegate for NSFileManager. */
@interface KKCopyFilesFilter : NSObject<NSFileManagerDelegate>
{
	NSFileManager* _fileManager;
}

@property NSArray* fileHasPrefixFilter;
@property NSArray* fileHasSuffixFilter;
@property NSArray* fileIsEqualFilter;
@property NSArray* fileContainsStringFilter;

@property NSArray* directoryHasPrefixFilter;
@property NSArray* directoryHasSuffixFilter;
@property NSArray* directoryIsEqualFilter;
@property NSArray* directoryContainsStringFilter;

@property BOOL logFilteredItems;

@end
