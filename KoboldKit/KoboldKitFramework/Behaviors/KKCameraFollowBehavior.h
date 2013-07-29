//
//  KKCameraFollowsBehavior.h
//  KoboldKit
//
//  Created by Steffen Itterheim on 22.06.13.
//  Copyright (c) 2013 Steffen Itterheim. All rights reserved.
//

#import "KKBehavior.h"

/** Makes the "camera" follow the node owning this behavior.
 The behavior node's parent should be the scrolling world. 
 The scene's anchorPoint should be at {0.5, 0.5} to center the behavior node on the screen/window. */
@interface KKCameraFollowBehavior : KKBehavior

@end
