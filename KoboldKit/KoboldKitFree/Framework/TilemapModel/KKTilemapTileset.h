/*
 * Copyright (c) 2012-2013 Steffen Itterheim.
 * Released under the MIT License:
 * KoboldAid/licenses/KoboldKitFree.License.txt
 */

#import "KKTypes.h"

/** @file KTTilemapTileset.h */

@class KKTilemap;
@class KKTilemapProperties;
@class KKTilemapTileProperties;
@class SKTexture;

/** The Tile flip flags for the various "flip" orientations a tile can be set at on a layer.
   These flags are encoded into the tile GID. */
typedef enum : gid_t
{
	KKTilemapTileHorizontalFlip = 0x80000000,                                                                        /**< set if the tile is horizontally flipped */
	KKTilemapTileVerticalFlip = 0x40000000,                                                                          /**< set if the tile is vertically flipped */
	KKTilemapTileDiagonalFlip = 0x20000000,                                                                          /**< set if the tile is diagonally flipped */
	KKTilemapTileFlippedAll = (KKTilemapTileHorizontalFlip | KKTilemapTileVerticalFlip | KKTilemapTileDiagonalFlip), /**< all three flip flags OR'ed together */
	KKTilemapTileFlipMask = ~(KKTilemapTileFlippedAll),                                                              /**< the negation of KTTilemapTileFlippedAll, ie all bits are set EXCEPT for the three flip flags */
} KKTilemapTileFlags;

/** TMX Tileset contains all the tileset data, most importantly the tileset image file and tile properties.
   Also holds a reference to the tileset texture after it has been loaded. Accessing the texture property will load the texture. */
@interface KKTilemapTileset : NSObject
{
	@private
	__weak SKTexture* _texture;
	__weak KKTilemapTileset* _alternateTileset;
	NSMutableArray* _tileTextures;
	KKTilemapProperties* _properties;
	KKTilemapTileProperties* _tileProperties;
}

/** Reference to the owning KTTilemap object. Mainly for internal use. */
@property (atomic, weak) KKTilemap* tilemap;
/** The name of the tileset. TILED-EDITABLE */
@property (atomic, copy) NSString* name;
/** The image file without the path. Assumes the image file is in bundle's root folder. */
@property (nonatomic, copy) NSString* imageFile;
/** Points to the alternate tileset, used to draw tiles of this tileset from a different texture. Set by calling replaceTileset:withTileset: on KTTilemap. */
@property (atomic, readonly) KKTilemapTileset* alternateTileset;
/** The first GID in this tileset. It's the top-left tile in the tileset. */
@property (atomic) gid_t firstGid;
/** The last GID in this tileset. It's the bottom-most, right-most tile in the tileset.
   Caution: lastGid is only valid after the tileset texture has been loaded. It will be 0 before that. */
@property (atomic) gid_t lastGid;
/** How many tiles per row are in this tileset. */
@property (atomic) unsigned int tilesPerRow;
/** How many tiles per column are in this tileset. */
@property (atomic) unsigned int tilesPerColumn;
/** How much space (in points) is between individual tiles. If there's a spacing of 2, there will be a spacing of 2 points
   (4 pixels for -hd tileset images) between two adjacent tiles. Spacing is the same for both horizontal and vertical. */
@property (atomic) int spacing;
/** The margin defines how much spacing (in points) there is from the texture border to the first tile. Margin is the same for both horizontal and vertical. */
@property (atomic) int margin;
/** Drawing offset determines placement of tiles relative to the tile's origin. Can be used if tileset should not align with the grid but offset by a certain
   distance from the grid. TILED-EDITABLE */
@property (atomic) CGPoint drawOffset;
/** The size of tiles (in points). */
@property (atomic) CGSize tileSize;
/* The transparent color for this tileset. Format is in 3-digit hex numbers, for example "AB99F0".
   Note: it's a string because I didn't want to bother converting to ccColor3B just because I didn't expect anyone to use it. If I'm wrong about that please let me know. */
// @property (atomic, copy) NSString* transparentColor;
/** The texture used by this tileset. If this property is accessed while it's still nil, it will load the texture. */
@property (atomic, readonly) SKTexture* texture;
/** The textures for each tile in the tileset. The index of a texture for a specific gid is obtained by subtracting firstGid from gid: textureIndes = gid - firstGid */
@property (atomic, readonly) NSArray* tileTextures;
/** The tileset's properties. Properties for individual tiles are in tileProperties. */
@property (atomic, readonly) KKTilemapProperties* properties;
/** Contains each tile's properties. Properties for the tileset itself are in properties. */
@property (atomic, readonly) KKTilemapTileProperties* tileProperties;

/** Gets the texture of a tile GID from this tileset.
 @param gid The tile gid whose texture should be returned.
 @returns The texture for a specific GID, or nil if the gid is not in this tileset. */
-(SKTexture*) textureForGid:(gid_t)gid;
/** Gets the texture of a tile GID from this tileset. Gid must not have any flags set.
 @param gid The tile gid without flags whose texture should be returned.
 @returns The texture for a specific GID, or nil if the gid is not in this tileset. */
-(SKTexture*) textureForGidWithoutFlags:(gid_t)gidWithoutFlags;

// internal use only
-(void) setAlternateTileset:(KKTilemapTileset*)alternateTileset;

@end

