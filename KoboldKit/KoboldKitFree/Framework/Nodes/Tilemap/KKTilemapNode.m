/*
 * Copyright (c) 2012-2013 Steffen Itterheim.
 * Released under the MIT License:
 * KoboldAid/licenses/KoboldKitFree.License.txt
 */

#import "KKTilemapNode.h"
#import "KKTilemapTileLayerNode.h"
#import "KKTilemapObjectLayerNode.h"
#import "KKTilemap.h"
#import "KKTilemapLayer.h"
#import "KKTilemapObject.h"
#import "KKTilemapTileset.h"
#import "KKTilemapProperties.h"
#import "SKNode+KoboldKit.h"
#import "KKFollowTargetBehavior.h"
#import "KKLimitBoundsBehavior.h"
#import "KKIntegerArray.h"
#import "KKMutableNumber.h"
#import "KKView.h"
#import "KKScene.h"
#import "KKModel.h"
#import "KKClassVarSetter.h"

@implementation KKTilemapNode

#pragma mark Init/Setup

+(id) tilemapWithContentsOfFile:(NSString*)tmxFile
{
	return [[self alloc] initWithContentsOfFile:tmxFile];
}

-(id) initWithContentsOfFile:(NSString*)tmxFile
{
	self = [super init];
	if (self)
	{
		self.name = tmxFile;
		_tilemap = [KKTilemap tilemapWithContentsOfFile:tmxFile];
		_tileLayerNodes = [NSMutableArray arrayWithCapacity:4];
		_objectLayerNodes = [NSMutableArray arrayWithCapacity:4];
	}
	return self;
}

-(void) didMoveToParent
{
	if (self.children.count == 0)
	{
		[self observeSceneEvents];
		
		self.scene.backgroundColor = _tilemap.backgroundColor;
		
		KKTilemapTileLayerNode* tileLayerNode = nil;
		
		for (KKTilemapLayer* layer in _tilemap.layers)
		{
			if (layer.isTileLayer)
			{
				tileLayerNode = [KKTilemapTileLayerNode tileLayerNodeWithLayer:layer];
				tileLayerNode.alpha = layer.alpha;
				tileLayerNode.tilemapNode = self;
				[self addChild:tileLayerNode];
				[_tileLayerNodes addObject:tileLayerNode];
			}
			else
			{
				KKTilemapObjectLayerNode* objectLayerNode = [KKTilemapObjectLayerNode objectLayerNodeWithLayer:layer];
				objectLayerNode.zPosition = -1;
				objectLayerNode.tilemapNode = self;
				
				NSAssert1(tileLayerNode, @"can't add object layer '%@' because no tile layer precedes it", layer.name);
				[tileLayerNode addChild:objectLayerNode];
				[_objectLayerNodes addObject:objectLayerNode];
			}
		}
		
		_mainTileLayerNode = [self findMainTileLayerNode];
		_gameObjectsLayerNode = [self findGameObjectsLayerNode];
	}
}

-(void) enableParallaxScrolling
{
	// parallaxing behavior
	KKFollowTargetBehavior* parallaxBehavior = [KKFollowTargetBehavior followTarget:_mainTileLayerNode];
	for (KKTilemapLayerNode* layerNode in _tileLayerNodes)
	{
		if (layerNode != _gameObjectsLayerNode)
		{
			parallaxBehavior.positionMultiplier = layerNode.layer.parallaxFactor;
			[layerNode addBehavior:[parallaxBehavior copy] withKey:NSStringFromClass([KKFollowTargetBehavior class])];
		}
	}
}

-(void) restrictScrollingToMapBoundary
{
	// camera boundary scrolling
	KKTilemapLayer* mainTileLayer = _mainTileLayerNode.layer;
	if (mainTileLayer.endlessScrollingHorizontal == NO || mainTileLayer.endlessScrollingVertical == NO)
	{
		CGRect cameraBounds = self.bounds;
		CGRect sceneFrame = self.scene.frame;
		
		if (mainTileLayer.endlessScrollingHorizontal == NO)
		{
			cameraBounds.origin.x = -cameraBounds.size.width + sceneFrame.origin.x + sceneFrame.size.width;
			cameraBounds.size.width = cameraBounds.size.width - sceneFrame.size.width;
		}
		if (mainTileLayer.endlessScrollingVertical == NO)
		{
			cameraBounds.origin.y = -cameraBounds.size.height + sceneFrame.origin.y + sceneFrame.size.height;
			cameraBounds.size.height = cameraBounds.size.height - sceneFrame.size.height;
		}

		//NSLog(@"Tilemap scrolling bounds: %@", NSStringFromCGRect(cameraBounds));
		NSString* const kMapBoundaryBehaviorKey = @"KKTilemapNode:MapBoundaryScrolling";
		if ([_mainTileLayerNode behaviorForKey:kMapBoundaryBehaviorKey] == nil)
		{
			[_mainTileLayerNode addBehavior:[KKLimitBoundsBehavior stayInBounds:cameraBounds] withKey:kMapBoundaryBehaviorKey];
		}
	}
}

-(void) restrictScrollingToObject:(KKTilemapRectangleObject*)object
{
	// camera boundary scrolling
	KKTilemapLayer* mainTileLayer = _mainTileLayerNode.layer;
	if (mainTileLayer.endlessScrollingHorizontal == NO || mainTileLayer.endlessScrollingVertical == NO)
	{
		CGRect sceneFrame = self.scene.frame;
		CGRect objectRect = object.rect;
		CGRect cameraBounds = CGRectZero;
		
		if (mainTileLayer.endlessScrollingHorizontal == NO)
		{
			cameraBounds.origin.x = -(objectRect.origin.x + objectRect.size.width) + sceneFrame.origin.x + sceneFrame.size.width;
			cameraBounds.size.width = objectRect.size.width - sceneFrame.size.width;
		}
		if (mainTileLayer.endlessScrollingVertical == NO)
		{
			cameraBounds.origin.y = -(objectRect.origin.y + objectRect.size.height) + sceneFrame.origin.y + sceneFrame.size.height;
			cameraBounds.size.height = objectRect.size.height - sceneFrame.size.height;
		}
		
		//NSLog(@"Tilemap scrolling bounds: %@", NSStringFromCGRect(cameraBounds));
		NSString* const kMapBoundaryBehaviorKey = @"KKTilemapNode:MapBoundaryScrolling";
		if ([_mainTileLayerNode behaviorForKey:kMapBoundaryBehaviorKey] == nil)
		{
			[_mainTileLayerNode addBehavior:[KKLimitBoundsBehavior stayInBounds:cameraBounds] withKey:kMapBoundaryBehaviorKey];
		}
	}
}

#pragma mark Position

-(void) setPosition:(CGPoint)position
{
	[super setPosition:position];
	
	_mainTileLayerNode.position = ccpMult(position, 1);
	_tilemap.modified = YES;
}

#pragma mark Update

-(void) didSimulatePhysics
{
	for (KKTilemapTileLayerNode* tileLayerNode in _tileLayerNodes)
	{
		[tileLayerNode updateLayer];
	}
	
	_tilemap.modified = NO;
}

#pragma mark Main Layer

-(KKTilemapTileLayerNode*) findMainTileLayerNode
{
	KKTilemapTileLayerNode* mainTileLayerNode = [self tileLayerNodeNamed:@"main layer"];
	if (mainTileLayerNode == nil)
	{
		mainTileLayerNode = [self tileLayerNodeNamed:@"mainlayer"];
	}
	
	NSAssert(mainTileLayerNode, @"tile layer named 'main layer' is missing!");
	return mainTileLayerNode;
}

-(KKTilemapObjectLayerNode*) findGameObjectsLayerNode
{
	KKTilemapObjectLayerNode* gameObjectsLayerNode = [self objectLayerNodeNamed:@"game objects"];
	if (gameObjectsLayerNode == nil)
	{
		gameObjectsLayerNode = [self objectLayerNodeNamed:@"gameobjects"];
	}
	
	NSAssert(gameObjectsLayerNode, @"object layer named 'game objects' is missing!");
	return gameObjectsLayerNode;
}

#pragma mark Layers

-(KKTilemapTileLayerNode*) tileLayerNodeNamed:(NSString*)name
{
	for (KKTilemapTileLayerNode* tileLayerNode in _tileLayerNodes)
	{
		if ([tileLayerNode.name isEqualToString:name])
		{
			return tileLayerNode;
		}
	}
	
	return nil;
}

-(KKTilemapObjectLayerNode*) objectLayerNodeNamed:(NSString*)name
{
	for (KKTilemapObjectLayerNode* objectLayerNode in _objectLayerNodes)
	{
		if ([objectLayerNode.name isEqualToString:name])
		{
			return objectLayerNode;
		}
	}
	
	return nil;
}

#pragma mark Objects

-(KKTilemapObject*) objectNamed:(NSString*)name
{
	for (KKTilemapObjectLayerNode* objectLayerNode in _objectLayerNodes)
	{
		for (KKTilemapObject* object in objectLayerNode.layer.objects)
		{
			if ([object.name isEqualToString:name])
			{
				return object;
			}
		}
	}
	return nil;
}

#pragma mark Bounds

@dynamic bounds;
-(CGRect) bounds
{
	CGRect bounds = CGRectMake(INFINITY, INFINITY, INFINITY, INFINITY);
	KKTilemapLayer* mainLayer = _mainTileLayerNode.layer;
	if (mainLayer.endlessScrollingHorizontal == NO)
	{
		bounds.origin.x = 0.0;
		bounds.size.width = _tilemap.size.width * _tilemap.gridSize.width;
	}
	if (mainLayer.endlessScrollingVertical == NO)
	{
		bounds.origin.y = 0.0;
		bounds.size.height = _tilemap.size.height * _tilemap.gridSize.height;
	}
	return bounds;
}

@end
