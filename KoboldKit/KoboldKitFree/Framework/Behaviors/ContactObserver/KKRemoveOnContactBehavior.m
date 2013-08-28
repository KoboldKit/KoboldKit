/*
 * Copyright (c) 2013 Steffen Itterheim.
 * Released under the MIT License:
 * KoboldAid/licenses/KoboldKitFree.License.txt
 */


#import "KKRemoveOnContactBehavior.h"
#import "SKNode+KoboldKit.h"
#import "KKScene.h"

@implementation KKRemoveOnContactBehavior

-(void) didBeginContact:(SKPhysicsContact *)contact otherBody:(SKPhysicsBody *)otherBody
{
	[self.node removeFromParent];
}

#pragma mark !! Update methods below whenever class layout changes !!
#pragma mark NSCoding

/*
static NSString* const ArchiveKeyForOtherNode = @"otherNode";

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
*/

@end
