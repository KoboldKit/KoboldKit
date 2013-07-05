//
//  MyScene.h
//  KoboldKitDemo
//

//  Copyright (c) 2013 Steffen Itterheim. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "KoboldKit.h"

@class MyLabelNode;

@interface GameScene : KKScene
{
	KKSpriteNode* _curtainSprite;
	KKSpriteNode* _playerCharacter;
	KKTilemapNode* _tilemapNode;

	CGPoint _currentControlPadDirection;
	
	CGFloat _jumpForce;
	CGFloat _dpadForce;
}

@property (atomic, copy) NSString* tmxFile;

@end
