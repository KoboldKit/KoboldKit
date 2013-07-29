//
//  KKNode+Related.m
//  KoboldKit
//
//  Created by Steffen Itterheim on 18.06.13.
//  Copyright (c) 2013 Steffen Itterheim. All rights reserved.
//

#import "KKNode.h"
#import "SKNode+KoboldKit.h"
#import "KKNodeController.h"
#import "KKBehavior.h"

@implementation KKNode
+(void) sendChildrenWillMoveFromParentWithNode:(SKNode*)node
{
	for (SKNode* child in node.children)
	{
		[child willMoveFromParent];
	}
}

#pragma mark Add/Remove Child Override
-(void) addChild:(SKNode*)node
{
	[super addChild:node];
	[node didMoveToParent];
}
-(void) insertChild:(SKNode*)node atIndex:(NSInteger)index
{
	[super insertChild:node atIndex:index];
	[node didMoveToParent];
}
-(void) removeFromParent
{
	[self willMoveFromParent];
	[super removeFromParent];
}
-(void) removeAllChildren
{
	[KKNode sendChildrenWillMoveFromParentWithNode:self];
	[super removeAllChildren];
}
-(void) removeChildrenInArray:(NSArray*)array
{
	[KKNode sendChildrenWillMoveFromParentWithNode:self];
	[super removeChildrenInArray:array];
}

#pragma mark Description

-(NSString*) description
{
	return [NSString stringWithFormat:@"%@ controller:%@ behaviors:%@", [super description], self.controller, self.controller.behaviors];
}

#pragma mark !! Update methods below whenever class layout changes !!
#pragma mark NSCoding

#pragma mark NSCopying

-(instancetype) copyWithZone:(NSZone*)zone
{
	// call original implementation - if this look wrong to you, read up on Method Swizzling: http://www.cocoadev.com/index.pl?MethodSwizzling)
	KKNode* copy = [super copyWithZone:zone];
	
	// if the node contains controllers make sure their copies reference the copied node
	KKNodeController* controller = copy.controller;
	NSAssert2(controller && self.controller || controller == nil && self.controller == nil, @"controller (%@) of node (%@) was not copied!", self.controller, self);
	if (controller)
	{
		controller.node = copy;
		for (KKBehavior* behavior in controller.behaviors)
		{
			behavior.controller = copy.controller;
			behavior.node = copy;
		}
	}
	
	return copy;
}

@end
