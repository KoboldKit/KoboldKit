/*
 * Copyright (c) 2013 Steffen Itterheim.
 * Released under a PROPRIETARY License:
 * Super_Stick_Spy/SuperStickSpy.License.txt
 */


@class KKEntity;

@interface PlayerCharacter : KKNode
{
@private
	__weak KKTilemapObject* _tilemapPlayerObject;
	KKSpriteNode* _playerSprite;
	KKEntity* _entity;

	// these values are Tiled-editable via properties of the same name
	CGPoint _respawnPosition;
	CGVector _currentControlPadDirection;
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
