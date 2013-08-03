//
//  KKTilemapObjectSpawnDelegate.h
//  KoboldKit
//
//  Created by Steffen Itterheim on 03.08.13.
//  Copyright (c) 2013 Steffen Itterheim. All rights reserved.
//

#import "KKCompatibility.h"

@class KKTilemapObject;

@protocol KKTilemapObjectSpawnDelegate <NSObject>
@optional
-(SKPhysicsBody*) physicsBodyWithTilemapObject:(KKTilemapObject*)tilemapObject;
-(void) nodeDidSpawnWithTilemapObject:(KKTilemapObject*)tilemapObject;
@end
