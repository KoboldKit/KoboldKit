//
//  KKCameraFollowsBehavior.m
//  KoboldKit
//
//  Created by Steffen Itterheim on 22.06.13.
//  Copyright (c) 2013 Steffen Itterheim. All rights reserved.
//

#import "KKCameraFollowsBehavior.h"
#import "SKNode+KoboldKit.h"

@implementation KKCameraFollowsBehavior

-(void) didJoinController
{
	_wantsUpdate = YES;
}

-(void) didLeaveController
{
}

-(void) didSimulatePhysics
{
	[super didSimulatePhysics];
	
	SKNode* selfNode = self.node;
	[selfNode.scene centerOnNode:selfNode];
}

@end
