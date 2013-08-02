//
//  KKNotifyOnItemCountBehavior.h
//  KoboldKit
//
//  Created by Steffen Itterheim on 02.08.13.
//  Copyright (c) 2013 Steffen Itterheim. All rights reserved.
//

#import "KKBehavior.h"

@interface KKNotifyOnItemCountBehavior : KKBehavior

@property (atomic, copy) NSString* notification;
@property (atomic, copy) NSString* itemName;
@property (atomic) unsigned int count;

-(void) didPickUpItemWithName:(NSString*)itemName count:(unsigned int)count;

@end
