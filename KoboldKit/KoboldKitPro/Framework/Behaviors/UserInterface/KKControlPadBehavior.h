/*
 * Copyright (c) 2013 Steffen Itterheim.
 * Released under a PROPRIETARY License:
 * KoboldKit/KoboldKitPro/KoboldKitPro.License.txt
 */

#import "KKBehavior.h"
#import "KKArcadeInputState.h"

/** Notification name, sent by KKControlPadBehavior when button should execute its action. */
extern NSString* const KKControlPadDidChangeDirectionNotification;

/** Emulates a digital control pad (d-pad), updates its node with textures based on the direction.
 Sends a KKControlPadDidChangeDirection notification every time direction changes.
 
 @warning *Caution:* Only works on SKSpriteNode classes! */
@interface KKControlPadBehavior : KKBehavior
{
	@private
	NSUInteger _trackedTouch;
	NSArray* _textures;
	int _directionsCount;
}

/** Deadzone defines the radius around the d-pad center where no direction change occurs. Defaults to 10 points. */
@property (atomic) CGFloat deadZone;

/** The D-Pad direction, in KTArcadeInputState directions (using player 1 states). */
@property (atomic, readonly) KKArcadeInputState direction;

/** For 2-way dpads specifies that the layout is vertical (up/down) instead of the default horizontal (left/right) layout. */
@property (atomic) BOOL vertical;

/** Initializes a control pad behavior with either 4 or 8 d-pad directional textures. Start with the texture for "right button pressed"
 and continue adding textures in counter-clockwise order (ie "upper right button pressed", "up button pressed", and so on).
 The "idle" state is the texture the sprite has been initialized with.
 @param textures The textures to use for the different dpad directional states.
 @returns A new instance. */
+(id) controlPadBehaviorWithTextures:(NSArray*)textures;

@end
