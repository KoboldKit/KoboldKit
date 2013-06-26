//
//  KKScene.m
//  KoboldKitDemo
//
//  Created by Steffen Itterheim on 13.06.13.
//  Copyright (c) 2013 Steffen Itterheim. All rights reserved.
//

#import "KKScene.h"
#import "KKNode.h"
#import "KKNodeController.h"
#import "SKNode+KoboldKit.h"
#import "KKViewAnchorNode.h"

@implementation KKScene

#pragma mark Init / Dealloc

-(id) initWithSize:(CGSize)size
{
	self = [super initWithSize:size];
	if (self)
	{
		[self initDefaults];
	}
	return self;
}

-(id) init
{
	self = [super init];
	if (self)
	{
		[self initDefaults];
	}
	return self;
}

-(void) initDefaults
{
	self.physicsWorld.contactDelegate = self;
	
	const NSUInteger kInitialCapacity = 8;
	_controllers = [NSMutableArray arrayWithCapacity:kInitialCapacity];
	_inputObservers = [NSMutableArray arrayWithCapacity:kInitialCapacity];
	_sceneUpdateObservers = [NSMutableArray arrayWithCapacity:kInitialCapacity];
	_sceneDidUpdateBehaviorsObservers = [NSMutableArray arrayWithCapacity:kInitialCapacity];
	_sceneDidEvaluateActionsObservers = [NSMutableArray arrayWithCapacity:kInitialCapacity];
	_sceneDidSimulatePhysicsObservers = [NSMutableArray arrayWithCapacity:kInitialCapacity];
	_sceneWillMoveFromViewObservers = [NSMutableArray arrayWithCapacity:kInitialCapacity];
	_sceneDidMoveToViewObservers = [NSMutableArray arrayWithCapacity:kInitialCapacity];
	
	_mainLoopStage = KKMainLoopStageDidSimulatePhysics;
	
	NSLog(@"scene init");
}

-(void) dealloc
{
	NSLog(@"dealloc: %@", self);
	
	// make sure no node is still hooked into the notification center
	NSNotificationCenter* notificationCenter = [NSNotificationCenter defaultCenter];
	[self enumerateChildNodesWithName:@"//*" usingBlock:^(SKNode *node, BOOL *stop)
	{
		[notificationCenter removeObserver:node];
	}];
}

#pragma mark Controllers

-(void) registerController:(KKNodeController*)controller
{
	dispatch_async(dispatch_get_main_queue(), ^{
		if ([_controllers indexOfObject:controller] == NSNotFound)
		{
			[_controllers addObject:controller];
		}
	});
}

-(void) unregisterController:(KKNodeController*)controller
{
	dispatch_async(dispatch_get_main_queue(), ^{
		[_controllers removeObject:controller];
	});
}

#pragma mark Update

-(void) update:(NSTimeInterval)currentTime
{
	NSAssert(_mainLoopStage == KKMainLoopStageDidSimulatePhysics, @"Main Loop Error: it seems you implemented didSimulatePhysics but did not call [super didSimulatePhysics]");
	_mainLoopStage = KKMainLoopStageDidUpdate;
	
	++_frameCount;
	
	// update controllers
	for (KKNodeController* controller in _controllers)
	{
		if (controller.paused == NO)
		{
			[controller update:currentTime];
		}
	}

	for (id observer in _sceneUpdateObservers)
	{
		[observer update:currentTime];
	}
}

-(void) didEvaluateActions
{
	NSAssert(_mainLoopStage == KKMainLoopStageDidUpdate, @"Main Loop Error: it seems you implemented update: but did not call [super update:currentTime]");
	_mainLoopStage = KKMainLoopStageDidEvaluateActions;

	// update controllers
	for (KKNodeController* controller in _controllers)
	{
		if (controller.paused == NO)
		{
			[controller didEvaluateActions];
		}
	}

	for (id observer in _sceneDidEvaluateActionsObservers)
	{
		[observer didEvaluateActions];
	}
}

-(void) didSimulatePhysics
{
	NSAssert(_mainLoopStage == KKMainLoopStageDidEvaluateActions, @"Main Loop Error: it seems you implemented didEvaluateActions: but did not call [super didEvaluateActions]");
	_mainLoopStage = KKMainLoopStageDidSimulatePhysics;

	// update controllers
	for (KKNodeController* controller in _controllers)
	{
		if (controller.paused == NO)
		{
			[controller didSimulatePhysics];
		}
	}

	for (id observer in _sceneDidSimulatePhysicsObservers)
	{
		[observer didSimulatePhysics];
	}
}

-(void) willMoveFromView:(SKView *)view
{
	NSLog(@"willMoveFromView");

	for (id observer in _sceneWillMoveFromViewObservers)
	{
		[observer willMoveFromView:view];
	}
}

-(void) didMoveToView:(SKView *)view
{
	NSLog(@"didMoveToView");

	for (id observer in _sceneDidMoveToViewObservers)
	{
		[observer didMoveToView:view];
	}
}

-(void) didChangeSize:(CGSize)oldSize
{
	NSLog(@"didChangeSize");
	LOG_EXPR(self.size);
}

-(void) addSceneEventsObserver:(id)observer
{
	// prevent users from registering the scene, because it will always call these methods if implemented
	if (observer != self)
	{
		dispatch_async(dispatch_get_main_queue(), ^{
			if ([observer respondsToSelector:@selector(update:)] &&
				[_sceneUpdateObservers indexOfObject:observer] == NSNotFound)
			{
				[_sceneUpdateObservers addObject:observer];
			}
			if ([observer respondsToSelector:@selector(didUpdateBehaviors)] &&
				[_sceneDidUpdateBehaviorsObservers indexOfObject:observer] == NSNotFound)
			{
				[_sceneDidUpdateBehaviorsObservers addObject:observer];
			}
			if ([observer respondsToSelector:@selector(didEvaluateActions)] &&
				[_sceneDidEvaluateActionsObservers indexOfObject:observer] == NSNotFound)
			{
				[_sceneDidEvaluateActionsObservers addObject:observer];
			}
			if ([observer respondsToSelector:@selector(didSimulatePhysics)] &&
				[_sceneDidSimulatePhysicsObservers indexOfObject:observer] == NSNotFound)
			{
				[_sceneDidSimulatePhysicsObservers addObject:observer];
			}
			if ([observer respondsToSelector:@selector(willMoveFromView:)] &&
				[_sceneWillMoveFromViewObservers indexOfObject:observer] == NSNotFound)
			{
				[_sceneWillMoveFromViewObservers addObject:observer];
			}
			if ([observer respondsToSelector:@selector(didMoveToView:)] &&
				[_sceneDidMoveToViewObservers indexOfObject:observer] == NSNotFound)
			{
				[_sceneDidMoveToViewObservers addObject:observer];
			}
		});
	}
}

-(void) removeSceneEventsObserver:(id)observer
{
	dispatch_async(dispatch_get_main_queue(), ^{
		[_sceneUpdateObservers removeObject:observer];
		[_sceneDidUpdateBehaviorsObservers removeObject:observer];
		[_sceneDidEvaluateActionsObservers removeObject:observer];
		[_sceneDidSimulatePhysicsObservers removeObject:observer];
		[_sceneWillMoveFromViewObservers removeObject:observer];
		[_sceneDidMoveToViewObservers removeObject:observer];
    });
}

#pragma mark Input

-(void) addInputEventsObserver:(id)observer
{
	dispatch_async(dispatch_get_main_queue(), ^{
		if ([_inputObservers indexOfObject:observer] == NSNotFound)
		{
			[_inputObservers addObject:observer];
		}
    });
}

-(void) removeInputEventsObserver:(id)observer
{
	dispatch_async(dispatch_get_main_queue(), ^{
		[_inputObservers removeObject:observer];
    });
}

#pragma mark Touches

#if TARGET_OS_IPHONE
-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	for (id observer in _inputObservers)
	{
		if ([observer respondsToSelector:@selector(touchesBegan:withEvent:)])
		{
			[observer touchesBegan:touches withEvent:event];
		}
	}
}

-(void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	for (id observer in _inputObservers)
	{
		if ([observer respondsToSelector:@selector(touchesMoved:withEvent:)])
		{
			[observer touchesMoved:touches withEvent:event];
		}
	}
}

-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	for (id observer in _inputObservers)
	{
		if ([observer respondsToSelector:@selector(touchesEnded:withEvent:)])
		{
			[observer touchesEnded:touches withEvent:event];
		}
	}
}

-(void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	for (id observer in _inputObservers)
	{
		if ([observer respondsToSelector:@selector(touchesCancelled:withEvent:)])
		{
			[observer touchesCancelled:touches withEvent:event];
		}
	}
}
#endif

#pragma mark Physics Contact

-(void) didBeginContact:(SKPhysicsContact *)contact
{
	/*
	SKNode* nodeA = contact.bodyA.node;
	SKNode* nodeB = contact.bodyB.node;
	
	if ([nodeA respondsToSelector:@selector(didBeginContact:)])
	{
		[(SKNode<SKPhysicsContactDelegate>*)nodeA didBeginContact:contact];
	}
	if ([nodeB respondsToSelector:@selector(didBeginContact:)])
	{
		[(SKNode<SKPhysicsContactDelegate>*)nodeB didBeginContact:contact];
	}
	*/
}

-(void) didEndContact:(SKPhysicsContact *)contact
{
	
}

#pragma mark Debugging

-(NSString*) dumpSceneGraph:(KKSceneGraphDumpOptions)options
{
	NSMutableString* dump = [NSMutableString stringWithCapacity:4096];
	[dump appendString:@"\nDump of scene graph:\n"];
	[dump appendFormat:@"%@\n", self];
	
	[self enumerateChildNodesWithName:@"//*" usingBlock:^(SKNode *node, BOOL *stop) {
		[dump appendFormat:@"%@\n", node];
	}];
	
	return dump;
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

#pragma mark AnchorPoint

-(void) setAnchorPoint:(CGPoint)anchorPoint
{
	[super setAnchorPoint:anchorPoint];
	
	// update all view origin nodes
	[self enumerateChildNodesWithName:@"//KKViewOriginNode" usingBlock:^(SKNode *node, BOOL *stop) {
		KKViewAnchorNode* originNode = (KKViewAnchorNode*)node;
		[originNode updatePositionFromSceneFrame];
	}];
}

#pragma mark Description

-(NSString*) description
{
	return [NSString stringWithFormat:@"%@ controller:%@ behaviors:%@", [super description], self.controller, self.controller.behaviors];
}

#pragma mark !! Update methods below whenever class layout changes !!
#pragma mark NSCoding

static NSString* const ArchiveKeyForControllers = @"controllers";
static NSString* const ArchiveKeyForInputObservers = @"inputObservers";
static NSString* const ArchiveKeyForSceneUpdateObservers = @"sceneUpdateObservers";
static NSString* const ArchiveKeyForSceneDidUpdateBehaviorsObservers = @"sceneDidUpdateBehaviorsObservers";
static NSString* const ArchiveKeyForSceneDidEvaluateActionsObservers = @"sceneDidEvaluateActionsObservers";
static NSString* const ArchiveKeyForSceneDidSimulatePhysicsObservers = @"sceneDidSimulatePhysicsObservers";
static NSString* const ArchiveKeyForSceneWillMoveFromViewObservers = @"sceneWillMoveFromViewObservers";
static NSString* const ArchiveKeyForSceneDidMoveToViewObservers = @"sceneDidMoveToViewObservers";
static NSString* const ArchiveKeyForFrameCount = @"frameCount";

-(id) initWithCoder:(NSCoder*)decoder
{
	self = [super initWithCoder:decoder];
	if (self)
	{
		_controllers = [decoder decodeObjectForKey:ArchiveKeyForControllers];
		_inputObservers = [decoder decodeObjectForKey:ArchiveKeyForInputObservers];
		_sceneUpdateObservers = [decoder decodeObjectForKey:ArchiveKeyForSceneUpdateObservers];
		_sceneDidUpdateBehaviorsObservers = [decoder decodeObjectForKey:ArchiveKeyForSceneDidUpdateBehaviorsObservers];
		_sceneDidEvaluateActionsObservers = [decoder decodeObjectForKey:ArchiveKeyForSceneDidEvaluateActionsObservers];
		_sceneDidSimulatePhysicsObservers = [decoder decodeObjectForKey:ArchiveKeyForSceneDidSimulatePhysicsObservers];
		_sceneWillMoveFromViewObservers = [decoder decodeObjectForKey:ArchiveKeyForSceneWillMoveFromViewObservers];
		_sceneDidMoveToViewObservers = [decoder decodeObjectForKey:ArchiveKeyForSceneDidMoveToViewObservers];
		_frameCount = [decoder decodeIntegerForKey:ArchiveKeyForFrameCount];
	}
	return self;
}

-(void) encodeWithCoder:(NSCoder*)encoder
{
	[super encodeWithCoder:encoder];
	[encoder encodeObject:_controllers forKey:ArchiveKeyForControllers];
	[encoder encodeObject:_inputObservers forKey:ArchiveKeyForInputObservers];
	[encoder encodeObject:_sceneUpdateObservers forKey:ArchiveKeyForSceneUpdateObservers];
	[encoder encodeObject:_sceneDidUpdateBehaviorsObservers forKey:ArchiveKeyForSceneDidUpdateBehaviorsObservers];
	[encoder encodeObject:_sceneDidEvaluateActionsObservers forKey:ArchiveKeyForSceneDidEvaluateActionsObservers];
	[encoder encodeObject:_sceneDidSimulatePhysicsObservers forKey:ArchiveKeyForSceneDidSimulatePhysicsObservers];
	[encoder encodeObject:_sceneWillMoveFromViewObservers forKey:ArchiveKeyForSceneWillMoveFromViewObservers];
	[encoder encodeObject:_sceneDidMoveToViewObservers forKey:ArchiveKeyForSceneDidMoveToViewObservers];
	[encoder encodeInteger:_frameCount forKey:ArchiveKeyForFrameCount];
}

#pragma mark NSCopying

-(id) copyWithZone:(NSZone*)zone
{
	KKScene* copy = [super copyWithZone:zone];
#pragma message "FIXME: this array copy is wrong, will make separate copies of observers!"
	copy->_controllers = [[NSMutableArray alloc] initWithArray:_controllers copyItems:YES];
	copy->_inputObservers = [[NSMutableArray alloc] initWithArray:_inputObservers copyItems:YES];
	copy->_sceneUpdateObservers = [[NSMutableArray alloc] initWithArray:_sceneUpdateObservers copyItems:YES];
	// TODO ...
	copy->_frameCount = _frameCount;
	return copy;
}

-(void) duplicateObserver:(id)observer withCopy:(id)copy
{
	// called by observing classes on copy to replace their observers
}

#pragma mark Equality

-(BOOL) isEqualToScene:(KKScene*)scene
{
	if ([self isEqualToSceneProperties:scene] == NO)
		return NO;
	
	return [self isEqualToNode:scene];
}

-(BOOL) isEqualToSceneTree:(KKScene*)scene
{
	if ([self isEqualToSceneProperties:scene] == NO)
		return NO;
	
	return [self isEqualToNodeTree:scene];
}

-(BOOL) isEqualToSceneProperties:(KKScene*)scene
{
	if (_frameCount != scene.frameCount)
		return NO;
	
	return YES;
}

@end
