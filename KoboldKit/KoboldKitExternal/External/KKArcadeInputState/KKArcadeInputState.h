/*
 Copyright (C) 2011-2012 by Stuart Carnie
 Copyright (C) 2012 by Cascadia Games LLC
 Copyright (C) 2013 by Steffen Itterheim
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 */

#import "CGVectorExtension.h"

/** @file KKArcadeInputState.h */

// The original joystick/button enum values are from:
// iCade https://github.com/scarnie/iCade-iOS/tree/master/iCadeTest/iCade and GameDock SDK, both MIT licensed.
// There are several additions for KoboldTouch / Kobold Kit.


/** Defines the button/joystick states of arcade controllers like GameDock, iCade. Gamedock supports 1 or 2 players, iCade only uses the first player's states. */
typedef enum
{
	KKArcadeJoystickNone       = 0x000, /**< joystick in "idle" position */
	KKArcadeJoystickUp         = 0x001, /**< straight up */
	KKArcadeJoystickRight      = 0x002, /**< straight right */
	KKArcadeJoystickDown       = 0x004, /**< straight down */
	KKArcadeJoystickLeft       = 0x008, /**< straight left */
	
	KKArcadeJoystickUpRight    = KKArcadeJoystickUp   | KKArcadeJoystickRight, /**< diagonal: up and right */
	KKArcadeJoystickDownRight  = KKArcadeJoystickDown | KKArcadeJoystickRight, /**< diagonal: down and right */
	KKArcadeJoystickUpLeft     = KKArcadeJoystickUp   | KKArcadeJoystickLeft, /**< diagonal: up and left */
	KKArcadeJoystickDownLeft   = KKArcadeJoystickDown | KKArcadeJoystickLeft, /**< diagonal: down and left */
	
	KKArcadeButtonA            = 0x010, /**< button A (iCade: button 5) */
	KKArcadeButtonB            = 0x020, /**< button B (iCade: button 6) */
	KKArcadeButtonC            = 0x040, /**< button C (iCade: button 7) */
	KKArcadeButtonD            = 0x080, /**< button D (iCade: button 8) */
	KKArcadeButtonE            = 0x100, /**< button E (iCade: button 9) */
	KKArcadeButtonF            = 0x200, /**< button F (iCade: button 0) */
	KKArcadeButtonG            = 0x400, /**< button G (iCade: button E1) */
	KKArcadeButtonH            = 0x800, /**< button H (iCade: button E2) */
	
	KKArcadeButtonMask          = KKArcadeButtonA | KKArcadeButtonB | KKArcadeButtonC | KKArcadeButtonD | KKArcadeButtonE | KKArcadeButtonF | KKArcadeButtonG | KKArcadeButtonH, /**< mask: all player 1 buttons */
	KKArcadeJoystickMask        = KKArcadeJoystickUp | KKArcadeJoystickRight | KKArcadeJoystickDown | KKArcadeJoystickLeft | KKArcadeJoystickUpRight | KKArcadeJoystickDownRight | KKArcadeJoystickUpLeft | KKArcadeJoystickDownLeft, /**< mask: all player 1 joystick directions */
	KKArcadeInputPlayer1Mask    = KKArcadeJoystickMask | KKArcadeButtonMask, /**< mask: all player 1 input states */
	
	KKArcadeJoystick2None       = 0x000000, /**< player 2: joystick in "idle" position */
	KKArcadeJoystick2Up         = 0x001000, /**< player 2: straight up */
	KKArcadeJoystick2Right      = 0x002000, /**< player 2: straight right */
	KKArcadeJoystick2Down       = 0x004000, /**< player 2: straight down */
	KKArcadeJoystick2Left       = 0x008000, /**< player 2: straight left */
	
	KKArcadeJoystick2UpRight    = KKArcadeJoystick2Up   | KKArcadeJoystick2Right, /**< player 2 diagonal: up and right */
	KKArcadeJoystick2DownRight  = KKArcadeJoystick2Down | KKArcadeJoystick2Right, /**< player 2 diagonal: down and right */
	KKArcadeJoystick2UpLeft     = KKArcadeJoystick2Up   | KKArcadeJoystick2Left, /**< player 2 diagonal: up and left */
	KKArcadeJoystick2DownLeft   = KKArcadeJoystick2Down | KKArcadeJoystick2Left, /**< player 2 diagonal: down and left */
	
	KKArcadeButton2A            = 0x010000, /**< player 2: button A */
	KKArcadeButton2B            = 0x020000, /**< player 2: button B */
	KKArcadeButton2C            = 0x040000, /**< player 2: button C */
	KKArcadeButton2D            = 0x080000, /**< player 2: button D */
	KKArcadeButton2E            = 0x100000, /**< player 2: button E */
	KKArcadeButton2F            = 0x200000, /**< player 2: button F */
	KKArcadeButton2G            = 0x400000, /**< player 2: button G */
	KKArcadeButton2H            = 0x800000, /**< player 2: button H */
	
	KKArcadeButton2Mask         = KKArcadeButton2A | KKArcadeButton2B | KKArcadeButton2C | KKArcadeButton2D | KKArcadeButton2E | KKArcadeButton2F | KKArcadeButton2G | KKArcadeButton2H, /**< mask: all player 2 buttons */
	KKArcadeJoystick2Mask       = KKArcadeJoystick2Up | KKArcadeJoystick2Right | KKArcadeJoystick2Down | KKArcadeJoystick2Left | KKArcadeJoystick2UpRight | KKArcadeJoystick2DownRight | KKArcadeJoystick2UpLeft | KKArcadeJoystick2DownLeft, /**< mask: all player 2 joystick directions */
	KKArcadeInputPlayer2Mask    = KKArcadeJoystick2Mask | KKArcadeButton2Mask, /**< mask: all player 2 input states */
} KKArcadeInputState;

/** Returns a unit vector pointing in the joystick direction of the given player (1 or 2). */
CG_INLINE CGVector vectorFromJoystickStateAndPlayer(KKArcadeInputState state, NSUInteger player)
{
	state = (KKArcadeInputState)(state & (player == 2 ? KKArcadeJoystick2Mask : KKArcadeJoystickMask));
	switch (state)
	{
		case KKArcadeJoystickRight:
			return CGVectorMake(1.0, 0.0);
		case KKArcadeJoystickUpRight:
			return CGVectorMake(0.70710678118655, 0.70710678118655);
		case KKArcadeJoystickUp:
			return CGVectorMake(0.0, 1.0);
		case KKArcadeJoystickUpLeft:
			return CGVectorMake(-0.70710678118655, 0.70710678118655);
		case KKArcadeJoystickLeft:
			return CGVectorMake(-1.0, 0.0);
		case KKArcadeJoystickDownLeft:
			return CGVectorMake(-0.70710678118655, -0.70710678118655);
		case KKArcadeJoystickDown:
			return CGVectorMake(0.0, -1.0);
		case KKArcadeJoystickDownRight:
			return CGVectorMake(0.70710678118655, -0.70710678118655);
		default:
			return CGVectorZero;
	}
}

/** Returns a unit vector pointing in the joystick direction of player 1. */
CG_INLINE CGVector vectorFromJoystickState(KKArcadeInputState state)
{
	return vectorFromJoystickStateAndPlayer(state, 1);
}
