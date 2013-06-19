//
//  KKTilemapObjectLayerNode.m
//  KoboldKit
//
//  Created by Steffen Itterheim on 18.06.13.
//  Copyright (c) 2013 Steffen Itterheim. All rights reserved.
//

#import "KKTilemapObjectLayerNode.h"
#import "KKTilemap.h"
#import "KKTilemapLayer.h"

@implementation KKTilemapObjectLayerNode

+(id) objectLayerWithLayer:(KKTilemapLayer*)layer tilemap:(KKTilemap*)tilemap
{
	return [[self alloc] initWithLayer:layer tilemap:tilemap];
}

-(id) initWithLayer:(KKTilemapLayer*)layer tilemap:(KKTilemap*)tilemap
{
	self = [super init];
	if (self)
	{
		_layer = layer;
		_tilemap = tilemap;
	}
	return self;
}

@end
