/*
 * Copyright (c) 2012-2013 Steffen Itterheim.
 * Released under the MIT License:
 * KoboldAid/licenses/KoboldKitFree.License.txt
 */


#import "KKTypes.h"

#import "KKTilemapLayer.h"
#import "KKTilemapLayerTiles.h"
#import "KKTilemapObject.h"
#import "KKTilemapProperties.h"
#import "KKTilemapTileProperties.h"
#import "KKTilemapTileset.h"
#import "KKTMXReader.h"
#import "KKTMXWriter.h"

/** @file KKTilemap.h */

@class KKTilemap;
@class KKTilemapTileset;
@class KKTilemapProperties;
@class KKTilemapLayer;

/** Tilemap orientation: orthogonal (rectangular tiles), isometric (diamond/rhombus shaped tiles) and hexagonal (hexagon shaped tiles). */
typedef enum : unsigned char
{
	KKTilemapOrientationOrthogonal,         /**< An orthogonal tilemap */
	KKTilemapOrientationIsometric,          /**< An isometric tilemap */
	KKTilemapOrientationStaggeredIsometric, /**< A "staggered" isometric tilemap (new in Tiled v0.9) */
	KKTilemapOrientationHexagonal,          /**< A hexagonal tilemap - removed from Tiled v0.6 :( */
} KKTilemapOrientation;

/** Represents a TMX Tilemap "map", ie global properties. The tilemap is usually created from a TMX file via the parseTMXFile method. */
@interface KKTilemap : NSObject
{
	@private
	NSMutableArray* _tilesets;
	NSMutableArray* _layers;
	KKTilemapProperties* _properties;
}

/** @name Map Properties */

/** @returns The size of the map, in tiles. */
@property (atomic) CGSize size;
/** The size of tiles. Can be set in Tiled when a new tilemap is created. In the New Map dialog the gridSize is referred to as "Tile Size".
 @returns The size of the grid (tiles) in points. */
@property (atomic) CGSize gridSize;
/** This is the tileSize of the tileset with the largest tile size. Will be the same as gridSize for tilemaps whose tilesets all use the same tile size.
   But if you use tilesets of different tile sizes (ie 32x32 and 128x128) this will be the largest (ie 128x128). Mainly used internally to make sure
   tiles of all sizes properly appear on the screen and do not "pop in/out" near the screen borders. Valid only after tilesets have loaded their textures.
 @returns The largest tile size found in the tilesets used by this tilemap. */
@property (atomic) CGSize largestTileSize;
/** The map's global properties. Editable in Tiled from the menu: Map -> Map Properties.
 @returns The dictionary of properties. */
@property (atomic, readonly) KKTilemapProperties* properties;

/** The orientiation (type) of tilemap.
 @returns The map's KKTilemapOrientation. */
@property (atomic) KKTilemapOrientation orientation;
/** The tilemap's background color. Seen only if there are empty tiles on all layers. Defaults to black.

   TILED-EDITABLE
 @returns The background color. */
@property (atomic) SKColor* backgroundColor;
/** The highest valid gid from all tilesets. Updated when tilesets load their textures. Equal to the lastGid property of the "last" tileset.
   Mainly needed for bounds checks, don't change this value.
 @returns The highest-numbered (theoretical) gid considering all tilesets. */
@property (atomic) gid_t highestGid;

DEVELOPER_FIXME("Tilemap iPad scale factor still needed with Sprite Kit?")

/** @name Scaling */

/** By how much to scale the tilemap if the app is running on an iPad device. Defaults to 1.0f (no scaling, ie iPad displays larger portion of the map). Recommended value: 2.0f.

   Caution: Some combination of values and scale factor may cause inaccuracies, and possibly visual glitches. For example a scale factor of 1.5 and a odd-numbered tile size of 25x25 would
   make the upscaled tilesize 37.5x37.5 - but tile sizes should remain integer values this will affect tile positions and subsequently may introduce issues (this has not been tested, and
   is not recommended - tile sizes really should remain integer values).

   Notes on what this does and what is required to make it work:

   - The -ipad and -ipadhd tileset image's width & height must be scaled accordingly. For example by factor of 2.0f for a scaleFactor of 2.0f.
   - Tileset images' spacing and margin properties must also be scaled accordingly *if* scaleTilesetSpacingAndMargin is set to YES. See its description for when to use it.

   TILED-EDITABLE
 
 @returns The iPad scale factor. */
@property (atomic) float iPadScaleFactor;
/** If set to YES, will also scale each tileset's spacing & margin properties. This can be used if you simply upscale an iPhone tileset with an image program,
   which will also increase any existing spacing & margin accordingly. If you use a texture atlas program, it usually generates the same spacing and margin for all texture
   atlas files regardless of the contained image's scale factor. Defaults to NO (ie for use with a texture atlas program). Can be ignored for texture atlases which have
   neither spacing between tiles nor margin between outermost tiles and texture border.

   TILED-EDITABLE
 @returns Whether to also scale up spacing and margin if iPadScaleFactor is > 1.0. */
@property (atomic) BOOL scaleTilesetSpacingAndMargin;

/** Applies the iPadScaleFactor property. You only need to call this if you're creating a tilemap from scratch at runtime, after your map was completely
   set up. And only if you actually use iPadScaleFactor other than the default. */
-(void) applyIpadScaleFactor;

/** @name Creating a Tilemap */

/** Parse and create a KKTilemap from a file. The file must be in TMX format.
 @param tmxFile The name of a TMX file in the bundle, or an absolute path to a TMX file in a non-bundle directory. 
 @returns A new instance of KTTilemap initialized with the contents of the TMX file. */
+(id) tilemapWithContentsOfFile:(NSString*)tmxFile;

/** Creates an empty tilemap. Use this if you want to create your tilemap world entirely in code.
 @param orientation The orientation (type) of tilemap.
 @param mapSize The size of the tilemap, in tiles.
 @param gridSize The grid size (tile size) of the tilemap.
 @returns A new, empty instance of KTTilemap. */
+(id) tilemapWithOrientation:(KKTilemapOrientation)orientation mapSize:(CGSize)mapSize gridSize:(CGSize)gridSize;

/** @name Writing a Tilemap */

/** Writes the tilemap to a file path. The resulting file will be in TMX format.
 @param path An absolute path to a file in a writable directory (ie AppData or Documents). */
-(void) writeToFile:(NSString*)path;

/** @name Working with tilesets */

/** List of tilesets (KKTilemapTileset) used by this map.
 @returns An array of KTTilemapTileset objects. */
@property (atomic, readonly) NSArray* tilesets;

/** Adds a tileset to the list of tilesets. Only needed when creating or changing a tilemap at runtime.
 @param tileset The tileset to add to the tilemap. */
-(void) addTileset:(KKTilemapTileset*)tileset;

/** Returns the tileset for a specific gid. Mainly to access that tile's properties. Will return nil for invalid gids (gid that points to a non-existing tileset,
   or if gid is 0).
 @param gid The GID of a tile.
 @returns The tileset the gid is part of, or nil if the GID is out of bounds. */
-(KKTilemapTileset*) tilesetForGid:(gid_t)gid;

/** Returns the tileset for a specific gid without flags. Mainly to access that tile's properties. Will return nil for invalid gids (gid that points to a non-existing tileset,
 or if gid is 0).
 @param gid The GID of a tile. Must not have any flags set.
 @returns The tileset the gid is part of, or nil if the GID is out of bounds. */
-(KKTilemapTileset*) tilesetForGidWithoutFlags:(gid_t)gidWithoutFlags;

/** @param name The name of a tileset as displayed in Tiled.
 @returns the tileset with the given name. Returns nil if there's no tileset with this name. */
-(KKTilemapTileset*) tilesetNamed:(NSString*)name;

/** Replaces a tileset with another (actually: it creates an alias) so that tiles drawn with the originalTileset will now be drawn using the otherTileset.
   This can be used to change the atmosphere of the tilemap, perhaps by changing from summer to winter, from "before attack" to "after attack", and so on.

   @warning: Both tilesets need to be compatible (ie same tile size) and the otherTileset should have the same number of tiles in the same place as the originalTileset
   to prevent rendering issues (ie empty tiles, wrong tiles, crashes at the worst).
 
 @param originalTileset The tileset you want to replace.
 @param otherTileset The tileset you want to replace it with.
 */
-(void) replaceTileset:(KKTilemapTileset*)originalTileset withTileset:(KKTilemapTileset*)otherTileset;

/** If tileset was replaced with replaceTileset: method, will restore it so that tiles will be drawn from this tileset again.
 @param originalTileset The tileset to restore. */
-(void) restoreTileset:(KKTilemapTileset*)originalTileset;

/** @name Working with Layers */

/** List of layers (KKTilemapLayer) used by this map, in the draw order respectively the reverse order they appear
 in Tiled's Layers list (bottom-most = first, top-most = last).
 @returns An array of KTTilemapLayer objects. */
@property (atomic, readonly) NSArray* layers;

/** Adds a layer to the list of layers.
 @param layer The layer to add. */
-(void) addLayer:(KKTilemapLayer*)layer;

/** @param name The name identifying a layer, as edited in Tiled.
 @returns The first layer with the given name, or nil if there's no layer with that name. Layer names are case-sensitive! */
-(KKTilemapLayer*) layerNamed:(NSString*)name;

/** Is set whenever the tilemap changes in a way that requires an immediate redraw in the current frame (tile gid change or tilesets swapped).
The modified state is reset automatically by the renderer. You don't normally need to modify it yourself. */
@property (atomic) BOOL modified;

@end

