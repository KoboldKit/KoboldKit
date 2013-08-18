//
//  KKViewOriginNode.m
//  KoboldKit
//
//  Created by Steffen Itterheim on 26.06.13.
//  Copyright (c) 2013 Steffen Itterheim. All rights reserved.
//

#import "KKViewOriginNode.h"
#import "KKScene.h"
#import "SKNode+KoboldKit.h"

@implementation KKViewOriginNode

-(void) didMoveToParent
{
	[super didMoveToParent];
	
	NSAssert([self.parent isKindOfClass:[KKScene class]], @"KKViewAnchorNode must be a direct child of a KKScene instance");
	[self updatePositionFromSceneFrame];
}

-(void) updatePositionFromSceneFrame
{
	self.position = self.scene.frame.origin;
}

@end
