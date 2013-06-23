//
//  KKCameraFollowsBehavior.m
//  KoboldKit
//
//  Created by Steffen Itterheim on 22.06.13.
//  Copyright (c) 2013 Steffen Itterheim. All rights reserved.
//

#import "KKCameraFollowBehavior.h"
#import "SKNode+KoboldKit.h"

@implementation KKCameraFollowBehavior

-(void) didJoinController
{
	_wantsUpdate = YES;
	
	// update once immediately
	[self didSimulatePhysics];
}

-(void) didLeaveController
{
}

-(void) didSimulatePhysics
{
	SKNode* node = self.node;
	SKNode* parent = node.parent;
	CGPoint cameraPositionInScene = [node.scene convertPoint:node.position fromNode:parent];
	CGPoint pos = CGPointMake(parent.position.x - cameraPositionInScene.x,
							  parent.position.y - cameraPositionInScene.y);
	parent.position = pos;
}

#pragma mark !! Update methods below whenever class layout changes !!
#pragma mark NSCoding


#pragma mark NSCopying


#pragma mark Equality


@end
