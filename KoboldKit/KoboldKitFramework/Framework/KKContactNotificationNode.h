//
//  KKContactNotificationNode.h
//  KoboldKit
//
//  Created by Steffen Itterheim on 02.08.13.
//  Copyright (c) 2013 Steffen Itterheim. All rights reserved.
//

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
