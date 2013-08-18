//
//  KKTilemapLayerNode.m
//  KoboldKit
//
//  Created by Steffen Itterheim on 18.06.13.
//  Copyright (c) 2013 Steffen Itterheim. All rights reserved.
//

#import "KKTilemapLayerNode.h"
#import "KKMacros.h"
#import "KKTilemapLayer.h"
#import "KKTilemap.h"

@implementation KKTilemapLayerNode

-(id) initWithLayer:(KKTilemapLayer*)layer
{
	self = [super init];
	if (self)
	{
		_layer = layer;
		_tilemap = _layer.tilemap;
		self.name = layer.name;
	}
	return self;
}

@end
