//
//  PlayerCharacter.h
//  KoboldKit
//
//  Created by Steffen Itterheim on 10.07.13.
//  Copyright (c) 2013 Steffen Itterheim. All rights reserved.
//

#import <KoboldKit/KoboldKit.h>

@interface PlayerCharacter : SKNode
{
@private
	SKSpriteNode* _playerSprite;

	// these values are Tiled-editable via properties of the same name
	CGPoint _currentControlPadDirection;
	CGFloat _jumpSpeedInitial;
	CGFloat _jumpSpeedDeceleration;
	CGFloat _jumpAbortVelocity;
	CGFloat _fallSpeedAcceleration;
	CGFloat _fallSpeedLimit;
	CGFloat _runSpeedAcceleration;
	CGFloat _runSpeedDeceleration;
	CGFloat _runSpeedLimit;

	__weak KKButtonBehavior* _jumpButton;

	BOOL _running;
	BOOL _jumping;
}

-(void) setupWithPlayerObject:(KKTilemapObject*)playerObject movementBounds:(CGRect)movementBounds;

-(void) controlPadDidChangeDirection:(NSNotification*)note;
-(void) attackButtonPressed:(NSNotification*)note;
-(void) jumpButtonPressed:(NSNotification*)note;
-(void) jumpButtonReleased:(NSNotification*)note;

@end
