//
//  KoboldKitLibraryTests.m
//  KoboldKitLibraryTests
//
//  Created by Steffen Itterheim on 13.06.13.
//  Copyright (c) 2013 Steffen Itterheim. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "KoboldKit.h"
#import "TestScene.h"

@interface KoboldKitLibraryTests : XCTestCase
{
	KKViewController* _viewController;
	KKScene* _testScene;
}
@end

@implementation KoboldKitLibraryTests

-(void) setUp
{
    [super setUp];
    
	CGRect frame = CGRectMake(0, 0, 480, 320);
	
    // Set-up code here.
	_viewController = [[KKViewController alloc] init];
	_viewController.view = [[KKView alloc] initWithFrame:frame];
	[_viewController viewDidLoad];
	
	_testScene = [TestScene sceneWithSize:frame.size];
    _testScene.scaleMode = SKSceneScaleModeAspectFill;
    [_viewController.kkView presentScene:_testScene];
}

-(void) tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

-(void) testSceneExists
{
	XCTAssertNotNil(_testScene, @"test scene is nil");
}

-(void) testArchiveScene
{
	NSData* sceneArchive = [NSKeyedArchiver archivedDataWithRootObject:_testScene];
	KKScene* decodedScene = [NSKeyedUnarchiver unarchiveObjectWithData:sceneArchive];

	BOOL isEqual = [_testScene isEqualToSceneTree:decodedScene];
	if (isEqual == NO)
	{
		NSString* testSceneDump = [_testScene dumpSceneGraph:KKSceneGraphDumpAll];
		NSString* decodedSceneDump = [decodedScene dumpSceneGraph:KKSceneGraphDumpAll];
		LOG_EXPR(testSceneDump);
		LOG_EXPR(decodedSceneDump);
	}
	
	XCTAssertTrue(isEqual, @"test scene and decoded scene are different, check log for details");
}

-(void) testCopyScene
{
	KKScene* copiedScene = [_testScene copy];
	
	BOOL isEqual = [_testScene isEqualToSceneTree:copiedScene];
	if (isEqual == NO)
	{
		NSString* testSceneDump = [_testScene dumpSceneGraph:KKSceneGraphDumpAll];
		NSString* copiedSceneDump = [copiedScene dumpSceneGraph:KKSceneGraphDumpAll];
		LOG_EXPR(testSceneDump);
		LOG_EXPR(copiedSceneDump);
	}
	
	XCTAssertTrue(isEqual, @"test scene and copied scene are different, check log for details");
}

-(void) testTilemap
{
	KKTilemap* tilemap = [KKTilemap tilemapWithContentsOfFile:@"crawl-tilemap.tmx"];
	XCTAssertNotNil(tilemap, @"tilemap is nil");
	XCTAssertEquals(tilemap.orientation, KKTilemapOrientationOrthogonal, @"tilemap orientation mismatch");
	XCTAssertNotNil([tilemap.layers lastObject], @"tilemap has no layers");
	XCTAssertNotNil([tilemap.tilesets lastObject], @"tilemap has no tilesets");
	
	for (KKTilemapLayer* layer in tilemap.layers)
	{
		if (layer.isTileLayer)
		{
			XCTAssertNotNil(layer.tiles, @"tile layer has no tiles");
		}
	}
	
	for (KKTilemapTileset* tileset in tilemap.tilesets)
	{
		XCTAssertNotNil(tileset.texture, @"tileset texture is nil / could not be loaded");
		XCTAssertEquals(tileset.tileTextures.count - 1, tileset.lastGid - tileset.firstGid, @"tileset texture count mismatch");
	}
}

@end
