//
//  KoboldKit.h
//  KoboldKitDemo
//
//  Created by Steffen Itterheim on 13.06.13.
//  Copyright (c) 2013 Steffen Itterheim. All rights reserved.
//

// GLOBAL HEADER IMPORTS

// headers
#import "KKVersion.h"
#import "KKSpriteKit.h"
#import "KKMacros.h"
#import "KKTypes.h"

// categories
#import "SKNode+KoboldKit.h"
#import "SKAction+KoboldKit.h"

// subclasses
#import "KKViewController.h"
#import "KKView.h"
#import "KKScene.h"

// framework
#import "KKNodeController.h"
#import "KKNodeModel.h"
#import "KKNodeBehavior.h"

// behaviors
#import "KKButtonBehavior.h"

// tilemap
#import "KTTilemap.h"
#import "KTTilemapLayer.h"
#import "KTTilemapLayerTiles.h"
#import "KTTilemapObject.h"
#import "KTTilemapProperties.h"
#import "KTTilemapTileProperties.h"
#import "KTTilemapTileset.h"
#import "KTTMXReader.h"
#import "KTTMXWriter.h"

// addons
#import "KKMutableNumber.h"
#import "NSCoder+KoboldKit.h"
#import "NSObject+KoboldKit.h"

// external
#import "CGPointExtension.h"
#import "VTPG_Common.h"
#import "XMLWriter.h"
#import "ZipUtils.h"

/** This class contains global helper functions. */
@interface KoboldKit : NSObject

/** @returns The absolute path to the file or nil if the file could not be found. */
+(NSString*) pathForBundleFile:(NSString*)file;

/** @returns The absolute path to the file. */
+(NSString*) pathForAppSupportFile:(NSString*)file;

/** @returns The absolute path to the file. */
+(NSString*) pathForDocumentsFile:(NSString*)file;

/** @returns The absolute path to the file. */
+(NSString*) pathForLibraryFile:(NSString*)file;

/** Searches for the file in the app support, documents and bundle directories (in this order) and returns the absolute path
 to the file where it was first found.
 @returns The absolute path to the file, or nil if the file could not be found. */
+(NSString*) searchPathsForFile:(NSString*)file;

@end
