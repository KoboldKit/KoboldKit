//
// Categories.m
// IMLocation
//
// Created by Vincent Gable on 5/28/07.
// Copyright 2007 Vincent Gable. All rights reserved.
//

#import "MacOSXCategories.h"
#import "VTPG_Common.h"

@implementation NSAppleScript (VTPGCategories)

-(NSString*) executeWithStringResultAndReturnError:(NSDictionary**)error
{
	return [[self executeAndReturnError:error] stringValue];
}

-(NSString*) executeWithStringResult
{
	NSDictionary* error = nil;
	NSString* result = [self executeWithStringResultAndReturnError:&error];
	if (error)
	{
		NSLog(@"*** executeWithStringResult had an error %@", error);
	}

	return result;
}

@end
