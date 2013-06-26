//
//  KKViewOriginNode.m
//  KoboldKit
//
//  Created by Steffen Itterheim on 26.06.13.
//  Copyright (c) 2013 Steffen Itterheim. All rights reserved.
//

#import "KKViewAnchorNode.h"

@implementation KKViewAnchorNode

-(void) didMoveToParent
{
	[self updatePositionFromSceneFrame];
}

-(void) updatePositionFromSceneFrame
{
	self.position = self.scene.frame.origin;
}

@end
