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

	CGPoint _currentControlPadDirection;
	CGFloat _jumpSpeedInitial;
	CGFloat _jumpSpeedDeceleration;
	CGFloat _fallSpeedAcceleration;
	CGFloat _fallSpeedLimit;
	CGFloat _runSpeedAcceleration;
	CGFloat _runSpeedDeceleration;
	CGFloat _runSpeedLimit;
	
	BOOL _running;
	BOOL _jumping;
}

-(void) setupWithPlayerObject:(KKTilemapObject*)playerObject movementBounds:(CGRect)movementBounds;

@end
