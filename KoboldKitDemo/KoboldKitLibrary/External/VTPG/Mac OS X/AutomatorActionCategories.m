// Created by Vincent Gable on 1/13/09.
// Copyright 2009 Vincent Gable. All rights reserved.
//

#import "AutomatorActionCategories.h"
#import <OSAKit/OSAKit.h> // OSAScriptErrorMessage

@implementation NSDictionary (AutomatorErrors)
+(NSDictionary*) errorInfoWithMessage:(NSString*)msg errorNumber:(int)err;
{
	return [self dictionaryWithObjectsAndKeys:msg, OSAScriptErrorMessage,
			[NSNumber numberWithInt:errOSASystemError], OSAScriptErrorNumber,
			nil];
}

+(NSDictionary*) errorInfoWithMessage:(NSString*)msg;
{
	return [self errorInfoWithMessage:msg errorNumber:errOSASystemError];
}
@end
