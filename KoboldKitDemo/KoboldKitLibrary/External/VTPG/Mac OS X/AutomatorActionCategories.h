// Created by Vincent Gable on 1/13/09.
// Copyright 2009 Vincent Gable. All rights reserved.
//

@interface NSDictionary (AutomatorErrors)
+(NSDictionary*) errorInfoWithMessage:(NSString*)msg errorNumber:(int)err;
+(NSDictionary*) errorInfoWithMessage:(NSString*)msg;
@end
