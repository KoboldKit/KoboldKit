/*
 * Copyright (c) 2013 Steffen Itterheim.
 * Released under the MIT License:
 * KoboldAid/licenses/KoboldKitFree.License.txt
 */


#import "SKNode+KoboldKit.h"
#import "KKNodeController.h"
#import "KKBehavior.h"
#import "KKScene.h"
#import "KKNode.h"
#import "KKMacros.h"
#import "KKView.h"
#import "KKTilemapObject.h"

#import "SKAction+KoboldKit.h"
#import "SKColor+KoboldKit.h"

@implementation SKNode (KoboldKit)

#pragma mark Properties

@dynamic kkScene;
-(KKScene*) kkScene
{
	NSAssert(self.scene, @"self.scene property is (still) nil. The scene property is only valid after the node has been added as child to another node.");
	NSAssert1([self.scene isKindOfClass:[KKScene class]], @"scene (%@) is not a KKScene object", self.scene);
	return (KKScene*)self.scene;
}

@dynamic model, info;
-(KKModel*) model
{
	return self.controller.model;
}
-(KKModel*) info
{
	return self.controller.model;
}

#pragma mark KVC

-(id) valueForUndefinedKey:(NSString*)key
{
	// assume undefined keys to refer to behaviors by key
	return [self.controller behaviorForKey:key];
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
		[self.controller willRemoveController];
		[self.userData removeObjectForKey:KKNodeControllerUserDataKey];
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

-(void) removeController
{
	[self setController:nil];
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

-(void) addBehavior:(KKBehavior*)behavior
{
	[[self createController] addBehavior:behavior];
}

-(void) addBehavior:(KKBehavior*)behavior withKey:(NSString*)key
{
	[[self createController] addBehavior:behavior withKey:key];
}

-(void) addBehaviors:(NSArray*)behaviors
{
	[[self createController] addBehaviors:behaviors];
}

-(id) behaviorForKey:(NSString*)key
{
	return [self.controller behaviorForKey:key];
}

-(id) behaviorKindOfClass:(Class)behaviorClass
{
	return [self.controller behaviorKindOfClass:behaviorClass];
}

-(id) behaviorMemberOfClass:(Class)behaviorClass
{
	return [self.controller behaviorMemberOfClass:behaviorClass];
}

-(BOOL) hasBehaviors
{
	return [self.controller hasBehaviors];
}

-(void) removeBehavior:(KKBehavior*)behavior
{
	[self.controller removeBehavior:behavior];
}

-(void) removeBehaviorForKey:(NSString*)key
{
	[self.controller removeBehaviorForKey:key];
}

-(void) removeBehaviorWithClass:(Class)behaviorClass
{
	[self.controller removeBehaviorWithClass:behaviorClass];
}

-(void) removeAllBehaviors
{
	[self.controller removeAllBehaviors];
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

#pragma mark Physics Events

-(void) observePhysicsContactEvents
{
	[self.kkScene addPhysicsContactEventsObserver:self];
}

-(void) disregardPhysicsContactEvents
{
	[self.kkScene removePhysicsContactEventsObserver:self];
}

#pragma mark Node Tree

-(void) didMoveToParent
{
	// to be overridden by subclasses
	if ([KKView showsNodeFrames])
	{
		SKShapeNode* shape = [SKShapeNode node];
		CGPathRef path = CGPathCreateWithRect(self.frame, nil);
		shape.path = path;
		CGPathRelease(path);
		shape.antialiased = NO;
		shape.lineWidth = 1.0;
		shape.strokeColor = [SKColor orangeColor];
		[self addChild:shape];
	}
    
	if ([KKView showsNodeAnchorPoints])
	{
		SKShapeNode* shape = [SKShapeNode node];
		CGRect center = CGRectMake(-1, -1, 2, 2);
		CGPathRef path = CGPathCreateWithRect(center, nil);
		shape.path = path;
		CGPathRelease(path);

		shape.antialiased = NO;
		shape.lineWidth = 1.0;
		[self addChild:shape];
		
        SKAction *sequence = [SKAction afterDelay:0.2 runBlock:^{
            shape.strokeColor = [SKColor randomColor];
        }];
		[shape runAction:[SKAction repeatActionForever:sequence]];
	}
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

-(void) addPhysicsBodyDrawNodeWithPath:(CGPathRef)path
{
	if ([KKView showsPhysicsShapes])
	{
		SKShapeNode* shape = [SKShapeNode node];
		shape.path = path;
		shape.antialiased = NO;
		if (self.physicsBody.dynamic)
		{
			shape.lineWidth = 1.0;
			shape.fillColor = [SKColor colorWithRed:1 green:0 blue:0.2 alpha:0.2];
		}
		else
		{
			shape.lineWidth = 2.0;
			shape.glowWidth = 4.0;
			shape.strokeColor = [SKColor magentaColor];
		}
		[self addChild:shape];
	}
}

-(SKPhysicsBody*) physicsBodyWithEdgeLoopFromPath:(CGPathRef)path
{
	SKPhysicsBody* physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromPath:path];
	physicsBody.dynamic = NO;
	self.physicsBody = physicsBody;
	[self addPhysicsBodyDrawNodeWithPath:path];
	return physicsBody;
}

-(SKPhysicsBody*) physicsBodyWithEdgeChainFromPath:(CGPathRef)path
{
	SKPhysicsBody* physicsBody = [SKPhysicsBody bodyWithEdgeChainFromPath:path];
	physicsBody.dynamic = NO;
	self.physicsBody = physicsBody;
	[self addPhysicsBodyDrawNodeWithPath:path];
	return physicsBody;
}

-(SKPhysicsBody*) physicsBodyWithRectangleOfSize:(CGSize)size
{
	SKPhysicsBody* physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:size];
	self.physicsBody = physicsBody;
	CGPathRef path = CGPathCreateWithRect(CGRectMake(-(size.width * 0.5), -(size.height * 0.5), size.width, size.height), nil);
	[self addPhysicsBodyDrawNodeWithPath:path];
	CGPathRelease(path);
	return physicsBody;
}

-(SKPhysicsBody*) physicsBodyWithCircleOfRadius:(CGFloat)radius
{
	SKPhysicsBody* physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:radius];
	self.physicsBody = physicsBody;
	CGPathRef path = CGPathCreateWithEllipseInRect(self.frame, nil);
	[self addPhysicsBodyDrawNodeWithPath:path];
	CGPathRelease(path);
	return physicsBody;
}

-(SKPhysicsBody*) physicsBodyWithTilemapObject:(KKTilemapObject*)tilemapObject
{
	return [self physicsBodyWithRectangleOfSize:tilemapObject.size];
}

#pragma mark Sound

-(void) playSoundFileNamed:(NSString*)soundFile
{
	[self runAction:[SKAction playSoundFileNamed:soundFile waitForCompletion:NO]];
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
		for (KKBehavior* behavior in controller.behaviors)
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
	
DEVELOPER_TODO("compare userData in isEqual")

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

@implementation SKSpriteNode (KoboldKit)
@dynamic imageName;
-(void) setImageName:(NSString *)imageName
{
DEVELOPER_FIXME("only works with Jetpack atlas atm")
	SKTexture* texture = [[SKTextureAtlas atlasNamed:@"Jetpack"] textureNamed:imageName];
	self.texture = texture;
	self.size = texture.size;
}
-(NSString*) imageName
{
	return nil;
}
@end

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
@implementation SKVideoNode (KoboldKit)
@end
