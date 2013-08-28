/*
 * Copyright (c) 2013 Steffen Itterheim.
 * Released under a PROPRIETARY License:
 * KoboldKit/KoboldKitPro/KoboldKitPro.License.txt
 */


#import "KKBehavior.h"

@interface KKNotifyOnItemCountBehavior : KKBehavior

@property (atomic, copy) NSString* notification;
@property (atomic, copy) NSString* itemName;
@property (atomic) unsigned int count;

-(void) didPickUpItemWithName:(NSString*)itemName count:(unsigned int)count;

@end
