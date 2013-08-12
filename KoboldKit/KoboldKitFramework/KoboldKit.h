//
//  KoboldKit.h
//  KoboldKitDemo
//
//  Created by Steffen Itterheim on 13.06.13.
//  Copyright (c) 2013 Steffen Itterheim. All rights reserved.
//

// GLOBAL HEADER IMPORTS

// headers
#import "KKCompatibility.h"
#import "KKVersion.h"
#import "KKMacros.h"
#import "KKTypes.h"
#import "KKArcadeInputState.h"
#import "KKSceneEventDelegate.h"
#import "KKPhysicsContactEventDelegate.h"

// Sprite Kit categories
#import "SKNode+KoboldKit.h"
#import "SKScene+KoboldKit.h"
#import "SKAction+KoboldKit.h"

// subclasses
#import "KKAppDelegate.h"
#import "KKViewController.h"
#import "KKView.h"
#import "KKNode.h"
#import "KKScene.h"
#import "KKSpriteNode.h"
#import "KKLabelNode.h"
#import "KKEmitterNode.h"
#import "KKViewOriginNode.h"

// framework
#import "KKNodeController.h"
#import "KKModel.h"
#import "KKBehavior.h"

// behaviors
#import "KKButtonBehavior.h"
#import "KKFollowTargetBehavior.h"
#import "KKControlPadBehavior.h"
#import "KKCameraFollowBehavior.h"
#import "KKStayInBoundsBehavior.h"
#import "KKLimitVelocityBehavior.h"
#import "KKRemoveOnContactBehavior.h"
#import "KKPickupItemBehavior.h"
#import "KKItemCollectorBehavior.h"
#import "KKNotifyOnItemCountBehavior.h"
#import "KKRemoveOnNotificationBehavior.h"

// tilemap model
#import "KKTilemap.h"
#import "KKTilemapLayer.h"
#import "KKTilemapLayerContourTracer.h"
#import "KKTilemapLayerTiles.h"
#import "KKTilemapObject.h"
#import "KKTilemapProperties.h"
#import "KKTilemapTileProperties.h"
#import "KKTilemapTileset.h"
#import "KKTMXReader.h"
#import "KKTMXWriter.h"

// tilemap nodes
#import "KKTilemapNode.h"
#import "KKTilemapTileLayerNode.h"
#import "KKTilemapObjectLayerNode.h"

// addons
#import "KKMutableNumber.h"
#import "KKIntegerArray.h"
#import "KKPointArray.h"
#import "KKDownloadProjectFiles.h"
#import "KKLua.h"
#import "KKClassVarSetter.h"

// NS* categories
#import "NSCoder+KoboldKit.h"
#import "NSDictionary+KoboldKit.h"
#import "NSBundle+KoboldKit.h"
#import "NSObject+KoboldKit.h"
#import "NSString+KoboldKit.h"

// external
#import "Reachability.h"
#import "CGPointExtension.h"
#import "VTPG_Common.h"
#import "XMLWriter.h"
#import "ZipUtils.h"
#import "SKTAudio.h"
#import "SKTUtils.h"
#import "CCProfiling.h"
