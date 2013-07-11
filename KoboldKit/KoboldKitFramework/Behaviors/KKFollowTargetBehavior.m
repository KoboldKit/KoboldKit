//
//  KKFollowsTargetBehavior
//  KoboldKit
//
//  Created by Steffen Itterheim on 19.06.13.
//  Copyright (c) 2013 Steffen Itterheim. All rights reserved.
//

#import "KKFollowTargetBehavior.h"

@implementation KKFollowTargetBehavior

+(id) followTarget:(SKNode*)target
{
	return [[self alloc] initWithTarget:target offset:CGPointZero multiplier:CGPointMake(1.0, 1.0)];
}

+(id) followTarget:(SKNode*)target offset:(CGPoint)positionOffset
{
	return [[self alloc] initWithTarget:target offset:positionOffset multiplier:CGPointMake(1.0, 1.0)];
}

+(id) followTarget:(SKNode*)target offset:(CGPoint)positionOffset multiplier:(CGPoint)positionMultiplier
{
	return [[self alloc] initWithTarget:target offset:positionOffset multiplier:positionMultiplier];
}

-(id) initWithTarget:(SKNode*)target offset:(CGPoint)positionOffset multiplier:(CGPoint)positionMultiplier
{
	self = [super init];
	if (self)
	{
		_target = target;
		_positionOffset = positionOffset;
		_positionMultiplier = positionMultiplier;
		
		_wantsUpdate = YES;
	}
	return self;
}

-(void) didSimulatePhysics
{
	if (_target && self.enabled)
	{
		CGPoint pos = _target.position;
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
		_target = [decoder decodeObjectForKey:ArchiveKeyForOtherNode];
		_positionOffset = [decoder decodeCGPointForKey:ArchiveKeyForPositionOffset];
		_positionMultiplier = [decoder decodeCGPointForKey:ArchiveKeyForPositionMultiplier];
	}
	return self;
}

-(void) encodeWithCoder:(NSCoder*)encoder
{
	[encoder encodeObject:_target forKey:ArchiveKeyForOtherNode];
	[encoder encodeCGPoint:_positionOffset forKey:ArchiveKeyForPositionOffset];
	[encoder encodeCGPoint:_positionMultiplier forKey:ArchiveKeyForPositionMultiplier];
}

#pragma mark NSCopying

-(id) copyWithZone:(NSZone*)zone
{
	KKFollowTargetBehavior* copy = [[super copyWithZone:zone] init];
	copy->_target = _target;
	copy->_positionOffset = _positionOffset;
	copy->_positionMultiplier = _positionMultiplier;
	return copy;
}

#pragma mark Equality

-(BOOL) isEqualToBehavior:(KKNodeBehavior*)behavior
{
	if ([self isMemberOfClass:[behavior class]] == NO)
		return NO;
	
	KKFollowTargetBehavior* synchPosBehavior = (KKFollowTargetBehavior*)behavior;
	return (synchPosBehavior.target == _target &&
			CGPointEqualToPoint(synchPosBehavior.positionOffset, _positionOffset) &&
			CGPointEqualToPoint(synchPosBehavior.positionMultiplier, _positionMultiplier));
}
@end
