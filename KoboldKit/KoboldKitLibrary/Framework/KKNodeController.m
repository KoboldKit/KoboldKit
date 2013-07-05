//
//  KKNodeController.m
//  KoboldKitDemo
//
//  Created by Steffen Itterheim on 13.06.13.
//  Copyright (c) 2013 Steffen Itterheim. All rights reserved.
//

#import "KKNodeController.h"
#import "SKNode+KoboldKit.h"
#import "KKScene.h"
#import "KKNodeModel.h"
#import "KKNodeBehavior.h"

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
		[self addBehaviors:behaviors];
	}
	return self;
}

-(void) dealloc
{
	[self removeAllBehaviors];
	[_node.kkScene unregisterController:self];
}

#pragma mark Properties

@dynamic model;
-(KKNodeModel*) model
{
	return _model;
}

-(void) setModel:(KKNodeModel *)model
{
	@synchronized(self)
	{
		_model = model;
		_model.controller = self;
	}
}

#pragma mark Behaviors

-(void) addBehavior:(KKNodeBehavior*)behavior withKey:(NSString*)key
{
	[self removeBehaviorForKey:key];

	behavior = [behavior copy];
	[behavior internal_joinController:self withKey:key];
	
	if (_behaviors == nil)
	{
		_behaviors = [NSMutableArray arrayWithObject:behavior];
	}
	else
	{
		[_behaviors addObject:behavior];
	}
	
	[behavior didJoinController];
	
	_hasBehaviorWantingUpdate = (_hasBehaviorWantingUpdate || behavior.wantsUpdate);
}

-(void) addBehavior:(KKNodeBehavior*)behavior
{
	[self addBehavior:behavior withKey:nil];
}

-(void) addBehaviors:(NSArray*)behaviors
{
	for (KKNodeBehavior* behavior in behaviors)
	{
		[self addBehavior:behavior];
	}
}

-(KKNodeBehavior*) behaviorForKey:(NSString*)key
{
	for (KKNodeBehavior* behavior in _behaviors)
	{
		if ([key isEqualToString:behavior.key])
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

-(void) removeBehavior:(KKNodeBehavior*)behavior
{
	[_behaviors removeObject:behavior];

	[behavior didLeaveController];
}


-(void) removeBehaviorForKey:(NSString*)key
{
	if (key)
	{
		for (KKNodeBehavior* behavior in [_behaviors reverseObjectEnumerator])
		{
			if ([key isEqualToString:behavior.key])
			{
				[self removeBehavior:behavior];
				break;
			}
		}
	}
}

-(void) removeAllBehaviors
{
	for (KKNodeBehavior* behavior in [_behaviors reverseObjectEnumerator])
	{
		[self removeBehavior:behavior];
	}
	
	_behaviors = nil;
}

#pragma mark Update

-(void) update:(NSTimeInterval)currentTime
{
	if (_hasBehaviorWantingUpdate)
	{
		for (KKNodeBehavior* behavior in _behaviors)
		{
			if (behavior.wantsUpdate)
			{
				[behavior update:currentTime];
			}
		}
	}
}

-(void) didEvaluateActions
{
	if (_hasBehaviorWantingUpdate)
	{
		for (KKNodeBehavior* behavior in _behaviors)
		{
			if (behavior.wantsUpdate)
			{
				[behavior didEvaluateActions];
			}
		}
	}
}

-(void) didSimulatePhysics
{
	if (_hasBehaviorWantingUpdate)
	{
		for (KKNodeBehavior* behavior in _behaviors)
		{
			if (behavior.wantsUpdate)
			{
				[behavior didSimulatePhysics];
			}
		}
	}
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
		
		for (KKNodeBehavior* behavior in _behaviors)
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
		KKNodeBehavior* selfBehavior = [self.behaviors objectAtIndex:i];
		KKNodeBehavior* controllerBehavior = [controller.behaviors objectAtIndex:i];
		
		if ([selfBehavior isEqualToBehavior:controllerBehavior] == NO)
			return NO;
	}
	
#pragma message "TODO: compare model in isEqual"
#pragma message "TODO: compare userData in isEqual"
	
	return YES;
}

-(BOOL) isEqualToControllerProperties:(KKNodeController*)controller
{
	if (self.paused != controller.paused)
		return NO;
	
	return YES;
}

@end
