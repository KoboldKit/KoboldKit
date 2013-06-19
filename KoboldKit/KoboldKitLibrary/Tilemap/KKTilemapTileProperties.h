//
// KTTilemapTileProperties.h
// KoboldTouch-Libraries
//
// Created by Steffen Itterheim on 21.01.13.
//
//



@class KKTilemapProperties;
@class KKMutableNumber;

/** Wrapper for tile properties, it stores one KTTilemapProperties object per tile that has properties. You can get/set KTTilemapProperties for a given tile gid
   by using the propertiesForGid: methods. If a gid has no properties nil will be returned. In cases where you want to create the properties of a gid
   use the createNonExistingProperties flag so that a new KTTilemapProperties object is created and associated with the gid if the gid has no properties yet. */
@interface KKTilemapTileProperties : NSObject
{
	@private
	NSMutableDictionary* _properties;
}

/** Dictionary of tile properties with gid as key (NSNumber) and values are KTTilemapProperties objects storing that tile's properties. */
@property (nonatomic, readonly) NSDictionary* properties;

/** Sets the number for the key on the tile gid's properties. Creates an instance of KTTilemapProperties if the gid has no properties yet. Returns that tile's properties. */
-(KKTilemapProperties*) propertiesForGid:(gid_t)gid setNumber:(KKMutableNumber*)number forKey:(NSString*)key;
/** Sets the string for the key on the tile gid's properties. Creates an instance of KTTilemapProperties if the gid has no properties yet. Returns that tile's properties. */
-(KKTilemapProperties*) propertiesForGid:(gid_t)gid setString:(NSString*)string forKey:(NSString*)key;
/** (KTTMXReader only) Sets a string or number (if string is convertible to number) for the key on the tile gid's properties.
   Creates an instance of KTTilemapProperties if the gid has no properties yet. Returns that tile's properties. */
-(KKTilemapProperties*) propertiesForGid:(gid_t)gid setValue:(NSString*)string forKey:(NSString*)key;

/** Returns the properties for a tile gid. Returns nil if the gid has no properties. */
-(KKTilemapProperties*) propertiesForGid:(gid_t)gid;

/** Returns the properties for a tile gid. If createNonExistingProperties is YES and if the gid has no properties, will create a new
   KTTilemapProperties object, set it as the tile gid's properties object, and return it. If createNonExistingProperties is NO behaves
   identical to propertiesForGid: by returning nil for non-existing tile properties. */
-(KKTilemapProperties*) propertiesForGid:(gid_t)gid createNonExistingProperties:(BOOL)createNonExistingProperties;

@end

