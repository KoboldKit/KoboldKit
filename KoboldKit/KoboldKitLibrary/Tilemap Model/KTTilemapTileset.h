//
// KTTilemapTileset.h
// KoboldTouch-Libraries
//
// Created by Steffen Itterheim on 20.12.12.
//
//


#import "KKTypes.h"

/** @file KTTilemapTileset.h */

@class KTTilemap;
@class KTTilemapProperties;
@class KTTilemapTileProperties;
@class SKTexture;

/** The Tile flip flags for the various "flip" orientations a tile can be set at on a layer.
   These flags are encoded into the tile GID. */
typedef enum : gid_t
{
	KTTilemapTileHorizontalFlip = 0x80000000,                                                                        /**< set if the tile is horizontally flipped */
	KTTilemapTileVerticalFlip = 0x40000000,                                                                          /**< set if the tile is vertically flipped */
	KTTilemapTileDiagonalFlip = 0x20000000,                                                                          /**< set if the tile is diagonally flipped */
	KTTilemapTileFlippedAll = (KTTilemapTileHorizontalFlip | KTTilemapTileVerticalFlip | KTTilemapTileDiagonalFlip), /**< all three flip flags OR'ed together */
	KTTilemapTileFlipMask = ~(KTTilemapTileFlippedAll),                                                              /**< the negation of KTTilemapTileFlippedAll, ie all bits are set EXCEPT for the three flip flags */
} KTTilemapTileFlags;

/** TMX Tileset contains all the tileset data, most importantly the tileset image file and tile properties.
   Also holds a reference to the tileset texture after it has been loaded. Accessing the texture property will load the texture. */
@interface KTTilemapTileset : NSObject
{
	@private
	__weak SKTexture* _texture;
	__weak KTTilemapTileset* _alternateTileset;
	NSMutableArray* _tileTextures;
	KTTilemapProperties* _properties;
	KTTilemapTileProperties* _tileProperties;
}

/** Reference to the owning KTTilemap object. Mainly for internal use. */
@property (nonatomic, weak) KTTilemap* tilemap;
/** The name of the tileset. TILED-EDITABLE */
@property (nonatomic, copy) NSString* name;
/** The image file without the path. Assumes the image file is in bundle's root folder. */
@property (nonatomic, copy) NSString* imageFile;
/** Points to the alternate tileset, used to draw tiles of this tileset from a different texture. Set by calling replaceTileset:withTileset: on KTTilemap. */
@property (nonatomic, readonly) KTTilemapTileset* alternateTileset;
/** The first GID in this tileset. It's the top-left tile in the tileset. */
@property (nonatomic) gid_t firstGid;
/** The last GID in this tileset. It's the bottom-most, right-most tile in the tileset.
   Caution: lastGid is only valid after the tileset texture has been loaded. It will be 0 before that. */
@property (nonatomic) gid_t lastGid;
/** How many tiles per row are in this tileset. */
@property (nonatomic) unsigned int tilesPerRow;
/** How many tiles per column are in this tileset. */
@property (nonatomic) unsigned int tilesPerColumn;
/** How much space (in points) is between individual tiles. If there's a spacing of 2, there will be a spacing of 2 points
   (4 pixels for -hd tileset images) between two adjacent tiles. Spacing is the same for both horizontal and vertical. */
@property (nonatomic) int spacing;
/** The margin defines how much spacing (in points) there is from the texture border to the first tile. Margin is the same for both horizontal and vertical. */
@property (nonatomic) int margin;
/** Drawing offset determines placement of tiles relative to the tile's origin. Can be used if tileset should not align with the grid but offset by a certain
   distance from the grid. TILED-EDITABLE */
@property (nonatomic) CGPoint drawOffset;
/** The size of tiles (in points). */
@property (nonatomic) CGSize tileSize;
/* The transparent color for this tileset. Format is in 3-digit hex numbers, for example "AB99F0".
   Note: it's a string because I didn't want to bother converting to ccColor3B just because I didn't expect anyone to use it. If I'm wrong about that please let me know. */
// @property (nonatomic, copy) NSString* transparentColor;
/** The texture used by this tileset. If this property is accessed while it's still nil, it will load the texture. */
@property (nonatomic, readonly) SKTexture* texture;
/** The textures for each tile in the tileset. The index of a texture for a specific gid is obtained by subtracting firstGid from gid: textureIndes = gid - firstGid */
@property (nonatomic, readonly) NSArray* tileTextures;
/** The tileset's properties. Properties for individual tiles are in tileProperties. */
@property (nonatomic, readonly) KTTilemapProperties* properties;
/** Contains each tile's properties. Properties for the tileset itself are in properties. */
@property (nonatomic, readonly) KTTilemapTileProperties* tileProperties;

/** @returns The texture for a specific GID, or nil if the gid is not in this tileset. */
-(SKTexture*) textureForGid:(gid_t)gid;

// internal use only
-(void) setAlternateTileset:(KTTilemapTileset*)alternateTileset;

@end
