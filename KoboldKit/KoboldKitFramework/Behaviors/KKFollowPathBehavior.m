//
//  KKFollowPathBehavior.m
//  KoboldKit
//
//  Created by Steffen Itterheim on 04.08.13.
//  Copyright (c) 2013 Steffen Itterheim. All rights reserved.
//

#import "KKFollowPathBehavior.h"
#import "KKTilemapObjectLayerNode.h"

@implementation KKFollowPathBehavior

-(void) didJoinController
{
	// assume the parent to be the object layer
	KKTilemapObjectLayerNode* objectLayerNode = (KKTilemapObjectLayerNode*)self.node.parent;
	NSAssert2([objectLayerNode isKindOfClass:[KKTilemapObjectLayerNode class]],
			  @"behavior node's parent isn't a KKTilemapObjectLayerNode but a %@ (%@)",
			  NSStringFromClass([objectLayerNode class]), objectLayerNode);
	
}

-(void) didLeaveController
{
	
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

-(id) copyWithZone:(NSZone*)zone
{
	KKFollowPathBehavior* copy = [[super copyWithZone:zone] init];
	copy->_pathName = [_pathName copy];
	copy->_moveSpeed = _moveSpeed;
	return copy;
}

/*
 #pragma mark Equality
 
 -(BOOL) isEqualToBehavior:(KKBehavior*)behavior
 {
 if ([self isMemberOfClass:[behavior class]] == NO)
 return NO;
 return NO;
 }
 */

@end
