//
// Categories.h
// IMLocation
//
// Created by Vincent Gable on 5/28/07.
// Copyright 2007 Vincent Gable. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSAppleScript (VTPGCategories)
// executes the NSAppleScript, and returns the result as an NSString.
-(NSString*) executeWithStringResult;

////executes the NSAppleScript, and returns the result as an NSString, if an error occurs, it's description is put in error
-(NSString*) executeWithStringResultAndReturnError:(NSDictionary**)error;
@end
