//
//  KKSynchronizePositionBehavior.m
//  KoboldKit
//
//  Created by Steffen Itterheim on 19.06.13.
//  Copyright (c) 2013 Steffen Itterheim. All rights reserved.
//

#import "KKSynchronizePositionBehavior.h"

@implementation KKSynchronizePositionBehavior

+(id) synchronizePositionWithNode:(SKNode*)otherNode
{
	return [[self alloc] initWithNode:otherNode offset:CGPointZero multiplier:CGPointMake(1.0, 1.0)];
}

+(id) synchronizePositionWithNode:(SKNode*)otherNode offset:(CGPoint)positionOffset
{
	return [[self alloc] initWithNode:otherNode offset:positionOffset multiplier:CGPointMake(1.0, 1.0)];
}

+(id) synchronizePositionWithNode:(SKNode*)otherNode offset:(CGPoint)positionOffset multiplier:(CGPoint)positionMultiplier
{
	return [[self alloc] initWithNode:otherNode offset:positionOffset multiplier:positionMultiplier];
}

-(id) initWithNode:(SKNode*)otherNode offset:(CGPoint)positionOffset multiplier:(CGPoint)positionMultiplier
{
	self = [super init];
	if (self)
	{
		_otherNode = otherNode;
		_positionOffset = positionOffset;
		_positionMultiplier = positionMultiplier;
		
		_wantsUpdate = YES;
	}
	return self;
}

-(void) didSimulatePhysics
{
	if (self.enabled && _otherNode)
	{
		CGPoint pos = _otherNode.position;
		pos = CGPointMake(pos.x * _positionMultiplier.x + _positionOffset.x,
						  pos.y * _positionMultiplier.y + _positionOffset.y);
		self.node.position = pos;
	}
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
		_otherNode = [decoder decodeObjectForKey:ArchiveKeyForOtherNode];
		_positionOffset = [decoder decodeCGPointForKey:ArchiveKeyForPositionOffset];
		_positionMultiplier = [decoder decodeCGPointForKey:ArchiveKeyForPositionMultiplier];
	}
	return self;
}

-(void) encodeWithCoder:(NSCoder*)encoder
{
	[encoder encodeObject:_otherNode forKey:ArchiveKeyForOtherNode];
	[encoder encodeCGPoint:_positionOffset forKey:ArchiveKeyForPositionOffset];
	[encoder encodeCGPoint:_positionMultiplier forKey:ArchiveKeyForPositionMultiplier];
}

#pragma mark NSCopying

-(id) copyWithZone:(NSZone*)zone
{
	KKSynchronizePositionBehavior* copy = [[super copyWithZone:zone] init];
	copy->_otherNode = _otherNode;
	copy->_positionOffset = _positionOffset;
	copy->_positionMultiplier = _positionMultiplier;
	return copy;
}

#pragma mark Equality

-(BOOL) isEqualToBehavior:(KKNodeBehavior*)behavior
{
	if ([self isMemberOfClass:[behavior class]] == NO)
		return NO;
	
	KKSynchronizePositionBehavior* synchPosBehavior = (KKSynchronizePositionBehavior*)behavior;
	return (synchPosBehavior.otherNode == _otherNode &&
			CGPointEqualToPoint(synchPosBehavior.positionOffset, _positionOffset) &&
			CGPointEqualToPoint(synchPosBehavior.positionMultiplier, _positionMultiplier));
}
@end
