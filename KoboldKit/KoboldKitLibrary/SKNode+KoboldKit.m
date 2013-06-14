//
//  SKNode+KoboldKit.m
//  KoboldKitDemo
//
//  Created by Steffen Itterheim on 13.06.13.
//  Copyright (c) 2013 Steffen Itterheim. All rights reserved.
//

#import "SKNode+KoboldKit.h"
#import "KKNodeController.h"
#import "KKNodeBehavior.h"
#import "KKScene.h"

@implementation SKNode (KoboldKit)

#pragma mark Scene

@dynamic kkScene;
-(KKScene*) kkScene
{
	NSAssert1([self.scene isKindOfClass:[KKScene class]], @"scene (%@) is not a KKScene object", self.scene);
	return (KKScene*)self.scene;
}

#pragma mark Controller

@dynamic controller;
-(KKNodeController*) controller
{
	return (KKNodeController*)[self.userData objectForKey:KKNodeControllerUserDataKey];
}

-(void) setController:(KKNodeController*)controller
{
	if (controller == nil)
	{
		[self.userData removeObjectForKey:KKNodeControllerUserDataKey];
		[self.kkScene unregisterController:controller];
	}
	else
	{
		if (self.userData == nil)
		{
			self.userData = [NSMutableDictionary dictionaryWithObject:controller forKey:KKNodeControllerUserDataKey];
		}
		else
		{
			[self.userData setObject:controller forKey:KKNodeControllerUserDataKey];
		}

		controller.node = self;
		[self.kkScene registerController:controller];
	}
}

-(KKNodeController*) createController
{
	KKNodeController* controller = self.controller;
	if (controller == nil)
	{
		controller = [KKNodeController new];
		[self setController:controller];
	}
	return controller;
}

#pragma mark Behaviors

-(void) addBehavior:(KKNodeBehavior*)behavior
{
	[[self createController] addBehavior:behavior];
}

-(void) addBehavior:(KKNodeBehavior*)behavior withKey:(NSString*)key
{
	[[self createController] addBehavior:behavior withKey:key];
}

-(void) addBehaviors:(NSArray*)behaviors
{
	[[self createController] addBehaviors:behaviors];
}

-(KKNodeBehavior*) behaviorForKey:(NSString*)key
{
	return [[self createController] behaviorForKey:key];
}

-(BOOL) hasBehaviors
{
	return [[self createController] hasBehaviors];
}

-(void) removeBehavior:(KKNodeBehavior*)behavior
{
	[[self createController] removeBehavior:behavior];
}

-(void) removeBehaviorForKey:(NSString*)key
{
	[[self createController] removeBehaviorForKey:key];
}

-(void) removeAllBehaviors
{
	[[self createController] removeAllBehaviors];
}

#pragma mark Position

-(void) centerOnNode:(SKNode*)node
{
    CGPoint cameraPositionInScene = [node.scene convertPoint:node.position fromNode:node.parent];
    node.parent.position = CGPointMake(node.parent.position.x - cameraPositionInScene.x,
                                       node.parent.position.y - cameraPositionInScene.y);
}

#pragma mark Description

-(NSString*) kkDescription
{
	return [SKNode descriptionForNode:self];
}

+(NSString*) descriptionForNode:(SKNode*)node
{
	return [NSString stringWithFormat:@"%@ controller:%@ behaviors:%@", [node kkDescription], node.controller, node.controller.behaviors];
}

#pragma mark NSCopying

-(instancetype) kkCopyWithZone:(NSZone*)zone
{
	// call original implementation - if this look wrong to you, read up on Method Swizzling: http://www.cocoadev.com/index.pl?MethodSwizzling)
	SKNode* copy = [self kkCopyWithZone:zone];
	
	// if the node contains controllers make sure their copies reference the copied node
	KKNodeController* controller = copy.controller;
	NSAssert2(controller && self.controller || controller == nil && self.controller == nil, @"controller (%@) of node (%@) was not copied!", self.controller, self);
	if (controller)
	{
		controller.node = copy;
		for (KKNodeBehavior* behavior in controller.behaviors)
		{
			behavior.controller = copy.controller;
			behavior.node = copy;
		}
	}
	
	return copy;
}

#pragma mark Equality

-(BOOL) isEqualToNode:(SKNode*)node
{
	return [self isEqualToNode:node recursive:NO];
}

-(BOOL) isEqualToNodeTree:(SKNode*)node
{
	return [self isEqualToNode:node recursive:YES];
}

-(BOOL) isEqualToNode:(SKNode*)node recursive:(BOOL)recursive
{
	if ([self isEqualToNodeProperties:node] == NO)
	{
		NSLog(@"Node Properties mismatch: %@ != %@", self, node);
		return NO;
	}

	if ([self.controller isEqualToController:node.controller] == NO)
	{
		NSLog(@"Node Controller/Behavior mismatch: %@ (%@) != %@ (%@)", self, self.controller, node, node.controller);
		return NO;
	}

	if (recursive)
	{
		NSUInteger childrenCount = self.children.count;
		if (childrenCount != node.children.count)
			return NO;

		for (NSUInteger i = 0; i < childrenCount; i++)
		{
			SKNode* selfChild = [self.children objectAtIndex:i];
			SKNode* nodeChild = [node.children objectAtIndex:i];
			
			if ([selfChild isEqualToNode:nodeChild recursive:YES] == NO)
				return NO;
		}
	}
	
	return YES;
}

-(BOOL) isEqualToNodeProperties:(SKNode*)node
{
	if (CGRectEqualToRect(self.frame, node.frame) == NO)
		return NO;
	if (CGPointEqualToPoint(self.position, node.position) == NO)
		return NO;
	if (CGFloatEqualToFloat(self.zPosition, node.zPosition) == NO)
		return NO;
	if (CGFloatEqualToFloat(self.xScale, node.xScale) == NO)
		return NO;
	if (CGFloatEqualToFloat(self.yScale, node.yScale) == NO)
		return NO;
	if (CGFloatEqualToFloat(self.zRotation, node.zRotation) == NO)
		return NO;
	if (CGFloatEqualToFloat(self.alpha, node.alpha) == NO)
		return NO;
	if (CGFloatEqualToFloat(self.speed, node.speed) == NO)
		return NO;
	if (self.hidden != node.hidden)
		return NO;
	if (self.paused != node.paused)
		return NO;
	if (self.userInteractionEnabled != node.userInteractionEnabled)
		return NO;
	if ((self.name && [self.name isEqualToString:node.name] == NO))
		return NO;
	
	return YES;
}

@end


#pragma mark SK*Node Categories

@implementation SKCropNode (KoboldKit)
-(NSString*) kkDescription
{
	return [SKNode descriptionForNode:self];
}
@end
@implementation SKEffectNode (KoboldKit)
-(NSString*) kkDescription
{
	return [SKNode descriptionForNode:self];
}
@end
@implementation SKEmitterNode (KoboldKit)
-(NSString*) kkDescription
{
	return [SKNode descriptionForNode:self];
}
@end
@implementation SKLabelNode (KoboldKit)
-(NSString*) kkDescription
{
	return [SKNode descriptionForNode:self];
}
@end
@implementation SKScene (KoboldKit)
-(NSString*) kkDescription
{
	return [SKNode descriptionForNode:self];
}
@end
@implementation SKShapeNode (KoboldKit)
-(NSString*) kkDescription
{
	return [SKNode descriptionForNode:self];
}
@end
@implementation SKSpriteNode (KoboldKit)
-(NSString*) kkDescription
{
	return [SKNode descriptionForNode:self];
}
@end
@implementation SKVideoNode (KoboldKit)
-(NSString*) kkDescription
{
	return [SKNode descriptionForNode:self];
}
@end
