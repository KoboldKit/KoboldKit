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

	//KKPhysicsDebugNode* _physicsContactDebugNode;
	
	CGPoint _currentControlPadDirection;
	
	CGFloat _jumpForce;
	CGFloat _dpadForce;
	
	CGPoint rayStart;
	CGPoint rayEnd;
}

@property (atomic, copy) NSString* tmxFile;

@end
