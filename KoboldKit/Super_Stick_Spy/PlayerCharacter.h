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
	__weak KKTilemapObject* _tilemapPlayerObject;
	KKSpriteNode* _playerSprite;

	// these values are Tiled-editable via properties of the same name
	CGPoint _respawnPosition;
	CGPoint _currentControlPadDirection;
	CGSize _boundingBox;
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
	BOOL _onFloor;
}

@property (atomic) CGPoint anchorPoint;

-(void) controlPadDidChangeDirection:(NSNotification*)note;
-(void) jumpButtonPressed:(NSNotification*)note;
-(void) jumpButtonReleased:(NSNotification*)note;

-(void) die;
-(void) setCheckpoint:(KKTilemapObject*)checkpointObject;
-(void) moveToCheckpoint;

@end
