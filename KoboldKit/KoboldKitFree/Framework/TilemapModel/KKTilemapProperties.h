/*
 * Copyright (c) 2012-2013 Steffen Itterheim.
 * Released under the MIT License:
 * KoboldAid/licenses/KoboldKitFree.License.txt
 */

#import "KKTypes.h"

@class KKMutableNumber;

/** KTTilemapProperties is a thin wrapper around NSMutableDictionary. It only allows NSString as keys and either KKMutableNumber or NSString as values (objects).
   Values can only be added and replaced but not removed. For weakly typed runtime variables use KTModel variables instead.

   It represents Tilemap properties. Properties are values (strings or numbers) indexed by name. The properties are editable in Tiled primarily
   by right-clicking (layer, tile, tileset, object, etc) with the exception of map (global) properties which can only be edited from the menu: Map -> Map Properties.

   Caution: for decimal numbers to be recognized you must use the dot as decimal separator (comma won't work). The reason for not making it locale-aware
   is that sharing TMX files between users with different system locales (ie US vs DE) would be difficult because it would require converting the TMX from one locale to the other. */
@interface KKTilemapProperties : NSObject

/** The properties as key-value dictionary. Keys are NSString objects, values are KKMutableNumber objects. */
@property (atomic, readonly) NSMutableDictionary* properties;

/** Returns the number of property items. */
@property (atomic, readonly) NSUInteger count;

/** Sets the number for the given key. If a value for the given key already exists the number will take its place.
   Caution: it is illegal to set a KKMutableNumber for an already existing key that stores a NSString.
 @param number The KKMutableNumber number to set.
 @param key The key uniquely identifying the number. */
-(void) setNumber:(KKMutableNumber*)number forKey:(NSString*)key;

/** Sets the string for the given key. If a value for the given key already exists the string will take its place.
   Caution: it is illegal to set a NSString for an already existing key that stores a KKMutableNumber.
 @param string The NSString to set.
  @param key The key uniquely identifying the number. */
-(void) setString:(NSString*)string forKey:(NSString*)key;

/** (KTTMXReader only) This method first determines if the string can be converted to KKMutableNumber and if so, will set the KKMutableNumber.
   Otherwise it will set the string.
 @param string The string to set. If the string can be converted to a number, a KKMutableNumber object will be created and set instead.
 @param key The key uniquely identifying the string or number. */
-(void) setValue:(NSString*)string forKey:(NSString*)key;

/** Returns a KKMutableNumber from a string if the string is convertable to a number. Otherwise returns nil.
   Note: floating point numbers must use . (dot) as floating point separator.
 @param string The string to convert to KKMutableNumber.
 @returns The converted number or nil if the string can't be converted to a number. */
-(KKMutableNumber*) numberFromString:(NSString*)string;

/** Returns the KKMutableNumber for the key. If there's no number for that key returns nil.
 @param key The key uniquely identifying the number.
 @returns The number for the key, or nil if there's no number with this key. */
-(KKMutableNumber*) numberForKey:(NSString*)key;

/** Returns the NSString for the key. If there's no string for that key returns nil.
 @param key The key uniquely identifying the string.
 @returns The string for the key, or nil if there's no string with this key. */
-(NSString*) stringForKey:(NSString*)key;

@end

