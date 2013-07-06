//
//  KKStaysInBoundsBehavior.h
//  KoboldKit
//
//  Created by Steffen Itterheim on 22.06.13.
//  Copyright (c) 2013 Steffen Itterheim. All rights reserved.
//

#import "KKNodeBehavior.h"

/** Prevents a node's position from passing over the bounds rectangle.
 (TODO: Optionally sends notifications when node comes in to contact with the bounds and when contact ends.) */
@interface KKStayInBoundsBehavior : KKNodeBehavior
{
	@private
	BOOL _nodeIsSprite;
}

/** @returns Bounds rect in scene coordinates. */
@property (atomic) CGRect bounds;

/** If either x/width or y/height are set to INFINITY then that axis will not check for bounds. Thus if the node
 should be able to move endlessly in horizontal direction but not outside the screen at the top or bottom,
 set bounds.size.width or bounds.origin.x to INFINITY.
 @param bounds The boundary rectangle.
 @returns An instance of the class. */
+(id) stayInBounds:(CGRect)bounds;

@end
