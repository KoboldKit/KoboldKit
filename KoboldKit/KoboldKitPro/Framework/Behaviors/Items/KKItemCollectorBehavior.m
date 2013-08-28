/*
 * Copyright (c) 2013 Steffen Itterheim.
 * Released under a PROPRIETARY License:
 * KoboldKit/KoboldKitPro/KoboldKitPro.License.txt
 */

#import "KKItemCollectorBehavior.h"
#import "KKPickupItemBehavior.h"
#import "KKModel.h"
#import "KKMutableNumber.h"
#import "KKNotifyOnItemCountBehavior.h"
#import "KKExternals.h"

@implementation KKItemCollectorBehavior

-(void) didPickUpItem:(KKPickupItemBehavior*)itemBehavior
{
	[[OALSimpleAudio sharedInstance] playEffect:@"pickup.wav"];

	// by default counts the number of item pickups
	NSString* itemName = itemBehavior.node.name;
	if (itemName.length)
	{
		KKModel* model = self.controller.model;
		KKMutableNumber* itemCountNumber = [model objectForKey:itemName];
		
		unsigned int itemCount = 1;
		if (itemCountNumber)
		{
			itemCount = itemCountNumber.unsignedIntValue + 1;
			[itemCountNumber setUnsignedIntValue:itemCount];
		}
		else
		{
			[model setUnsignedInt32:itemCount forKey:itemName];
		}

		Class itemCountBehaviorClass = [KKNotifyOnItemCountBehavior class];
		for (KKBehavior* behavior in self.controller.behaviors)
		{
			if ([behavior isKindOfClass:itemCountBehaviorClass])
			{
				KKNotifyOnItemCountBehavior* itemCountBehavior = (KKNotifyOnItemCountBehavior*)behavior;
				[itemCountBehavior didPickUpItemWithName:itemName count:itemCount];
			}
		}
	}
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
