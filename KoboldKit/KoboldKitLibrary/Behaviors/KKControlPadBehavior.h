//
//  KKControlPadBehavior.h
//  KoboldKit
//
//  Created by Steffen Itterheim on 21.06.13.
//  Copyright (c) 2013 Steffen Itterheim. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KKNodeBehavior.h"
#import "KKArcadeInputState.h"

/** Notification name, sent by KKControlPadBehavior when button should execute its action. */
extern NSString* const KKControlPadDidChangeDirection;

/** Emulates a digital control pad (d-pad), updates its node with textures based on the direction.
 Sends a KKControlPadDidChangeDirection notification every time direction changes.
 
 @warning *Caution:* Only works on SKSpriteNode classes! */
@interface KKControlPadBehavior : KKNodeBehavior
{
	@private
	__weak UITouch* _trackedTouch;
	NSArray* _textures;
	BOOL _allowDiagonalDirections;
}

/** Deadzone defines the radius around the d-pad center where no direction change occurs. Defaults to 8 points. */
@property (atomic) CGFloat deadZone;

/** The D-Pad direction, in KTArcadeInputState directions (using player 1 states). */
@property (nonatomic, readonly) KKArcadeInputState direction;

/** Initializes a control pad behavior with either 4 or 8 d-pad directional textures. Start with the texture for "right button pressed"
 and continue adding textures in counter-clockwise order (ie "upper right button pressed", "up button pressed", and so on).
 The "idle" state is the texture the sprite has been initialized with. */
+(id) controlPadBehaviorWithTextures:(NSArray*)textures;

@end
