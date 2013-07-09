//
// KTTilemapLayerTiles.h
// KoboldTouch-Libraries
//
// Created by Steffen Itterheim on 20.12.12.
//
//


#import "KKTypes.h"

@class KKTilemap;
@class KKTilemapTileset;

/** TMX Tiles of a tile layer. This is just a list of GIDs pointing to a specific tile in the tileset.
   The GIDs have the KTTilemapTileFlip flags encoded, so it is recommended to use the tileAt method from KTTilemapLayer
   instead of accessing the GIDs directly.

   However the latter may be preferable if you need to access many GIDs consecutively, for example for pathfinding algorithms.
   And if there are no flip flags used on the pathfinding layer, you don't even need to mask out the KTTilemapTileFlip flags. */
@interface KKTilemapLayerTiles : NSObject

/** Returns the memory buffer containing a layer's tile GIDs. */
@property (atomic, readonly) gid_t* gid;
/** Returns the size (in bytes) of the GID memory buffer. Equal to (mapSize.width * mapSize.height * sizeof(gid_t)). */
@property (atomic, readonly) unsigned int gidSize;
/** Returns the number of GIDs in the GID memory buffer. Equal to (mapSize.width * mapSize.height). */
@property (atomic, readonly) unsigned int gidCount;

/** Takes an already allocated GID buffer with the given bufferSize (in bytes) and takes ownership for it.
   Which means: you should not free() the tiles buffer, it will be freed by KTTilemapLayerTiles when it deallocates.

   This method also sets the gidCount, which it derives from (gidSize / sizeof(gid_t)). */
-(void) takeOwnershipOfGidBuffer:(gid_t*)tiles bufferSize:(unsigned int)bufferSize;

@end

