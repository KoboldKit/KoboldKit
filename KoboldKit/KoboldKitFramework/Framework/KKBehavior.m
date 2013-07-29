//
//  KKBehavior.m
//  KoboldKitDemo
//
//  Created by Steffen Itterheim on 13.06.13.
//  Copyright (c) 2013 Steffen Itterheim. All rights reserved.
//

#import "KKBehavior.h"
#import "KKNodeController.h"
#import "SKNode+KoboldKit.h"

@implementation KKBehavior

#pragma mark Init / Dealloc

+(id) behavior
{
	return [[self alloc] init];
}

-(id) init
{
	self = [super init];
	if (self)
	{
		_enabled = YES;
	}
	return self;
}

#pragma mark Join / Leave

-(void) internal_joinController:(KKNodeController*)controller withKey:(NSString*)key
{
	_controller = controller;
	_node = controller.node;
	_key = [key copy];
}

-(void) didJoinController
{	
}

-(void) didLeaveController
{
}

-(void) removeFromNode
{
	[self.node removeBehavior:self];
}

#pragma mark Update

-(void) update:(NSTimeInterval)currentTime
{
}

-(void) didEvaluateActions
{
}

-(void) didSimulatePhysics
{
}

#pragma mark Notifications

-(void) postNotificationName:(NSString*)name userInfo:(NSDictionary*)userInfo
{
	if (userInfo)
	{
		userInfo = [NSMutableDictionary dictionaryWithDictionary:userInfo];
		[userInfo setValue:self forKey:@"behavior"];
	}
	else
	{
		userInfo = @{@"behavior": self};
	}
	
	[[NSNotificationCenter defaultCenter] postNotificationName:name
														object:self.node
													  userInfo:userInfo];
}

-(void) postNotificationName:(NSString *)name
{
	[self postNotificationName:name userInfo:nil];
}

#pragma mark !! Update methods below whenever class layout changes !!
#pragma mark NSCoding

static NSString* const ArchiveKeyForKey = @"key";
static NSString* const ArchiveKeyForController = @"controller";
static NSString* const ArchiveKeyForNode = @"node";
static NSString* const ArchiveKeyForWantsUpdate = @"wantsUpdate";

-(id) initWithCoder:(NSCoder*)decoder
{
	self = [super init];
	if (self)
	{
		_key = [decoder decodeObjectForKey:ArchiveKeyForKey];
		_controller = [decoder decodeObjectForKey:ArchiveKeyForController];
		_node = [decoder decodeObjectForKey:ArchiveKeyForNode];
		_wantsUpdate = [decoder decodeBoolForKey:ArchiveKeyForWantsUpdate];
	}
	return self;
}

-(void) encodeWithCoder:(NSCoder*)encoder
{
	[encoder encodeObject:_key forKey:ArchiveKeyForKey];
	[encoder encodeObject:_controller forKey:ArchiveKeyForController];
	[encoder encodeObject:_node forKey:ArchiveKeyForNode];
	[encoder encodeBool:_wantsUpdate forKey:ArchiveKeyForWantsUpdate];
}

#pragma mark NSCopying

-(id) copyWithZone:(NSZone*)zone
{
	KKBehavior* copy = [[[self class] allocWithZone:zone] init];
	copy->_key = [_key copy];
	copy->_wantsUpdate = _wantsUpdate;
	return copy;
}

#pragma mark Equality

-(BOOL) isEqualToBehavior:(KKBehavior*)behavior
{
	if ([self isMemberOfClass:[behavior class]] == NO)
		return NO;
	
	if ((_key != nil || behavior.key != nil) &&
		[_key isEqualToString:behavior.key] == NO)
		return NO;
	
	if (_wantsUpdate != behavior.wantsUpdate)
		return NO;
	
	return YES;
}

@end
