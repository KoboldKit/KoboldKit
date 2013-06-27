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
#import "KKNode.h"
#import "CGPointExtension.h"

@implementation SKNode (KoboldKit)

#pragma mark Scene

@dynamic kkScene;
-(KKScene*) kkScene
{
	NSAssert1(self.scene == nil || [self.scene isKindOfClass:[KKScene class]], @"scene (%@) is not a KKScene object", self.scene);
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

-(void) pauseOrResumeControllersInNodeTree:(SKNode*)rootNode pause:(BOOL)pause
{
	[rootNode enumerateChildNodesWithName:@"//*" usingBlock:^(SKNode *node, BOOL *stop)
	{
		 KKNodeController* controller = node.controller;
		 if (controller)
		 {
			 controller.paused = pause;
		 }
	}];
}

-(void) pauseControllersInNodeTree:(SKNode*)rootNode
{
	[self pauseOrResumeControllersInNodeTree:rootNode pause:YES];
}

-(void) resumeControllersInNodeTree:(SKNode*)rootNode
{
	[self pauseOrResumeControllersInNodeTree:rootNode pause:NO];
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

#pragma mark Perform Selector

-(void) performSelector:(SEL)aSelector afterDelay:(NSTimeInterval)delay
{
	[self performSelector:aSelector withObject:self afterDelay:delay];
}

-(void) performSelectorInBackground:(SEL)aSelector
{
	[self performSelectorInBackground:aSelector withObject:self];
}

#pragma mark Notifications

-(void) observeNotification:(NSString*)notificationName selector:(SEL)notificationSelector
{
	[[NSNotificationCenter defaultCenter] addObserver:self selector:notificationSelector name:notificationName object:nil];
}
-(void) observeNotification:(NSString*)notificationName selector:(SEL)notificationSelector object:(id)notificationSender
{
	[[NSNotificationCenter defaultCenter] addObserver:self selector:notificationSelector name:notificationName object:notificationSender];
}
-(void) disregardNotification:(NSString*)notificationName
{
	[[NSNotificationCenter defaultCenter] removeObserver:self name:notificationName object:nil];
}
-(void) disregardNotification:(NSString*)notificationName object:(id)notificationSender
{
	[[NSNotificationCenter defaultCenter] removeObserver:self name:notificationName object:notificationSender];
}
-(void) disregardAllNotifications
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark Scene Events

-(void) observeSceneEvents
{
	[self.kkScene addSceneEventsObserver:self];
}

-(void) disregardSceneEvents
{
	[self.kkScene removeSceneEventsObserver:self];
}

#pragma mark Input Events

-(void) observeInputEvents
{
	[self.kkScene addInputEventsObserver:self];
}

-(void) disregardInputEvents
{
	[self.kkScene removeInputEventsObserver:self];
}

#pragma mark Node Tree

-(void) didMoveToParent
{
	// to be overridden by subclasses
}

-(void) willMoveFromParent
{
	// to be overridden by subclasses
}

#pragma mark Position

-(void) centerOnNode:(SKNode*)node
{
    CGPoint cameraPositionInScene = [node.scene convertPoint:node.position fromNode:node.parent];
    node.parent.position = CGPointMake(node.parent.position.x - cameraPositionInScene.x,
                                       node.parent.position.y - cameraPositionInScene.y);
}

#pragma mark Physics

-(SKPhysicsBody*) physicsBodyWithEdgeChainFromPath:(CGPathRef)path
{
	SKPhysicsBody* physicsBody = [SKPhysicsBody bodyWithEdgeChainFromPath:path];
	self.physicsBody = physicsBody;

#if DEBUG
	SKShapeNode* shape = [SKShapeNode node];
	shape.path = path;
	shape.antialiased = NO;
	shape.lineWidth = 2.0;
	shape.fillColor = [SKColor colorWithRed:200 green:0 blue:80 alpha:0.2];
	[self addChild:shape];
#endif
	
	return physicsBody;
}

-(SKPhysicsBody*) physicsBodyWithRectangleOfSize:(CGSize)size
{
	SKPhysicsBody* physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:size];
	self.physicsBody = physicsBody;
	
#if DEBUG
	SKShapeNode* shape = [SKShapeNode node];
	shape.path = CGPathCreateWithRect(CGRectMake(-size.width / 2.0, -size.height / 2.0, size.width, size.height), nil);
	shape.antialiased = NO;
	shape.lineWidth = 2.0;
	shape.fillColor = [SKColor colorWithRed:200 green:0 blue:80 alpha:0.2];
	[self addChild:shape];
#endif
	
	return physicsBody;
}

#pragma mark !! Update methods below whenever class layout changes !!
#pragma mark NSCoding

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

	if ((self.controller != nil || node.controller != nil) &&
		[self.controller isEqualToController:node.controller] == NO)
	{
		NSLog(@"Node Controller mismatch: %@ != %@", self.controller, node.controller);
		return NO;
	}
	
#pragma message "TODO: compare userData in isEqual"

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
	if (((self.name != nil || node.name != nil) &&
		 [self.name isEqualToString:node.name] == NO))
		return NO;
	
	return YES;
}

@end


#pragma mark SK*Node Categories

@implementation SKCropNode (KoboldKit)
@end
@implementation SKEffectNode (KoboldKit)
@end
@implementation SKEmitterNode (KoboldKit)
@end
@implementation SKLabelNode (KoboldKit)
@end
@implementation SKShapeNode (KoboldKit)
@end
@implementation SKSpriteNode (KoboldKit)
@end
@implementation SKVideoNode (KoboldKit)
@end
