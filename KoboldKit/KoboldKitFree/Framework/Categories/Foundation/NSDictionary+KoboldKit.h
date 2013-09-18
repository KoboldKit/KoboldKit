/*
 * Copyright (c) 2011-2013 Steffen Itterheim.
 * Released under the MIT License:
 * KoboldAid/licenses/KoboldKitFree.License.txt
 */

#import <Foundation/Foundation.h>

/** Kobold Kit extensions */
@interface NSDictionary (KoboldKit)

/** Runs the given Lua script file and transforms the returned Lua table into a KVC coded NSDictionary. 
 Navigate the table with valueForKeyPath:
 
 @param scriptFile The name of a Lua script file.
 @returns The Lua table as a dictionary, or nil if there are any errors. */
+(NSDictionary*) dictionaryWithContentsOfLuaScript:(NSString*)scriptFile;

@end


/** Kobold Kit extensions */
@interface NSMutableDictionary (KoboldKit)

/** Runs the given Lua script file and transforms the returned Lua table into a KVC coded NSMutableDictionary.
 Navigate the table with valueForKeyPath:
 
 @param scriptFile The name of a Lua script file.
 @returns The Lua table as a dictionary, or nil if there are any errors. */
+(NSMutableDictionary*) dictionaryWithContentsOfLuaScript:(NSString*)scriptFile;

@end