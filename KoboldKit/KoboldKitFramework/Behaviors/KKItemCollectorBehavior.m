//
//  KKItemCollectorBehavior.m
//  KoboldKit
//
//  Created by Steffen Itterheim on 01.08.13.
//  Copyright (c) 2013 Steffen Itterheim. All rights reserved.
//

#import "KKItemCollectorBehavior.h"
#import "KKPickupItemBehavior.h"
#import "KKModel.h"
#import "KKMutableNumber.h"

@implementation KKItemCollectorBehavior

-(void) didPickUpItem:(KKPickupItemBehavior*)itemBehavior
{
	// by default counts the number of item pickups
	NSString* itemName = itemBehavior.name;
	if (itemName.length)
	{
		KKModel* model = self.controller.model;
		KKMutableNumber* count = [model objectForKey:itemName];
		if (count)
		{
			[count setUnsignedIntValue:count.unsignedIntValue + 1];
		}
		else
		{
			[model setUnsignedInt32:1 forKey:itemName];
		}
		
		LOG_EXPR([[model objectForKey:itemName] unsignedIntValue]);
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
