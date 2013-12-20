/*
 * Copyright (c) 2013 Steffen Itterheim.
 * Released under the MIT License:
 * KoboldAid/licenses/KoboldKitFree.License.txt
 */

#import "KKBehavior.h"

/** Prevents a node's position from passing over the bounds rectangle.
 (TODO: Optionally sends notifications when node comes in to contact with the bounds and when contact ends.) */
@interface KKLimitBoundsBehavior : KKBehavior <KKSceneEventDelegate>

/** @returns Bounds rect in scene coordinates. */
@property (nonatomic) CGRect bounds;

/** If either x/width or y/height are set to INFINITY then that axis will not check for bounds. Thus if the node
 should be able to move endlessly in horizontal direction but not outside the screen at the top or bottom,
 set bounds.size.width or bounds.origin.x to INFINITY.
 @param bounds The boundary rectangle.
 @returns An instance of the class. */
+(id) stayInBounds:(CGRect)bounds;

@end
