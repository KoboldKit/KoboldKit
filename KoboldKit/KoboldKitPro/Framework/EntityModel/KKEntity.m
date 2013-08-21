//
//  KKEntity.m
//  KoboldKitPro
//
//  Created by Steffen Itterheim on 18.08.13.
//  Copyright (c) 2013 Steffen Itterheim. All rights reserved.
//

#import "KKEntity.h"
#import "KKProFramework.h"

@implementation KKEntity

+(id) entityWithNode:(SKNode*)node tilemapObject:(KKTilemapObject*)tilemapObject
{
	return [[self alloc] initWithNode:node tilemapObject:tilemapObject];
}

-(id) initWithNode:(SKNode*)node tilemapObject:(KKTilemapObject*)tilemapObject
{
	self = [super init];
	if (self)
	{
		_node = node;
		_node.entity = self;
		_maximumVelocity = CGPointMake(INFINITY, INFINITY);
		_position = node.position;
		_positionInPixels = _position;
		_spawnPosition = _position;
		_initialPosition = _position;
		_boundingBox = _node.frame;
		_type = KKEntityTypeStatic;
	}
	return self;
}

@end
