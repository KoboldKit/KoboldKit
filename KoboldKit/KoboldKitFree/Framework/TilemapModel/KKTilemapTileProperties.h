/*
 * Copyright (c) 2012-2013 Steffen Itterheim.
 * Released under the MIT License:
 * KoboldAid/licenses/KoboldKitFree.License.txt
 */

@class KKTilemapProperties;
@class KKMutableNumber;

/** Wrapper for tile properties, it stores one KTTilemapProperties object per tile that has properties. You can get/set KTTilemapProperties for a given tile gid
   by using the propertiesForGid: methods. If a gid has no properties nil will be returned. In cases where you want to create the properties of a gid
   use the createNonExistingProperties flag so that a new KTTilemapProperties object is created and associated with the gid if the gid has no properties yet. */
@interface KKTilemapTileProperties : NSObject

/** Dictionary of tile properties with gid as key (NSNumber) and values are KTTilemapProperties objects storing that tile's properties. */
@property (atomic, readonly) NSMutableDictionary* properties;

/** Returns the number of property items. */
@property (atomic, readonly) NSUInteger count;

/** Sets the number for the key on the tile gid's properties. Creates an instance of KTTilemapProperties if the gid has no properties yet.
 @param gid The gid whose properties will be used.
 @param number The number to set.
 @param key The key uniquely identifying the number.
 @returns The tile's properties. */
-(KKTilemapProperties*) propertiesForGid:(gid_t)gid setNumber:(KKMutableNumber*)number forKey:(NSString*)key;
/** Sets the string for the key on the tile gid's properties. Creates an instance of KTTilemapProperties if the gid has no properties yet.
 @param gid The gid whose properties will be used.
 @param string The string to set.
 @param key The key uniquely identifying the number.
 @returns The tile's properties.*/
-(KKTilemapProperties*) propertiesForGid:(gid_t)gid setString:(NSString*)string forKey:(NSString*)key;
/** (KTTMXReader only) Sets a string or number (if string is convertible to number) for the key on the tile gid's properties.
   Creates an instance of KTTilemapProperties if the gid has no properties yet.
 @param gid The gid whose properties will be used.
 @param string The string to set. If the string is convertible to a number, will create a KKMutableNumber object and set that instead.
 @param key The key uniquely identifying the number.
 @returns The tile's properties. */
-(KKTilemapProperties*) propertiesForGid:(gid_t)gid setValue:(NSString*)string forKey:(NSString*)key;

/** @param gid The gid whose properties should be returned.
 @returns the properties for a tile gid. Returns nil if the gid has no properties. */
-(KKTilemapProperties*) propertiesForGid:(gid_t)gid;

/** @param gid The gid whose properties should be returned.
 @param createNonExistingProperties If YES and the gid has no properties it will create a new KTTilemapProperties object, set it as the tile gid's properties object, 
 and return it. If createNonExistingProperties is NO behaves identical to propertiesForGid: by returning nil for non-existing tile properties.
 @returns The properties for a tile gid. */
-(KKTilemapProperties*) propertiesForGid:(gid_t)gid createNonExistingProperties:(BOOL)createNonExistingProperties;

@end

