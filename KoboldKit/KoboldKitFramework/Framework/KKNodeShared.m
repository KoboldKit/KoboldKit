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
	NSLog(@"dealloc: %@", node);
	[node removeController];
}

+(void) sendChildrenWillMoveFromParentWithNode:(SKNode*)node
{
	for (SKNode* child in node.children)
	{
		[child willMoveFromParent];
		[child.controller nodeWillMoveFromParent];
	}
}

+(void) didMoveToParentWithNode:(SKNode*)node
{
	[node didMoveToParent];
	[node.controller nodeDidMoveToParent];
}

+(void) willMoveFromParentWithNode:(SKNode*)node
{
	[node willMoveFromParent];
	[node.controller nodeWillMoveFromParent];
}

@end
