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
#import "KKBehavior.h"

NSString* const KKNodeControllerUserDataKey = @"<KKNodeController>";

@implementation KKNodeController

#pragma mark Init / Dealloc

+(id) controller
{
	return [[self alloc] initWithBehaviors:nil];
}

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

#pragma mark Behaviors

-(void) addBehavior:(KKBehavior*)behavior withKey:(NSString*)key
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

-(BOOL) hasBehaviors
{
	return _behaviors.count > 0;
}

-(void) removeBehavior:(KKBehavior*)behavior
{
	[_behaviors removeObject:behavior];

	[behavior internal_leaveController];
	[behavior didLeaveController];
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

-(void) removeAllBehaviors
{
	for (KKBehavior* behavior in _behaviors)
	{
		[self removeBehavior:behavior];
	}
	
	_behaviors = nil;
}

#pragma mark Update

-(void) update:(NSTimeInterval)currentTime
{
	for (KKBehavior* behavior in _behaviors)
	{
		if (behavior.wantsUpdate)
		{
			[behavior update:currentTime];
		}
	}
}

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

@end
