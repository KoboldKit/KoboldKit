/*
 * Copyright (c) 2013 Steffen Itterheim.
 * Released under a PROPRIETARY License:
 * KoboldKit/KoboldKitPro/KoboldKitPro.License.txt
 */


#import "KKBehavior.h"

@class KKPickupItemBehavior;

@interface KKItemCollectorBehavior : KKBehavior

-(void) didPickUpItem:(KKPickupItemBehavior*)itemBehavior;

@end
