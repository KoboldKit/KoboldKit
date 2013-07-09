//
//  NSDictionary+KoboldKit.h
//  KoboldKit
//
//  Created by Steffen Itterheim on 05.07.13.
//  Copyright (c) 2013 Steffen Itterheim. All rights reserved.
//

#import <Foundation/Foundation.h>

/** nd */
@interface NSDictionary (KoboldKit)

/** Runs the given Lua script file and transforms the returned Lua table into a KVC coded NSDictionary. 
 Navigate the table with valueForKeyPath:
 
 @param scriptFile The name of a Lua script file.
 @returns The Lua table as a dictionary, or nil if there are any errors. */
+(NSDictionary*) dictionaryWithContentsOfLuaScript:(NSString*)scriptFile;

@end
