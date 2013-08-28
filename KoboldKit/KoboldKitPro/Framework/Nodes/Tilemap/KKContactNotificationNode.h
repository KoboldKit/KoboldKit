/*
 * Copyright (c) 2013 Steffen Itterheim.
 * Released under a PROPRIETARY License:
 * KoboldKit/KoboldKitPro/KoboldKitPro.License.txt
 */

#import "KKNode.h"

@interface KKContactNotificationNode : KKNode
{
	@private
	NSMutableDictionary* _info;
}

@property (atomic, copy) NSString* notification;
@property (atomic) NSString* triggerType; // alias
@property (nonatomic, readonly) NSMutableDictionary* info;
@property (atomic) BOOL onlyOnce;

-(void) postNotification;

@end
