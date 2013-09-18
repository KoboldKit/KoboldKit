/*
 * Copyright (c) 2013 Steffen Itterheim.
 * Released under the MIT License:
 * KoboldAid/licenses/KoboldKitFree.License.txt
 */


#import "KKFramework.h"
#import "KKNode.h"

/** Children of this node will always have their origin at the lower left corner of the view,
 regardless of the scene's anchorPoint. This class is mainly used to keep HUD elements
 in a scrolling world fixed on the screen because the origin (0,0) is fixed to the lower left corner.
 
 @Caution: This node must be a added as child to a KKScene object for it to work. */
@interface KKViewOriginNode : KKNode

// internal use only, called by scene's setAnchorPoint: method
-(void) updatePositionFromSceneFrame;

@end
