/*
 * Copyright (c) 2013 Steffen Itterheim.
 * Released under the MIT License:
 * KoboldAid/licenses/KoboldKitFree.License.txt
 */

#import "KKBehavior.h"

/** Makes the "camera" follow the node owning this behavior.
 The scrollingNode should be the scrolling world.
 The scene's anchorPoint should be at {0.5, 0.5} to center the behavior node on the screen/window. */
@interface KKCameraFollowBehavior : KKBehavior <KKSceneEventDelegate>

/** The scrolling node whose position should be updated based on the behavior node's position. */
@property (atomic, weak) SKNode* scrollingNode;

@end
