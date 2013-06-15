//
//  KKScene.m
//  KoboldKitDemo
//
//  Created by Steffen Itterheim on 13.06.13.
//  Copyright (c) 2013 Steffen Itterheim. All rights reserved.
//

#import "KKScene.h"
#import "KKNodeController.h"
#import "SKNode+KoboldKit.h"

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
	//self.anchorPoint = CGPointMake(0.5f, 0.5f);
	self.physicsWorld.contactDelegate = self;
	_inputReceivers = [NSMutableArray array];
	_inputReceiversToAdd = [NSMutableArray array];
	_inputReceiversToRemove = [NSMutableArray array];
}

-(void) dealloc
{
	NSLog(@"dealloc: %@", self);
}

#pragma mark View

-(void) didMoveToView:(SKView *)view
{
}

-(void) willMoveFromView:(SKView *)view
{
}

#pragma mark Controllers

-(void) registerController:(KKNodeController*)controller
{
	if (_controllers == nil)
	{
		_controllers = [NSMutableArray arrayWithObject:controller];
	}
	else
	{
		[_controllers addObject:controller];
	}
}

-(void) unregisterController:(KKNodeController*)controller
{
	[_controllers removeObject:controller];
}

#pragma mark Update

-(void) update:(NSTimeInterval)currentTime
{
	++_frameCount;
	
	// update controllers
	for (KKNodeController* controller in _controllers)
	{
		if (controller.paused == NO)
		{
			[controller update:currentTime];
		}
	}
}

/*
-(void) didEvaluateActions
{
	
}
*/

-(void) didSimulatePhysics
{
	[self addAndRemoveInputReceivers];
}

#pragma mark Input

-(void) addAndRemoveInputReceivers
{
	[_inputReceivers addObjectsFromArray:_inputReceiversToAdd];
	[_inputReceiversToAdd removeAllObjects];

	[_inputReceivers removeObjectsInArray:_inputReceiversToRemove];
	[_inputReceiversToRemove removeAllObjects];
}

-(void) registerInputReceiver:(id)receiver
{
	[_inputReceiversToAdd addObject:receiver];
}

-(void) unregisterInputReceiver:(id)receiver
{
	[_inputReceiversToRemove addObject:receiver];
}

#pragma mark Touches

#if TARGET_OS_IPHONE
-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	for (id receiver in _inputReceivers)
	{
		if ([receiver respondsToSelector:@selector(touchesBegan:withEvent:)])
		{
			[receiver touchesBegan:touches withEvent:event];
		}
	}
}

-(void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	for (id receiver in _inputReceivers)
	{
		if ([receiver respondsToSelector:@selector(touchesBegan:withEvent:)])
		{
			[receiver touchesMoved:touches withEvent:event];
		}
	}
}

-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	for (id receiver in _inputReceivers)
	{
		if ([receiver respondsToSelector:@selector(touchesBegan:withEvent:)])
		{
			[receiver touchesEnded:touches withEvent:event];
		}
	}
}

-(void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	for (id receiver in _inputReceivers)
	{
		if ([receiver respondsToSelector:@selector(touchesBegan:withEvent:)])
		{
			[receiver touchesCancelled:touches withEvent:event];
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

#pragma mark !! Update methods below whenever class layout changes !!
#pragma mark NSCoding

static NSString* const ArchiveKeyForControllers = @"controller";
static NSString* const ArchiveKeyForInputReceivers = @"inputReceivers";
static NSString* const ArchiveKeyForFrameCount = @"frameCount";

-(id) initWithCoder:(NSCoder*)decoder
{
	self = [super initWithCoder:decoder];
	if (self)
	{
		_controllers = [decoder decodeObjectForKey:ArchiveKeyForControllers];
		_inputReceivers = [decoder decodeObjectForKey:ArchiveKeyForInputReceivers];
		_frameCount = [decoder decodeIntegerForKey:ArchiveKeyForFrameCount];
	}
	return self;
}

-(void) encodeWithCoder:(NSCoder*)encoder
{
	[super encodeWithCoder:encoder];
	[encoder encodeObject:_controllers forKey:ArchiveKeyForControllers];
	[encoder encodeObject:_inputReceivers forKey:ArchiveKeyForInputReceivers];
	[encoder encodeInteger:_frameCount forKey:ArchiveKeyForFrameCount];
}

#pragma mark NSCopying

-(id) copyWithZone:(NSZone*)zone
{
	KKScene* copy = [super copyWithZone:zone];
	copy->_controllers = [[NSMutableArray alloc] initWithArray:_controllers copyItems:YES];
	copy->_inputReceivers = [[NSMutableArray alloc] initWithArray:_inputReceivers copyItems:YES];
	copy->_frameCount = _frameCount;
	return copy;
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
