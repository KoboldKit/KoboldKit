/*
 * Copyright (c) 2013 Steffen Itterheim.
 * Released under a PROPRIETARY License:
 * KoboldKit/KoboldKitPro/KoboldKitPro.License.txt
 */

#import "KKEntityDynamicsBehavior.h"
#import "KKEntity.h"

@implementation KKEntityDynamicsBehavior

-(void) didInitialize
{
	_kinematicEntities = [NSMutableArray arrayWithCapacity:8];
	_dynamicEntities = [NSMutableArray arrayWithCapacity:8];
	_playerEntities = [NSMutableArray arrayWithCapacity:2];
	
	_gravity = CGPointMake(0.0, -0.98);
	_speed = 1.0;
}

-(void) didJoinController
{
	[self.node.kkScene addSceneEventsObserver:self];
}

-(void) didLeaveController
{
	[self.node.kkScene removeSceneEventsObserver:self];
	
	[_kinematicEntities removeAllObjects];
	[_dynamicEntities removeAllObjects];
	[_playerEntities removeAllObjects];
}


-(void) addEntity:(KKEntity *)entity
{
	NSAssert1(entity.type != KKEntityTypeStatic, @"KKEntityDynamicsBehavior doesn't accept static entities (%@)", entity);

	if (entity.type == KKEntityTypeDynamic)
	{
		[_dynamicEntities addObject:entity];
	}
	else if (entity.type == KKEntityTypePlayer)
	{
		[_playerEntities addObject:entity];
	}
	else
	{
		[_kinematicEntities addObject:entity];
	}
}

-(void) didEvaluateActions
{
	const CGPoint infinityVelocity = CGPointMake(INFINITY, INFINITY);
	KKTilemapNode* tilemapNode = (KKTilemapNode*)self.node;
	
	for (KKEntity* entity in _dynamicEntities)
	{
		// apply gravity
		CGPoint newVelocity = ccpAdd(entity.velocity, _gravity);
		
		// cap new velocity
		CGPoint maxVelocity = entity.maximumVelocity;
		if (CGPointEqualToPoint(maxVelocity, infinityVelocity) == NO)
		{
			newVelocity.x = MAX(newVelocity.x, -maxVelocity.x);
			newVelocity.x = MIN(newVelocity.x, maxVelocity.x);
			newVelocity.y = MAX(newVelocity.y, -maxVelocity.y);
			newVelocity.y = MIN(newVelocity.y, maxVelocity.y);
		}

		// speed is unaffected by max velocity caps, hence speed is applied afterwards
		newVelocity = ccpMult(newVelocity, _speed);
		LOG_EXPR(newVelocity);
		
		// update position
		CGPoint previousPosition = entity.position;
		CGPoint newPosition;
		newPosition.x = previousPosition.x + newVelocity.x;
		newPosition.y = previousPosition.y + newVelocity.y;

		CGPoint tileCoord = [tilemapNode.mainTileLayerNode tileCoordForPoint:newPosition];
		tileCoord.y += 1;
		
		gid_t gid = [tilemapNode.mainTileLayerNode.layer tileGidAt:tileCoord];
		if (gid)
		{
			newVelocity.y = 0.0;
			CGPoint tilePos = [tilemapNode.mainTileLayerNode positionForTileCoord:tileCoord];
			newPosition.y = tilePos.y + 2 * tilemapNode.tilemap.gridSize.height;
		}

		// apply updated velocity & position to entity and node
		entity.velocity = newVelocity;
		entity.position = newPosition;
		entity.node.position = newPosition;
	}
}

@end
