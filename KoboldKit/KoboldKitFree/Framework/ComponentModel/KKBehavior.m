/*
 * Copyright (c) 2013 Steffen Itterheim.
 * Released under the MIT License:
 * KoboldAid/licenses/KoboldKitFree.License.txt
 */


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
		[self didInitialize];
	}
	return self;
}

/*
-(void) dealloc
{
	NSLog(@"dealloc: %@", self);
}
*/

#pragma mark Join / Leave

-(void) internal_joinController:(KKNodeController*)controller withKey:(NSString*)key
{
	_controller = controller;
	_node = controller.node;
	_key = [key copy];
}

-(void) removeFromNode
{
	[self.node removeBehavior:self];
}

#pragma mark Subclass overrides
-(void) didInitialize
{
}

-(void) didJoinController
{
}

-(void) didLeaveController
{
}

-(void) didChangeEnabledState
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

@dynamic enabled;
-(BOOL) enabled
{
	return _enabled;
}
-(void) setEnabled:(BOOL)enabled
{
	@synchronized(self)
	{
		if (_enabled != enabled)
		{
			_enabled = enabled;
			[self didChangeEnabledState];
		}
	}
}

#pragma mark !! Update methods below whenever class layout changes !!
#pragma mark NSCoding

static NSString* const ArchiveKeyForKey = @"key";
static NSString* const ArchiveKeyForController = @"controller";
static NSString* const ArchiveKeyForNode = @"node";

-(id) initWithCoder:(NSCoder*)decoder
{
	self = [super init];
	if (self)
	{
		_key = [decoder decodeObjectForKey:ArchiveKeyForKey];
		_controller = [decoder decodeObjectForKey:ArchiveKeyForController];
		_node = [decoder decodeObjectForKey:ArchiveKeyForNode];
	}
	return self;
}

-(void) encodeWithCoder:(NSCoder*)encoder
{
	[encoder encodeObject:_key forKey:ArchiveKeyForKey];
	[encoder encodeObject:_controller forKey:ArchiveKeyForController];
	[encoder encodeObject:_node forKey:ArchiveKeyForNode];
}

#pragma mark NSCopying

-(id) copyWithZone:(NSZone*)zone
{
	KKBehavior* copy = [[[self class] allocWithZone:zone] init];
	copy->_key = [_key copy];
	copy->_name = [_name copy];
	copy->_enabled = _enabled;
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
	
	return YES;
}

@end
