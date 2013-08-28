/*
 * Copyright (c) 2013 Steffen Itterheim.
 * Released under a PROPRIETARY License:
 * KoboldKit/KoboldKitPro/KoboldKitPro.License.txt
 */


#import "KKPickupItemBehavior.h"
#import "KKItemCollectorBehavior.h"

@implementation KKPickupItemBehavior

-(void) didBeginContact:(SKPhysicsContact *)contact otherBody:(SKPhysicsBody *)otherBody
{
	// inform the other party about the pick up
	SKNode* otherNode = otherBody.node;
	
	KKItemCollectorBehavior* collectorBehavior = [otherNode behaviorKindOfClass:[KKItemCollectorBehavior class]];
	[collectorBehavior didPickUpItem:self];
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
 */
 #pragma mark NSCopying

/*
-(id) copyWithZone:(NSZone*)zone
{
	KKPickupItemBehavior* copy = [[super copyWithZone:zone] init];
	return copy;
}
*/

 #pragma mark Equality

/*
 -(BOOL) isEqualToBehavior:(KKBehavior*)behavior
 {
 if ([self isMemberOfClass:[behavior class]] == NO)
 return NO;
 return NO;
 }
*/
@end
