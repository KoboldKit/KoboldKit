//
//  KKCameraFollowsBehavior.h
//  KoboldKit
//
//  Created by Steffen Itterheim on 22.06.13.
//  Copyright (c) 2013 Steffen Itterheim. All rights reserved.
//

#import "KKNodeBehavior.h"

/** Makes the "camera" follow this node. The node's parent should be the scrolling world, the scene's anchorPoint should be
 at 0.5,0.5 if you want to center on the node. */
@interface KKCameraFollowBehavior : KKNodeBehavior

@end
