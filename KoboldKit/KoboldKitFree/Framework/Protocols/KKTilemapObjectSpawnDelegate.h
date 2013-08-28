/*
 * Copyright (c) 2013 Steffen Itterheim.
 * Released under the MIT License:
 * KoboldAid/licenses/KoboldKitFree.License.txt
 */


#import "KKFramework.h"

@class KKTilemapObject;

@protocol KKTilemapObjectSpawnDelegate <NSObject>
@optional
-(SKPhysicsBody*) physicsBodyWithTilemapObject:(KKTilemapObject*)tilemapObject;
-(void) nodeDidSpawnWithTilemapObject:(KKTilemapObject*)tilemapObject;
@end
