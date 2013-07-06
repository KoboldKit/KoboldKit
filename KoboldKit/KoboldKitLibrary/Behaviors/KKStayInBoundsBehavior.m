//
//  KKStaysInBoundsBehavior.m
//  KoboldKit
//
//  Created by Steffen Itterheim on 22.06.13.
//  Copyright (c) 2013 Steffen Itterheim. All rights reserved.
//

#import "KKStayInBoundsBehavior.h"

@implementation KKStayInBoundsBehavior

+(id) stayInBounds:(CGRect)bounds
{
	return [[self alloc] initWithBounds:bounds];
}

-(id) initWithBounds:(CGRect)bounds
{
	self = [super init];
	if (self)
	{
		_bounds = bounds;
	}
	return self;
}

-(void) didJoinController
{
	_wantsUpdate = YES;
	_nodeIsSprite = [self.node isKindOfClass:[SKSpriteNode class]];

	// update once immediately
	[self didSimulatePhysics];
}

-(void) didSimulatePhysics
{
	SKNode* node = self.node;
	CGPoint nodePos = node.position;
	CGSize nodeSize = CGSizeZero;
	CGPoint anchorPoint = CGPointZero;

	if (_nodeIsSprite)
	{
		SKSpriteNode* sprite = (SKSpriteNode*)node;
		nodeSize = sprite.size;
		anchorPoint = sprite.anchorPoint;
	}
	
	SKPhysicsBody* body = node.physicsBody;
	CGPoint velocity = body.velocity;
	
	// keep node within defined borders
	if (_bounds.origin.x != INFINITY && _bounds.size.width != INFINITY)
	{
		float maxWidth = _bounds.origin.x + _bounds.size.width - 1;
		if ((nodePos.x + nodeSize.width * (1.0 - anchorPoint.x)) > maxWidth)
		{
			nodePos.x = maxWidth - nodeSize.width * (1.0 - anchorPoint.x);
			velocity.x = 0;
		}
		
		if ((nodePos.x - nodeSize.width * anchorPoint.x) < _bounds.origin.x)
		{
			nodePos.x = _bounds.origin.x + nodeSize.width * anchorPoint.x;
			velocity.x = 0;
		}
	}
	
	if (_bounds.origin.y != INFINITY && _bounds.size.height != INFINITY)
	{
		float maxHeight = _bounds.origin.y + _bounds.size.height - 1;
		if ((nodePos.y + nodeSize.height * (1.0 - anchorPoint.y)) > maxHeight)
		{
			nodePos.y = maxHeight - nodeSize.height * (1.0 - anchorPoint.y);
			velocity.y = 0;
		}
		
		if ((nodePos.y - nodeSize.height * anchorPoint.y) < _bounds.origin.y)
		{
			nodePos.y = _bounds.origin.y + nodeSize.height * anchorPoint.y;
			velocity.y = 0;
		}
	}
	
	node.position = nodePos;
	body.velocity = velocity;
}

#pragma mark !! Update methods below whenever class layout changes !!
#pragma mark NSCoding

static NSString* const ArchiveKeyForOtherNode = @"otherNode";
static NSString* const ArchiveKeyForPositionOffset = @"positionOffset";
static NSString* const ArchiveKeyForPositionMultiplier = @"positionMultiplier";

-(id) initWithCoder:(NSCoder*)decoder
{
	self = [super init];
	if (self)
	{
		/*
		_target = [decoder decodeObjectForKey:ArchiveKeyForOtherNode];
		_positionOffset = [decoder decodeCGPointForKey:ArchiveKeyForPositionOffset];
		_positionMultiplier = [decoder decodeCGPointForKey:ArchiveKeyForPositionMultiplier];
		 */
	}
	return self;
}

-(void) encodeWithCoder:(NSCoder*)encoder
{
	/*
	[encoder encodeObject:_target forKey:ArchiveKeyForOtherNode];
	[encoder encodeCGPoint:_positionOffset forKey:ArchiveKeyForPositionOffset];
	[encoder encodeCGPoint:_positionMultiplier forKey:ArchiveKeyForPositionMultiplier];
	 */
}

#pragma mark NSCopying

-(id) copyWithZone:(NSZone*)zone
{
	KKStayInBoundsBehavior* copy = [[super copyWithZone:zone] init];
	copy->_bounds = _bounds;
	copy->_nodeIsSprite = _nodeIsSprite;
	return copy;
}

#pragma mark Equality

-(BOOL) isEqualToBehavior:(KKNodeBehavior*)behavior
{
	if ([self isMemberOfClass:[behavior class]] == NO)
		return NO;
	return NO;
}
@end
