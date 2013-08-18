//
//  KKEmitterNode.h
//  KoboldKit
//
//  Created by Steffen Itterheim on 03.08.13.
//  Copyright (c) 2013 Steffen Itterheim. All rights reserved.
//

#import "KKFramework.h"
#import "KKTilemapObjectSpawnDelegate.h"

@interface KKEmitterNode : SKEmitterNode <KKTilemapObjectSpawnDelegate>

+(id) emitterWithFile:(NSString*)file;

@end
