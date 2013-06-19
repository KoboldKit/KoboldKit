//
// KTTilemap.h
// Kobold2D-Libraries
//
// Created by Steffen Itterheim on 13.10.12.
//
//

#import "KKTypes.h"

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
	BOOL _iPadScaleFactorApplied;
}

/** The size of the map, in tiles. */
@property (nonatomic) CGSize mapSize;
/** The size of the "grid", meaning: the height & width of the tiles (in points). Can only be set in Tiled when a new tilemap is created. In the
   New Map dialog the gridSize is called "Tile Size". */
@property (nonatomic) CGSize gridSize;
/** This is the tileSize of the tileset with the largest tile size. Will be the same as gridSize for tilemaps whose tilesets all use the same tile size.
   But if you use tilesets of different tile sizes (ie 32x32 and 128x128) this will be the largest (ie 128x128). Mainly used internally to make sure
   tiles of all sizes properly appear on the screen and do not "pop in/out" near the screen borders. Valid only after tilesets have loaded their textures. */
@property (nonatomic) CGSize largestTileSize;
/** The map's global properties. Editable in Tiled from the menu: Map -> Map Properties. */
@property (nonatomic, readonly) KKTilemapProperties* properties;

/** List of tilesets (KKTilemapTileset) used by this map. */
@property (nonatomic, readonly) NSArray* tilesets;
/** List of layers (KKTilemapLayer) used by this map, in the draw order respectively the reverse order they appear
   in Tiled's Layers list (bottom-most = first, top-most = last). */
@property (nonatomic, readonly) NSArray* layers;
/** The orientiation (type) of tilemap. */
@property (nonatomic) KKTilemapOrientation orientation;
/** The tilemap's background color. Seen only if there are empty tiles on all layers. Defaults to black.

   TILED-EDITABLE */
@property (nonatomic, copy) NSString* backgroundColor;
/** The highest valid gid from all tilesets. Updated when tilesets load their textures. Equal to the lastGid property of the "last" tileset.
   Mainly needed for bounds checks. */
@property (nonatomic) gid_t highestGid;
/** By how much to scale the tilemap if the app is running on an iPad device. Defaults to 1.0f (no scaling, ie iPad displays larger portion of the map). Recommended value: 2.0f.

   Caution: Some combination of values and scale factor may cause inaccuracies, and possibly visual glitches. For example a scale factor of 1.5 and a odd-numbered tile size of 25x25 would
   make the upscaled tilesize 37.5x37.5 - but tile sizes should remain integer values this will affect tile positions and subsequently may introduce issues (this has not been tested, and
   is not recommended - tile sizes really should remain integer values).

   Notes on what this does and what is required to make it work:

   - The -ipad and -ipadhd tileset image's width & height must be scaled accordingly. For example by factor of 2.0f for a scaleFactor of 2.0f.
   - Tileset images' spacing and margin properties must also be scaled accordingly *if* scaleTilesetSpacingAndMargin is set to YES. See its description for when to use it.

   TILED-EDITABLE */
@property (nonatomic) float iPadScaleFactor;
/** If set to YES, will also scale each tileset's spacing & margin properties. This can be used if you simply upscale an iPhone tileset with an image program,
   which will also increase any existing spacing & margin accordingly. If you use a texture atlas program, it usually generates the same spacing and margin for all texture
   atlas files regardless of the contained image's scale factor. Defaults to NO (ie for use with a texture atlas program). Can be ignored for texture atlases which have
   neither spacing between tiles nor margin between outermost tiles and texture border.

   TILED-EDITABLE */
@property (nonatomic) BOOL scaleTilesetSpacingAndMargin;

/** Applies the iPadScaleFactor property. You only need to call this if you're creating a tilemap from scratch at runtime, after your map was completely
   set up. And only if you actually use iPadScaleFactor other than the default. */
-(void) applyIpadScaleFactor;

/** Parse and create a KKTilemap from a file. The file must be in TMX format. */
+(id) tilemapWithContentsOfFile:(NSString*)tmxFile;

/** Creates an empty tilemap. Use this if you want to create your tilemap world entirely in code. */
+(id) tilemapWithOrientation:(KKTilemapOrientation)orientation mapSize:(CGSize)mapSize gridSize:(CGSize)gridSize;

/** Writes the tilemap to a file path. The resulting file will be in TMX format. */
-(void) writeToFile:(NSString*)path;

/** Adds a tileset to the list of tilesets. */
-(void) addTileset:(KKTilemapTileset*)tileset;

/** Returns the tileset for a specific gid. Mainly to access that tile's properties. Will return nil for invalid gids (gid that points to a non-existing tileset,
   or if gid is 0). */
-(KKTilemapTileset*) tilesetForGid:(gid_t)gid;

/** Returns the tileset with the given name. Returns nil if there's no tileset with this name. */
-(KKTilemapTileset*) tilesetNamed:(NSString*)name;

/** Replaces a tileset with another (actually: it creates an alias) so that tiles drawn with the originalTileset will now be drawn using the otherTileset.
   This can be used to change the atmosphere of the tilemap, perhaps by changing from summer to winter, from "before attack" to "after attack", and so on.

   Caution: both tilesets need to be compatible (ie same tile size) and the otherTileset should have the same number of tiles in the same place as the originalTileset
   to prevent rendering issues (ie empty tiles, wrong tiles, crashes at the worst). */
-(void) replaceTileset:(KKTilemapTileset*)originalTileset withTileset:(KKTilemapTileset*)otherTileset;

/** If tileset was replaced with replaceTileset: method, will restore it so that tiles will be drawn from this tileset again. */
-(void) restoreTileset:(KKTilemapTileset*)originalTileset;

/** Adds a tileset to the list of tilesets. */
-(void) addLayer:(KKTilemapLayer*)layer;

/** Returns the first layer with the given name, or nil if there's no layer with that name. Layer names are case-sensitive! */
-(KKTilemapLayer*) layerNamed:(NSString*)name;

/** Is set whenever the tilemap changes (tile gid change or tilesets swapped). State is not reset automatically.
 Used to determine whether the tilemap needs redrawing. */
@property (nonatomic) BOOL modified;

@end

