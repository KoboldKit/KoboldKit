//
//  KKNode+Related.h
//  KoboldKit
//
//  Created by Steffen Itterheim on 18.06.13.
//  Copyright (c) 2013 Steffen Itterheim. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>


/** In Kobold Kit KKNode must be used in place of SKNode to ensure that KK messaging works (ie didMoveToParent, willMoveFromParent, etc). */
@interface KKNode : SKNode


@end
