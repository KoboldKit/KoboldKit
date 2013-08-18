//
//  MyScene.h
//  KoboldKitDemo
//

//  Copyright (c) 2013 Steffen Itterheim. All rights reserved.
//

@class PlayerCharacter;

@interface GameScene : KKScene
{
	KKSpriteNode* _curtainSprite;
	PlayerCharacter* _playerCharacter;
	KKTilemapNode* _tilemapNode;

	CGPoint rayStart;
	CGPoint rayEnd;
}

@property (atomic, copy) NSString* tmxFile;
@property (atomic, copy) NSString* spawnAtCheckpoint;

@end
