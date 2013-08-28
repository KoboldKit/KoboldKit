/*
 * Copyright (c) 2013 Steffen Itterheim.
 * Released under a PROPRIETARY License:
 * KoboldKit/KoboldKitPro/KoboldKitPro.License.txt
 */

#import "KKRemoveOnContactBehavior.h"

/** In addition to removing the node (see KKRemoveOnContactBehavior) this node also informs
 the other contacting node's KKItemCollectorBehavior about the pick up. */
@interface KKPickupItemBehavior : KKBehavior

@end
