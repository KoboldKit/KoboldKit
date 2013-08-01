//
//  KKNodeShared.m
//  KoboldKit
//
//  Created by Steffen Itterheim on 01.08.13.
//  Copyright (c) 2013 Steffen Itterheim. All rights reserved.
//

#import "KKNodeShared.h"
#import "SKNode+KoboldKit.h"
#import "KKNodeController.h"
#import "KKScene.h"

@implementation KKNodeShared

+(void) deallocWithNode:(SKNode*)node
{
	[node removeController];
}

+(void) removeFromParentWithNode:(SKNode*)node
{
	[node willMoveFromParent];
}

+(void) sendChildrenWillMoveFromParentWithNode:(SKNode*)node
{
	for (SKNode* child in node.children)
	{
		[child willMoveFromParent];
	}
}

+(void) didMoveToParentWithNode:(SKNode*)node
{
	[node didMoveToParent];
}

+(void) willMoveFromParentWithNode:(SKNode*)node
{
	[node willMoveFromParent];
}

@end
