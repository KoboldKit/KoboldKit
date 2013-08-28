/*
 * Copyright (c) 2013 Steffen Itterheim.
 * Released under the MIT License:
 * KoboldAid/licenses/KoboldKitFree.License.txt
 */

#import "KKFramework.h"
#import "KKTilemapObjectSpawnDelegate.h"


/** In Kobold Kit KKNode must be used in place of SKNode to ensure that KK messaging works (ie didMoveToParent, willMoveFromParent, etc). */
@interface KKNode : SKNode <KKTilemapObjectSpawnDelegate>


@end
