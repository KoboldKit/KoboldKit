//
//  KKViewOriginNode.h
//  KoboldKit
//
//  Created by Steffen Itterheim on 26.06.13.
//  Copyright (c) 2013 Steffen Itterheim. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "KKSpriteKit.h"
#import "KKNode.h"

/** Children of this node will always have their origin at the lower left corner of the view,
 regardless of the scene's anchorPoint. This class is mainly used to keep HUD elements
 in a scrolling world fixed on the screen using the view's coordinate system. */
@interface KKViewAnchorNode : KKNode

-(void) updatePositionFromSceneFrame;

@end
