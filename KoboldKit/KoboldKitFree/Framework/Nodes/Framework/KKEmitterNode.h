/*
 * Copyright (c) 2013 Steffen Itterheim.
 * Released under the MIT License:
 * KoboldAid/licenses/KoboldKitFree.License.txt
 */


#import "KKFramework.h"
#import "KKTilemapObjectSpawnDelegate.h"

@interface KKEmitterNode : SKEmitterNode <KKTilemapObjectSpawnDelegate>

+(id) emitterWithFile:(NSString*)file;

@end
