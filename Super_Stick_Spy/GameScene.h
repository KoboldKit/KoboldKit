/*
 * Copyright (c) 2013 Steffen Itterheim.
 * Released under a PROPRIETARY License:
 * Super_Stick_Spy/SuperStickSpy.License.txt
 */


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
