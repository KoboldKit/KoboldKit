/*
 * Copyright (c) 2013 Steffen Itterheim.
 * Released under a PROPRIETARY License:
 * KoboldKit/KoboldKitPro/KoboldKitPro.License.txt
 */

#import "KKContactNotificationNode.h"
#import "SKNode+KoboldKit.h"
#import "KKPhysicsContactEventDelegate.h"
#import "KKTilemapNode.h"

@implementation KKContactNotificationNode

-(void) didMoveToParent
{
	[self createController];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationNotSet:) name:@"<missing notification>" object:self];
}

-(void) willMoveFromParent
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void) notificationNotSet:(NSNotification*)notification
{
	[NSException raise:NSInternalInconsistencyException format:@"contact notification node (%@) received a '<missing notification>' notification (%@)", self, notification];
}

-(void) postNotification
{
	[[NSNotificationCenter defaultCenter] postNotificationName:_notification object:self userInfo:_info];
}

-(SKPhysicsBody*) physicsBodyWithTilemapObject:(KKTilemapObject*)tilemapObject
{
	return [self physicsBodyWithRectangleOfSize:tilemapObject.size];
}

-(void) didBeginContact:(SKPhysicsContact*)contact otherBody:(SKPhysicsBody*)otherBody
{
	[self postNotification];
	
	if (_onlyOnce)
	{
		[self removeFromParent];
	}
}

@dynamic triggerType;
-(NSString*) triggerType
{
	return _notification;
}
-(void) setTriggerType:(NSString *)triggerType
{
	self.notification = triggerType;
}

-(NSMutableDictionary*) info
{
	if (_info == nil)
	{
		_info = [NSMutableDictionary dictionaryWithCapacity:4];
	}
	return _info;
}

@end
