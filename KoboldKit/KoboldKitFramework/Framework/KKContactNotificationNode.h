//
//  KKContactNotificationNode.h
//  KoboldKit
//
//  Created by Steffen Itterheim on 02.08.13.
//  Copyright (c) 2013 Steffen Itterheim. All rights reserved.
//

#import "KKNode.h"

@interface KKContactNotificationNode : KKNode

@property (atomic, copy) NSString* notification;
@property (atomic) BOOL notifyRepeatedly;

-(void) postNotification;

@end
