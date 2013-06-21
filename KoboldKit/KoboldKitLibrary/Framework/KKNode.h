//
//  KKNode+Related.h
//  KoboldKit
//
//  Created by Steffen Itterheim on 18.06.13.
//  Copyright (c) 2013 Steffen Itterheim. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>


// Stub Subclasses implementing common methods which can't be put in a category or swizzled.


@interface KKNode : SKNode

// internal use
+(void) sendChildrenWillMoveFromParentWithNode:(SKNode*)node;

@end
