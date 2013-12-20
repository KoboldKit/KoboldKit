/*
 * Copyright (c) 2013 Steffen Itterheim.
 * Released under the MIT License:
 * KoboldAid/licenses/KoboldKitFree.License.txt
 */

#import "KKScene.h"
#import "KKNode.h"
#import "KKView.h"
#import "KKNodeController.h"
#import "SKNode+KoboldKit.h"
#import "KKViewOriginNode.h"
#import "KKNodeShared.h"

@implementation KKScene
KKNODE_SHARED_CODE

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
#if TARGET_OS_IPHONE
	CGSize windowSize = [UIApplication sharedApplication].keyWindow.frame.size;
#else
	CGSize windowSize = [NSApplication sharedApplication].keyWindow.frame.size;
#endif
	
	self = [super initWithSize:windowSize];
	if (self)
	{
		NSLog(@"WARNING: scene (%@) created without specifying size. Using window size: {%.0f, %.0f}. Use sceneWithSize: initializer to prevent this warning.", self, windowSize.width, windowSize.height);
		[self initDefaults];
	}
	return self;
}

-(void) initDefaults
{
	self.physicsWorld.contactDelegate = self;
	
	const NSUInteger kInitialCapacity = 4;
	_inputObservers = [NSMutableArray arrayWithCapacity:kInitialCapacity];
	_sceneUpdateObservers = [NSMutableArray arrayWithCapacity:kInitialCapacity];
	_sceneDidEvaluateActionsObservers = [NSMutableArray arrayWithCapacity:kInitialCapacity];
	_sceneDidSimulatePhysicsObservers = [NSMutableArray arrayWithCapacity:kInitialCapacity];
	_sceneWillMoveFromViewObservers = [NSMutableArray arrayWithCapacity:kInitialCapacity];
	_sceneDidMoveToViewObservers = [NSMutableArray arrayWithCapacity:kInitialCapacity];
	_physicsContactObservers = [NSMutableArray arrayWithCapacity:kInitialCapacity];
	
	_mainLoopStage = KKMainLoopStageDidSimulatePhysics;
}

@dynamic kkView;
-(KKView*) kkView
{
	NSAssert1([self.view isKindOfClass:[KKView class]], @"Scene's view (%@) is not a KKView class", self.view);
	return (KKView*)self.view;
}

#pragma mark Update

-(void) update:(NSTimeInterval)currentTime
{
	NSAssert(_mainLoopStage == KKMainLoopStageDidSimulatePhysics, @"Scene Events Error: it seems you implemented didSimulatePhysics but did not call [super didSimulatePhysics]");
	_mainLoopStage = KKMainLoopStageDidUpdate;
	
	++_frameCount;
	
	for (id observer in _sceneUpdateObservers)
	{
		[observer update:currentTime];
	}
}

-(void) didEvaluateActions
{
	NSAssert(_mainLoopStage == KKMainLoopStageDidUpdate, @"Scene Events Error: it seems you implemented update: but did not call [super update:currentTime]");
	_mainLoopStage = KKMainLoopStageDidEvaluateActions;

	for (id observer in _sceneDidEvaluateActionsObservers)
	{
		[observer didEvaluateActions];
	}
}

-(void) didSimulatePhysics
{
	NSAssert(_mainLoopStage == KKMainLoopStageDidEvaluateActions, @"Scene Events Error: it seems you implemented didEvaluateActions: but did not call [super didEvaluateActions]");
	_mainLoopStage = KKMainLoopStageDidSimulatePhysics;

	for (id observer in _sceneDidSimulatePhysicsObservers)
	{
		[observer didSimulatePhysics];
	}
}

-(void) willMoveFromView:(SKView *)view
{
	NSLog(@"KKScene - willMoveFromView");

	for (id observer in _sceneWillMoveFromViewObservers)
	{
		[observer willMoveFromView:view];
	}

	// make sure no node is still hooked into the notification center when the scene changes
	NSNotificationCenter* notificationCenter = [NSNotificationCenter defaultCenter];
	[notificationCenter removeObserver:self];
	[self enumerateChildNodesWithName:@"//*" usingBlock:^(SKNode *node, BOOL *stop) {
		[notificationCenter removeObserver:node];
	}];
}

-(void) didMoveToView:(SKView *)view
{
	NSLog(@"KKScene - didMoveToView - scene: %p", self);
	
	for (id observer in _sceneDidMoveToViewObservers)
	{
		[observer didMoveToView:view];
	}
}

-(void) didChangeSize:(CGSize)oldSize
{
	NSLog(@"KKScene - didChangeSize:{%.1f, %.1f} - scene: %p", self.size.width, self.size.height, self);
}

#pragma mark Scene Events Observer

-(void) addSceneEventsObserver:(id)observer
{
	// prevent users from registering the scene, because it will always call these methods if implemented
	if (observer && observer != self)
	{
		dispatch_async(dispatch_get_main_queue(), ^{
			if ([observer respondsToSelector:@selector(update:)] &&
				[_sceneUpdateObservers indexOfObject:observer] == NSNotFound)
			{
				[_sceneUpdateObservers addObject:observer];
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
	if (observer)
	{
		dispatch_async(dispatch_get_main_queue(), ^{
			[_sceneUpdateObservers removeObject:observer];
			[_sceneDidEvaluateActionsObservers removeObject:observer];
			[_sceneDidSimulatePhysicsObservers removeObject:observer];
			[_sceneWillMoveFromViewObservers removeObject:observer];
			[_sceneDidMoveToViewObservers removeObject:observer];
			[_physicsContactObservers removeObject:observer];
		});
	}
}

#pragma mark Physics Contact Observer

-(void) addPhysicsContactEventsObserver:(id<KKPhysicsContactEventDelegate>)observer
{
	if (observer && observer != (id)self)
	{
		dispatch_async(dispatch_get_main_queue(), ^{
			if ([_physicsContactObservers indexOfObject:observer] == NSNotFound)
			{
				[_physicsContactObservers addObject:observer];
			}
		});
	}
}

-(void) removePhysicsContactEventsObserver:(id<KKPhysicsContactEventDelegate>)observer
{
	if (observer)
	{
		dispatch_async(dispatch_get_main_queue(), ^{
			[_physicsContactObservers removeObject:observer];
		});
	}
}


#pragma mark Input Observer

-(void) addInputEventsObserver:(id)observer
{
	if (observer && observer != self)
	{
		dispatch_async(dispatch_get_main_queue(), ^{
			if ([_inputObservers indexOfObject:observer] == NSNotFound)
			{
				[_inputObservers addObject:observer];
			}
		});
	}
}

-(void) removeInputEventsObserver:(id)observer
{
	if (observer)
	{
		dispatch_async(dispatch_get_main_queue(), ^{
			[_inputObservers removeObject:observer];
		});
	}
}

#pragma mark Touches

DEVELOPER_FIXME("remove calls to respondsToSelector by separating observers into individual touch event arrays")

#if TARGET_OS_IPHONE

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	[super touchesBegan:touches withEvent:event];
	
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
	[super touchesMoved:touches withEvent:event];
	
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
	[super touchesEnded:touches withEvent:event];
	
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
	[super touchesCancelled:touches withEvent:event];
	
	for (id observer in _inputObservers)
	{
		if ([observer respondsToSelector:@selector(touchesCancelled:withEvent:)])
		{
			[observer touchesCancelled:touches withEvent:event];
		}
	}
}

#else // OS X

-(void) mouseDown:(NSEvent*)theEvent
{
	[super mouseDown:theEvent];
	
	for (id observer in _inputObservers)
	{
		if ([observer respondsToSelector:@selector(mouseDown:)])
		{
			[observer mouseDown:theEvent];
		}
	}
}

-(void) mouseDragged:(NSEvent*)theEvent
{
	[super mouseDragged:theEvent];

	for (id observer in _inputObservers)
	{
		if ([observer respondsToSelector:@selector(mouseDragged:)])
		{
			[observer mouseDragged:theEvent];
		}
	}
}

-(void) mouseMoved:(NSEvent*)theEvent
{
	[super mouseMoved:theEvent];

	for (id observer in _inputObservers)
	{
		if ([observer respondsToSelector:@selector(mouseMoved:)])
		{
			[observer mouseMoved:theEvent];
		}
	}
}

-(void) mouseUp:(NSEvent*)theEvent
{
	[super mouseUp:theEvent];

	for (id observer in _inputObservers)
	{
		if ([observer respondsToSelector:@selector(mouseUp:)])
		{
			[observer mouseUp:theEvent];
		}
	}
}

-(void) keyDown:(NSEvent *)theEvent
{
    [super keyDown:theEvent];
    
    for (id observer in _inputObservers)
	{
		if ([observer respondsToSelector:@selector(keyDown:)])
		{
			[observer keyDown:theEvent];
		}
	}
}

-(void) keyUp:(NSEvent *)theEvent
{
    [super keyUp:theEvent];
    
    for (id observer in _inputObservers)
	{
		if ([observer respondsToSelector:@selector(keyUp:)])
		{
			[observer keyUp:theEvent];
		}
	}
}

#endif

#pragma mark Physics Contact

-(void) didBeginContact:(SKPhysicsContact *)contact
{
	SKPhysicsBody* bodyA = contact.bodyA;
	SKPhysicsBody* bodyB = contact.bodyB;
	SKNode* nodeA = bodyA.node;
	SKNode* nodeB = bodyB.node;
	for (id<KKPhysicsContactEventDelegate> observer in _physicsContactObservers)
	{
		SKNode* observerNode = observer.node;
		if (observerNode == nodeA)
		{
			[observer didBeginContact:contact otherBody:bodyB];
		}
		else if (observerNode == nodeB)
		{
			[observer didBeginContact:contact otherBody:bodyA];
		}
	}
}

-(void) didEndContact:(SKPhysicsContact *)contact
{
	SKPhysicsBody* bodyA = contact.bodyA;
	SKPhysicsBody* bodyB = contact.bodyB;
	SKNode* nodeA = bodyA.node;
	SKNode* nodeB = bodyB.node;
	for (id<KKPhysicsContactEventDelegate> observer in _physicsContactObservers)
	{
		SKNode* observerNode = observer.node;
		if (observerNode == nodeA)
		{
			[observer didEndContact:contact otherBody:bodyB];
		}
		else if (observerNode == nodeB)
		{
			[observer didEndContact:contact otherBody:bodyA];
		}
	}
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

#pragma mark AnchorPoint

-(void) setAnchorPoint:(CGPoint)anchorPoint
{
	[super setAnchorPoint:anchorPoint];
	
	// update all view origin nodes
	[self enumerateChildNodesWithName:@"//KKViewOriginNode" usingBlock:^(SKNode *node, BOOL *stop) {
		KKViewOriginNode* originNode = (KKViewOriginNode*)node;
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
		_inputObservers = [decoder decodeObjectForKey:ArchiveKeyForInputObservers];
		_sceneUpdateObservers = [decoder decodeObjectForKey:ArchiveKeyForSceneUpdateObservers];
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
	[encoder encodeObject:_inputObservers forKey:ArchiveKeyForInputObservers];
	[encoder encodeObject:_sceneUpdateObservers forKey:ArchiveKeyForSceneUpdateObservers];
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
DEVELOPER_FIXME("this array copy is wrong, will make separate copies of observers!")
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
