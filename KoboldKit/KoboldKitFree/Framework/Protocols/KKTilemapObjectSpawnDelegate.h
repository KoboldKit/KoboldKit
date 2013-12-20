/*
 * Copyright (c) 2013 Steffen Itterheim.
 * Released under the MIT License:
 * KoboldAid/licenses/KoboldKitFree.License.txt
 */


#import "KKFramework.h"

@class KKTilemapObject;

@protocol KKTilemapObjectSpawnDelegate <NSObject>

@optional

/** Create a rectangle physics body sized to match a tile.
 @param tilemapObject the object to create a physics body from. This tile must have a size property. */
-(SKPhysicsBody*) physicsBodyWithTilemapObject:(KKTilemapObject*)tilemapObject;

-(void) nodeDidSpawnWithTilemapObject:(KKTilemapObject*)tilemapObject;

@end
