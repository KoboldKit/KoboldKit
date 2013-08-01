//
//  KKLimitVelocityBehavior.m
//  KoboldKit
//
//  Created by Steffen Itterheim on 04.07.13.
//  Copyright (c) 2013 Steffen Itterheim. All rights reserved.
//

#import "KKLimitVelocityBehavior.h"
#import "CGPointExtension.h"

@implementation KKLimitVelocityBehavior

+(id) limitVelocity:(CGFloat)velocityLimit
{
	return [[self alloc] initWithVelocityLimit:velocityLimit angularVelocityLimit:0.0];
}

+(id) limitVelocity:(CGFloat)velocityLimit limitAngularVelocity:(CGFloat)angularVelocityLimit
{
	return [[self alloc] initWithVelocityLimit:velocityLimit angularVelocityLimit:angularVelocityLimit];
}

+(id) limitAngularVelocity:(CGFloat)angularVelocityLimit
{
	return [[self alloc] initWithVelocityLimit:0.0 angularVelocityLimit:angularVelocityLimit];
}

-(id) initWithVelocityLimit:(CGFloat)velocityLimit angularVelocityLimit:(CGFloat)angularVelocityLimit
{
	self = [super init];
	if (self)
	{
		_velocityLimit = velocityLimit;
		_angularVelocityLimit = angularVelocityLimit;
	}
	return self;
}

-(void) didJoinController
{
	[self.node.kkScene addSceneEventsObserver:self];
}

-(void) didLeaveController
{
	[self.node.kkScene removeSceneEventsObserver:self];
}

-(void) didEvaluateActions
{
	SKPhysicsBody* physicsBody = self.node.physicsBody;
	if (physicsBody)
	{
		if (_velocityLimit != 0.0)
		{
			CGPoint velocity = physicsBody.velocity;
			CGFloat speed = ccpLengthSQ(velocity);
			if (speed > (_velocityLimit * _velocityLimit))
			{
				CGPoint cappedVelocity = ccpMult(ccpNormalize(velocity), _velocityLimit);
				physicsBody.velocity = cappedVelocity;
			}
		}
		
		if (_angularVelocityLimit != 0.0)
		{
			CGFloat angularVelocity = physicsBody.angularVelocity;
			angularVelocity = MAX(angularVelocity, -_angularVelocityLimit);
			angularVelocity = MIN(angularVelocity, _angularVelocityLimit);
			physicsBody.angularVelocity = angularVelocity;
		}
	}
}

#pragma mark !! Update methods below whenever class layout changes !!
#pragma mark NSCoding

static NSString* const ArchiveKeyForOtherNode = @"otherNode";

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
	KKLimitVelocityBehavior* copy = [[super copyWithZone:zone] init];
	copy->_velocityLimit = _velocityLimit;
	copy->_angularVelocityLimit = _angularVelocityLimit;
	return copy;
}

#pragma mark Equality

-(BOOL) isEqualToBehavior:(KKBehavior*)behavior
{
	if ([self isMemberOfClass:[behavior class]] == NO)
		return NO;
	return NO;
}

@end
