/*
 * Copyright (c) 2012-2013 Steffen Itterheim.
 * Released under the MIT License:
 * KoboldAid/licenses/KoboldKitFree.License.txt
 */

#import <Foundation/Foundation.h>

@class KKIntegerArray;
@class KKPointArray;
@class KKTilemapLayer;

// neighbor indices
typedef enum
{
	KKNeighborLeft,
	KKNeighborUpLeft,
	KKNeighborUp,
	KKNeighborUpRight,
	KKNeighborRight,
	KKNeighborDownRight,
	KKNeighborDown,
	KKNeighborDownLeft,
	
	KKNeighborIndices_Count,
} KKNeighborIndices;


/** Internal use. Performs contour tracing of a tile layer and returns the resulting contour segments
 as CGPathRef or KKPointArray. */
@interface KKTilemapLayerContourTracer : NSObject
{
	@private
	__weak KKTilemapLayer* _layer;
	CGSize _tileSize;
	CGSize _layerSize;

	KKIntegerArray* _blockingGids;
	NSMutableArray* _contourTiles;
	NSMutableArray* _contourSegments;
	NSUInteger _blockMapCount;
	NSUInteger _currentStartTile;
	NSUInteger _currentNeighborTile;
	NSUInteger _currentBacktrackTile;
	CGSize _blockMapSize;
	uint16_t* _blockMap;
	BOOL _mapBorderBlocking;
}

/** Contains array of CGPathRef definining the contours' line segments. */
@property (atomic, readonly) NSArray* contourSegments;

/** Parses the tile layer and creates a contour map.
 @returns Instance of KKTilemapLayerContourTracer.
 @param layer A tile layer. */
+(id) contourMapFromTileLayer:(KKTilemapLayer*)layer;
/** Parses the tile layer and creates a contour map.
 @returns Instance of KKTilemapLayerContourTracer.
 @param layer A tile layer.
 @param blockingGids An integer array of specific GIDs that should be considered as blocking. */
+(id) contourMapFromTileLayer:(KKTilemapLayer*)layer blockingGids:(KKIntegerArray*)blockingGids;

@end
