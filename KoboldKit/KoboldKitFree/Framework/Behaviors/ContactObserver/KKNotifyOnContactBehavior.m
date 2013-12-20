/*
 * Copyright (c) 2013 Steffen Itterheim.
 * Released under the MIT License:
 * KoboldAid/licenses/KoboldKitFree.License.txt
 */


#import "KKNotifyOnContactBehavior.h"

@implementation KKNotifyOnContactBehavior

-(void) didBeginContact:(SKPhysicsContact *)contact otherBody:(SKPhysicsBody *)otherBody
{
	[self postNotificationName:_notification];
}

#pragma mark !! Update methods below whenever class layout changes !!
#pragma mark NSCoding
static NSString* const ArchiveKeyForNotification = @"notification";

-(id) initWithCoder:(NSCoder*)decoder
{
	self = [super init];
	if (self)
	{
        _notification = [decoder decodeObjectForKey:ArchiveKeyForNotification];
	}
	return self;
}

-(void) encodeWithCoder:(NSCoder*)encoder
{
    [encoder encodeObject:_notification forKey:ArchiveKeyForNotification];
}

#pragma mark NSCopying

-(id) copyWithZone:(NSZone*)zone
{
	KKNotifyOnContactBehavior* copy = [[super copyWithZone:zone] init];
	copy->_notification = [_notification copy];
	return copy;
}


#pragma mark Equality

-(BOOL) isEqualToBehavior:(KKBehavior*)behavior
{
    if ([self isMemberOfClass:[behavior class]] == NO)
        return NO;
    
    KKNotifyOnContactBehavior *notifyBehavior = (KKNotifyOnContactBehavior *)behavior;
    if ([self.notification isEqualToString:notifyBehavior.notification])
        return YES;
     
    return NO;
}

@end
