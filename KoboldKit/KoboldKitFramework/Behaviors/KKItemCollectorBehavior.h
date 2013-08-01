//
//  KKItemCollectorBehavior.h
//  KoboldKit
//
//  Created by Steffen Itterheim on 01.08.13.
//  Copyright (c) 2013 Steffen Itterheim. All rights reserved.
//

#import "KKBehavior.h"

@class KKPickupItemBehavior;

@interface KKItemCollectorBehavior : KKBehavior

-(void) didPickUpItem:(KKPickupItemBehavior*)itemBehavior;

@end
