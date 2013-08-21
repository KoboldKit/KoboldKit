//
//  SKNode+KoboldKitPro.h
//  KoboldKitPro
//
//  Created by Steffen Itterheim on 21.08.13.
//  Copyright (c) 2013 Steffen Itterheim. All rights reserved.
//

#import "KKFramework.h"

@class KKEntity;

@interface SKNode (KoboldKitPro)

@property (nonatomic) KKTilemapObject* tilemapObject;
@property (nonatomic) KKEntity* entity;

@end
