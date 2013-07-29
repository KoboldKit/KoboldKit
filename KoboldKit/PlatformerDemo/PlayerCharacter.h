//
//  PlayerCharacter.h
//  KoboldKit
//
//  Created by Steffen Itterheim on 10.07.13.
//  Copyright (c) 2013 Steffen Itterheim. All rights reserved.
//

#import <KoboldKit/KoboldKit.h>

@interface PlayerCharacter : KKNode
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
	
	NSString* _defaultImage;

	__weak KKButtonBehavior* _jumpButton;

	BOOL _running;
	BOOL _jumping;
}

@property (atomic) BOOL running;
@property (atomic) float someFloat;
@property (atomic) int someInt;

@property (atomic) CGRect someRect;
@property (atomic) CGSize someSize;
@property (atomic) CGPoint somePoint;

-(void) controlPadDidChangeDirection:(NSNotification*)note;
-(void) attackButtonPressed:(NSNotification*)note;
-(void) jumpButtonPressed:(NSNotification*)note;
-(void) jumpButtonReleased:(NSNotification*)note;

@end
