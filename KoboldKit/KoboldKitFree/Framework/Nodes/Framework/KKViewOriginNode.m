/*
 * Copyright (c) 2013 Steffen Itterheim.
 * Released under the MIT License:
 * KoboldAid/licenses/KoboldKitFree.License.txt
 */


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
