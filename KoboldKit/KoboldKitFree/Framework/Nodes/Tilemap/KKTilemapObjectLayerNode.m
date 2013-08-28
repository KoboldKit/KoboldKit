/*
 * Copyright (c) 2012-2013 Steffen Itterheim.
 * Released under the MIT License:
 * KoboldAid/licenses/KoboldKitFree.License.txt
 */


#import "KKTilemapObjectLayerNode.h"
#import "KKTilemap.h"
#import "KKTilemapLayer.h"

@implementation KKTilemapObjectLayerNode

+(id) objectLayerNodeWithLayer:(KKTilemapLayer*)layer
{
	return [[self alloc] initWithLayer:layer];
}

@end
