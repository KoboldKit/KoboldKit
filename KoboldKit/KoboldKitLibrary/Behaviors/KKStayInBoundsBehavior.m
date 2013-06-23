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
		_wantsUpdate = YES;
	}
	return self;
}

-(void) didJoinController
{
	// update once immediately
	[self didSimulatePhysics];
}

-(void) didSimulatePhysics
{
	SKNode* node = self.node;
	CGPoint pos = node.position;
	
	// keep camera within defined borders
	if (_bounds.origin.x != INFINITY && _bounds.size.width != INFINITY)
	{
		pos.x = MIN(pos.x, _bounds.origin.x + _bounds.size.width);
		pos.x = MAX(pos.x, _bounds.origin.x);
	}
	
	if (_bounds.origin.y != INFINITY && _bounds.size.height != INFINITY)
	{
		pos.y = MIN(pos.y, _bounds.origin.y + _bounds.size.height);
		pos.y = MAX(pos.y, _bounds.origin.y);
	}
	
	node.position = pos;
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
