//
// KTTilemapProperties.h
// KoboldTouch-Libraries
//
// Created by Steffen Itterheim on 21.01.13.
//
//

#import "KKTypes.h"

@class KKMutableNumber;

/** KTTilemapProperties is a thin wrapper around NSMutableDictionary. It only allows NSString as keys and either KKMutableNumber or NSString as values (objects).
   Values can only be added and replaced but not removed. For weakly typed runtime variables use KTModel variables instead.

   It represents Tilemap properties. Properties are values (strings or numbers) indexed by name. The properties are editable in Tiled primarily
   by right-clicking (layer, tile, tileset, object, etc) with the exception of map (global) properties which can only be edited from the menu: Map -> Map Properties.

   Caution: for decimal numbers to be recognized you must use the dot as decimal separator (comma won't work). The reason for not making it locale-aware
   is that sharing TMX files between users with different system locales (ie US vs DE) would be difficult because it would require converting the TMX from one locale to the other. */
@interface KKTilemapProperties : NSObject
{
	@private
	NSMutableDictionary* _properties;
}

/** The properties as key-value dictionary. Keys are NSString objects, values are KKMutableNumber objects. */
@property (atomic, readonly) NSDictionary* properties;

/** Returns the number of property items. */
@property (atomic, readonly) NSUInteger count;

/** Sets the number for the given key. If a value for the given key already exists the number will take its place.

   Caution: it is illegal to set a KKMutableNumber for an already existing key that stores a NSString. */
-(void) setNumber:(KKMutableNumber*)number forKey:(NSString*)key;

/** Sets the string for the given key. If a value for the given key already exists the string will take its place.

   Caution: it is illegal to set a NSString for an already existing key that stores a KKMutableNumber. */
-(void) setString:(NSString*)string forKey:(NSString*)key;

/** (KTTMXReader only) This method first determines if the string can be converted to KKMutableNumber and if so, will set the KKMutableNumber.
   Otherwise it will set the string. */
-(void) setValue:(NSString*)string forKey:(NSString*)key;

/** Returns a KKMutableNumber from a string if the string is convertable to a number. Otherwise returns nil.
   Note: floating point numbers must use . (dot) as floating point separator. */
-(KKMutableNumber*) numberFromString:(NSString*)string;

/** Returns the KKMutableNumber for the key. If there's no number for that key returns nil. */
-(KKMutableNumber*) numberForKey:(NSString*)key;

/** Returns the NSString for the key. If there's no string for that key returns nil. */
-(NSString*) stringForKey:(NSString*)key;

@end

