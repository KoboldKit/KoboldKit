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

+(id) objectLayerNodeWithLayer:(KKTilemapLayer*)layer
{
	return [[self alloc] initWithLayer:layer];
}

@end
