//
// NilCategories.m
//
// Created by Vincent Gable on 2009-04-21
// Copyright 2009 Vincent Gable. All rights reserved.
//

#import "NilCategories.h"
#import "VTPG_Common.h"

@implementation NSString (NilCategories)
// builds a URL from the string
//
// +[NSURL URLWithString:] throws an exception for nil, but this is considered as designed.
-(NSURL*) convertToURL;
{
	return [NSURL URLWithString:self];
}

// +[NSURL URLWithString:relativeToURL:] throws an exception
-(NSURL*) convertToURLRelitiveToURL:(NSURL*)baseURL;
{
	if (!baseURL)
	{
		return nil;
	}
	return [NSURL URLWithString:self relativeToURL:baseURL];
}

@end

@implementation NSArray (NilCategories)
-(id) objectOrNilAtIndex:(NSUInteger)i;
{
	if (i >= [self count] || i < 0)
	{
		return nil;
	}
	return [self objectAtIndex:i];
}
@end

@implementation NSMutableDictionary (NilCategories)

-(void) setObjectToObjectForKey:(id)key inDictionary:(NSDictionary*)otherDictionary;
{
	id obj = [otherDictionary objectForKey:key];
	if (obj)
	{
		[self setObject:obj forKey:key];
	}
}


@end
