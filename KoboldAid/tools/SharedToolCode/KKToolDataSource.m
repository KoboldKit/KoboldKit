//
//  KKToolDataSources.m
//  KKNewProject
//
//  Created by Steffen Itterheim on 27.08.13.
//  Copyright (c) 2013 Steffen Itterheim. All rights reserved.
//

#import "KKToolDataSource.h"

@implementation KKToolDataSource

-(id) init
{
	self = [super init];
	if (self)
	{
		_array = [NSMutableArray arrayWithCapacity:4];
		_dictionary = [NSMutableDictionary dictionaryWithCapacity:4];
	}
	return self;
}

-(void) setObject:(id)object forKey:(NSString*)key
{
	NSAssert1([_dictionary objectForKey:key] == nil, @"object for key '%@' already exists!", key);
	
	[_array addObject:key];
	[_dictionary setObject:object forKey:key];
}

@end


@implementation KKXcodeProjectsTableViewDataSource

-(NSInteger) numberOfRowsInTableView:(NSTableView*)aTableView
{
	return self.array.count;
}

-(id) tableView:(NSTableView*)tableView objectValueForTableColumn:(NSTableColumn*)tableColumn row:(NSInteger)row
{
	return [self.array objectAtIndex:row];
}

@end
