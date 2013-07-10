//
//  MyScene.h
//  KoboldKitDemo
//

//  Copyright (c) 2013 Steffen Itterheim. All rights reserved.
//

#import <KoboldKit/KoboldKit.h>

@class PlayerCharacter;

@interface GameScene : KKScene
{
	KKSpriteNode* _curtainSprite;
	PlayerCharacter* _playerCharacter;
	KKTilemapNode* _tilemapNode;

	//KKPhysicsDebugNode* _physicsContactDebugNode;
	
	CGPoint rayStart;
	CGPoint rayEnd;
}

@property (atomic, copy) NSString* tmxFile;

@end
