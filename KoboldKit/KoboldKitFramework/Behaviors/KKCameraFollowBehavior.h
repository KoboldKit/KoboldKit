//
//  KKCameraFollowsBehavior.h
//  KoboldKit
//
//  Created by Steffen Itterheim on 22.06.13.
//  Copyright (c) 2013 Steffen Itterheim. All rights reserved.
//

#import "KKBehavior.h"

/** Makes the "camera" follow the node owning this behavior.
 The scrollingNode should be the scrolling world.
 The scene's anchorPoint should be at {0.5, 0.5} to center the behavior node on the screen/window. */
@interface KKCameraFollowBehavior : KKBehavior

/** The scrolling node whose position should be updated based on the behavior node's position. */
@property (atomic, weak) SKNode* scrollingNode;

@end
