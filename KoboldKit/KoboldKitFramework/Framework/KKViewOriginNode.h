//
//  KKViewOriginNode.h
//  KoboldKit
//
//  Created by Steffen Itterheim on 26.06.13.
//  Copyright (c) 2013 Steffen Itterheim. All rights reserved.
//

#import "KKCompatibility.h"
#import "KKNode.h"

/** Children of this node will always have their origin at the lower left corner of the view,
 regardless of the scene's anchorPoint. This class is mainly used to keep HUD elements
 in a scrolling world fixed on the screen with the origin (0,0) fixed to the lower left corner.
 
 @Caution: This node must be a added as child to a KKScene object. */
@interface KKViewOriginNode : KKNode

-(void) updatePositionFromSceneFrame;

@end
