/*
 * Copyright (c) 2013 Steffen Itterheim.
 * Released under the MIT License:
 * KoboldAid/licenses/KoboldKitFree.License.txt
 */


#import "KKNodeController.h"
#import "SKNode+KoboldKit.h"
#import "KKScene.h"
#import "KKModel.h"
#import "KKBehavior.h"

NSString* const KKNodeControllerUserDataKey = @"<KKNodeController>";

@implementation KKNodeController

#pragma mark Init / Dealloc

+(id) controllerWithBehaviors:(NSArray*)behaviors
{
	return [[self alloc] initWithBehaviors:behaviors];
}

-(id) initWithBehaviors:(NSArray*)behaviors
{
	self = [super init];
	if (self)
	{
		[self sharedInit];
		[self addBehaviors:behaviors];
	}
	return self;
}

-(id) init
{
	self = [super init];
	if (self)
	{
		[self sharedInit];
	}
	return self;
}

-(void) sharedInit
{
	_behaviors = [NSMutableArray array];
	_physicsDidBeginContactObservers = [NSMutableArray array];
	_physicsDidEndContactObservers = [NSMutableArray array];
}

/*
-(void) dealloc
{
	NSLog(@"dealloc: %@", self);
}
 */

// called when the node removes the controller (set to nil)
-(void) willRemoveController
{
	[self removeAllBehaviors];
}

-(void) nodeDidMoveToParent
{
	for (KKBehavior* behavior in _behaviors)
	{
		[behavior didJoinController];
	}
	
	[self startObservingPhysicsContactEvents];
}

-(void) nodeWillMoveFromParent
{
	[self stopObservingPhysicsContactEvents];
	
	for (KKBehavior* behavior in _behaviors)
	{
		[behavior didLeaveController];
	}
}

#pragma mark Properties

-(KKModel*) model
{
	// created on demand
	if (_model == nil)
	{
		_model = [KKModel model];
		_model.controller = self;
	}
	return _model;
}

-(void) setModel:(KKModel *)model
{
	@synchronized(self)
	{
		_model = model;
		_model.controller = self;
	}
}

-(SKNode*) node
{
	return _node;
}

-(void) setNode:(SKNode*)node
{
	@synchronized(self)
	{
		if (_node != node)
		{
			if (_node != nil)
			{
				[self removePotentialPhysicsContactObserver:_node];
			}
			
			_node = node;

			if (_node)
			{
				[self addPotentialPhysicsContactObserver:_node];
			}
		}
	}
}

#pragma mark Behaviors

-(void) addBehavior:(KKBehavior*)behavior withKey:(NSString*)key
{
	[self removeBehaviorForKey:key];

	// don't copy like actions
	//behavior = [behavior copy];

	NSAssert3(behavior.node == nil, @"The behavior (%@) already belongs to node (%@) ---- tried to add it to node: %@", behavior, behavior.node, self.node);

	[behavior internal_joinController:self withKey:key];
	[_behaviors addObject:behavior];
	
	if (_node.parent)
	{
		[behavior didJoinController];
	}
	
	[self addPotentialPhysicsContactObserver:behavior];
}

-(void) addBehavior:(KKBehavior*)behavior
{
	[self addBehavior:behavior withKey:nil];
}

-(void) addBehaviors:(NSArray*)behaviors
{
	for (KKBehavior* behavior in behaviors)
	{
		[self addBehavior:behavior];
	}
}

-(KKBehavior*) behaviorForKey:(NSString*)key
{
	for (KKBehavior* behavior in _behaviors)
	{
		if ([key isEqualToString:behavior.key])
		{
			return behavior;
		}
	}
	return nil;
}

-(id) behaviorKindOfClass:(Class)behaviorClass
{
	for (KKBehavior* behavior in _behaviors)
	{
		if ([behavior isKindOfClass:behaviorClass])
		{
			return behavior;
		}
	}
	return nil;
}

-(id) behaviorMemberOfClass:(Class)behaviorClass
{
	for (KKBehavior* behavior in _behaviors)
	{
		if ([behavior isMemberOfClass:behaviorClass])
		{
			return behavior;
		}
	}
	return nil;
}

-(BOOL) hasBehaviors
{
	return _behaviors.count > 0;
}

-(void) removeBehavior:(KKBehavior*)behavior
{
	[_behaviors removeObject:behavior];

	[behavior didLeaveController];
	[self removePotentialPhysicsContactObserver:behavior];
}


-(void) removeBehaviorForKey:(NSString*)key
{
	if (key)
	{
		for (KKBehavior* behavior in [_behaviors reverseObjectEnumerator])
		{
			if ([key isEqualToString:behavior.key])
			{
				[self removeBehavior:behavior];
				break;
			}
		}
	}
}

-(void) removeBehaviorWithClass:(Class)behaviorClass
{
	for (KKBehavior* behavior in [_behaviors reverseObjectEnumerator])
	{
		if ([behavior isMemberOfClass:behaviorClass])
		{
			[self removeBehavior:behavior];
			break;
		}
	}
}

-(void) removeAllBehaviors
{
	for (KKBehavior* behavior in [_behaviors reverseObjectEnumerator])
	{
		[self removeBehavior:behavior];
	}
}

#pragma mark Physics Contact Events

-(void) didBeginContact:(SKPhysicsContact*)contact otherBody:(SKPhysicsBody*)otherBody
{
	for (id<KKPhysicsContactEventDelegate> observer in _physicsDidBeginContactObservers)
	{
		[observer didBeginContact:contact otherBody:otherBody];
	}
}

-(void) didEndContact:(SKPhysicsContact*)contact otherBody:(SKPhysicsBody*)otherBody
{
	for (id<KKPhysicsContactEventDelegate> observer in _physicsDidEndContactObservers)
	{
		[observer didEndContact:contact otherBody:otherBody];
	}
}

-(void) startObservingPhysicsContactEvents
{
	if (_observingPhysicsContactEvents == NO && _node.parent)
	{
		_observingPhysicsContactEvents = YES;
		[_node.kkScene addPhysicsContactEventsObserver:self];
	}
}

-(void) stopObservingPhysicsContactEvents
{
	if (_observingPhysicsContactEvents == YES && _node.parent)
	{
		_observingPhysicsContactEvents = NO;
		[_node.kkScene removePhysicsContactEventsObserver:self];
	}
}

-(void) addPotentialPhysicsContactObserver:(id)potentialObserver
{
	BOOL didAdd = NO;
	if ([potentialObserver respondsToSelector:@selector(didBeginContact:otherBody:)])
	{
		[_physicsDidBeginContactObservers addObject:potentialObserver];
		didAdd = YES;
	}
	if ([potentialObserver respondsToSelector:@selector(didEndContact:otherBody:)])
	{
		[self startObservingPhysicsContactEvents];
		[_physicsDidEndContactObservers addObject:potentialObserver];
		didAdd = YES;
	}

	if (didAdd && _observingPhysicsContactEvents == NO)
	{
		[self startObservingPhysicsContactEvents];
	}
}

-(void) removePotentialPhysicsContactObserver:(id)potentialObserver
{
	[_physicsDidBeginContactObservers removeObject:potentialObserver];
	[_physicsDidEndContactObservers removeObject:potentialObserver];
}

#pragma mark !! Update methods below whenever class layout changes !!
#pragma mark NSCoding

static NSString* const ArchiveKeyForNode = @"node";
static NSString* const ArchiveKeyForUserData = @"userData";
static NSString* const ArchiveKeyForBehaviors = @"behaviors";
static NSString* const ArchiveKeyForPaused = @"paused";

-(id) initWithCoder:(NSCoder*)decoder
{
	self = [super init];
	if (self)
	{
		_node = [decoder decodeObjectForKey:ArchiveKeyForNode];
		_userData = [decoder decodeObjectForKey:ArchiveKeyForUserData];
		_behaviors = [decoder decodeObjectForKey:ArchiveKeyForBehaviors];
		_paused = [decoder decodeBoolForKey:ArchiveKeyForPaused];
		
		for (KKBehavior* behavior in _behaviors)
		{
			
		}
	}
	return self;
}

-(void) encodeWithCoder:(NSCoder*)encoder
{
	[encoder encodeObject:_node forKey:ArchiveKeyForNode];
	[encoder encodeObject:_userData forKey:ArchiveKeyForUserData];
	[encoder encodeObject:_behaviors forKey:ArchiveKeyForBehaviors];
	[encoder encodeBool:_paused forKey:ArchiveKeyForPaused];
}

#pragma mark NSCopying

-(id) copyWithZone:(NSZone*)zone
{
	KKNodeController* copy = [[[self class] allocWithZone:zone] init];
	copy->_userData = [[NSMutableDictionary alloc] initWithDictionary:_userData copyItems:YES];
	copy->_behaviors = [[NSMutableArray alloc] initWithArray:_behaviors copyItems:YES];
	copy->_paused = _paused;
	return copy;
}

#pragma mark Equality

-(BOOL) isEqualToController:(KKNodeController*)controller
{
	if ([self isEqualToControllerProperties:controller] == NO)
		return NO;

	NSUInteger behaviorsCount = controller.behaviors.count;
	if (controller.behaviors.count != behaviorsCount)
		return NO;
	
	for (NSUInteger i = 0; i < behaviorsCount; i++)
	{
		KKBehavior* selfBehavior = [self.behaviors objectAtIndex:i];
		KKBehavior* controllerBehavior = [controller.behaviors objectAtIndex:i];
		
		if ([selfBehavior isEqualToBehavior:controllerBehavior] == NO)
			return NO;
	}
    
    // Compare userData
    if ([controller.userData hash] != [self.userData hash])
        return NO;
	
DEVELOPER_TODO("compare model in isEqual")
	
	return YES;
}

-(BOOL) isEqualToControllerProperties:(KKNodeController*)controller
{
	if (self.paused != controller.paused)
		return NO;
	
	return YES;
}

@end
