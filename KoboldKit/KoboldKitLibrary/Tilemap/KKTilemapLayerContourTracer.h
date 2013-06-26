//
//  KTContourMap.h
//  Cocos2D+Box2D-GenerateTilemapCollisions
//
//  Created by Steffen Itterheim on 29.05.13.
//  Copyright (c) 2013 Steffen Itterheim. All rights reserved.
//

#import <Foundation/Foundation.h>

@class KKIntegerArray;
@class KKPointArray;
@class KKTilemapLayer;

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


@interface KKTilemapLayerContourTracer : NSObject
{
	@private
	__weak KKTilemapLayer* _layer;
	CGSize _tileSize;
	CGSize _layerSize;

	KKIntegerArray* _blockingGids;
	NSMutableArray* _contours;
	NSMutableArray* _contourSegments;
	NSUInteger _blockMapCount;
	CGSize _blockMapSize;
	uint16_t* _blockMap;
	BOOL _mapBorderBlocking;
}

/** Contains KTPointArray of points definining a single contour's line segments. */
@property (atomic, readonly) NSArray* contourSegments;

+(id) contourMapFromTileLayer:(KKTilemapLayer*)layer blockingGids:(KKIntegerArray*)blockingGids;

@end
