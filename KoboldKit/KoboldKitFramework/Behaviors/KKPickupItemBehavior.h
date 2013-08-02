//
//  KKPickupItemBehavior.h
//  KoboldKit
//
//  Created by Steffen Itterheim on 01.08.13.
//  Copyright (c) 2013 Steffen Itterheim. All rights reserved.
//

#import "KKRemoveOnContactBehavior.h"

/** In addition to removing the node (see KKRemoveOnContactBehavior) this node also informs
 the other contacting node's KKItemCollectorBehavior about the pick up. */
@interface KKPickupItemBehavior : KKBehavior

@property (atomic) NSUInteger itemType;

@end
