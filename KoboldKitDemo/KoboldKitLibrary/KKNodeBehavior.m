//
//  KKBehavior.m
//  KoboldKitDemo
//
//  Created by Steffen Itterheim on 13.06.13.
//  Copyright (c) 2013 Steffen Itterheim. All rights reserved.
//

#import "KKBehavior.h"
#import "KKNodeController.h"

@implementation KKBehavior

#pragma mark Init / Dealloc

#pragma mark Join / Leave

-(void) internal_joinController:(KKNodeController*)controller withKey:(NSString*)key
{
	_controller = controller;
	_node = controller.node;
	_key = [key copy];
}

-(void) internal_leaveController
{
	_controller = nil;
	_node = nil;
	_key = nil;
}

-(void) didJoinController
{	
}

-(void) didLeaveController
{
}

#pragma mark Update

-(void) update:(NSTimeInterval)currentTime
{
}

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

@end
