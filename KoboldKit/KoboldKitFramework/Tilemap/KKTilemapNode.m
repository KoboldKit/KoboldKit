//
//  KKTilemapNode.m
//  KoboldKit
//
//  Created by Steffen Itterheim on 18.06.13.
//  Copyright (c) 2013 Steffen Itterheim. All rights reserved.
//

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
#import "KKStayInBoundsBehavior.h"
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
		_tileLayerNodes = [NSMutableArray arrayWithCapacity:2];
		_objectLayerNodes = [NSMutableArray arrayWithCapacity:2];
	}
	return self;
}

-(void) didMoveToParent
{
	if (self.children.count == 0)
	{
		[self observeSceneEvents];
		
		self.scene.backgroundColor = _tilemap.backgroundColor;
		
		KKTilemapTileLayerNode* tileLayer = nil;
		
		for (KKTilemapLayer* layer in _tilemap.layers)
		{
			if (layer.isTileLayer)
			{
				tileLayer = [KKTilemapTileLayerNode tileLayerNodeWithLayer:layer];
				tileLayer.alpha = layer.alpha;
				[self addChild:tileLayer];
				[_tileLayerNodes addObject:tileLayer];
			}
			else
			{
				KKTilemapObjectLayerNode* objectLayer = [KKTilemapObjectLayerNode objectLayerNodeWithLayer:layer];
				objectLayer.zPosition = -1;
				NSAssert1(tileLayer, @"can't add object layer '%@' because no tile layer precedes it", layer.name);
				[tileLayer addChild:objectLayer];
				[_objectLayerNodes addObject:objectLayer];
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
			[layerNode addBehavior:parallaxBehavior withKey:NSStringFromClass([KKFollowTargetBehavior class])];
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

		NSLog(@"Tilemap scrolling bounds: %@", NSStringFromCGRect(cameraBounds));
		NSString* const kMapBoundaryBehaviorKey = @"KKTilemapNode:MapBoundaryScrolling";
		if ([_mainTileLayerNode behaviorForKey:kMapBoundaryBehaviorKey] == nil)
		{
			[_mainTileLayerNode addBehavior:[KKStayInBoundsBehavior stayInBounds:cameraBounds] withKey:kMapBoundaryBehaviorKey];
		}
	}
}

#pragma mark Position

-(void) setPosition:(CGPoint)position
{
	[super setPosition:position];
	
	_mainTileLayerNode.position = ccpMult(position, 1);
}

#pragma mark Update

-(void) didSimulatePhysics
{
	for (KKTilemapTileLayerNode* tileLayer in _tileLayerNodes)
	{
		[tileLayer updateLayer];
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

#pragma mark Collision

-(void) addGidStringComponents:(NSArray*)components toGidArray:(KKIntegerArray*)gidArray gidOffset:(gid_t)gidOffset
{
	for (NSString* range in components)
	{
		NSUInteger gidStart = 0, gidEnd = 0;
		NSArray* fromTo = [range componentsSeparatedByString:@"-"];
		if (fromTo.count == 1)
		{
			gidStart = [[fromTo firstObject] intValue];
			gidEnd = gidStart;
		}
		else
		{
			gidStart = [[fromTo firstObject] intValue];
			gidEnd = [[fromTo lastObject] intValue];
		}
		
		for (NSUInteger i = gidStart; i <= gidEnd; i++)
		{
			[gidArray addInteger:i + gidOffset - 1];
		}
	}
}

-(SKNode*) createPhysicsShapesWithTileLayerNode:(KKTilemapTileLayerNode*)tileLayerNode
{
	/*
	KKIntegerArray* blockingGids = [KKIntegerArray integerArrayWithCapacity:32];
	KKIntegerArray* nonBlockingGids = [KKIntegerArray integerArrayWithCapacity:32];
	for (KKTilemapTileset* tileset in _tilemap.tilesets)
	{
		id blocking = [tileset.properties.properties objectForKey:@"blockingTiles"];
		if ([blocking isKindOfClass:[KKMutableNumber class]])
		{
			[blockingGids addInteger:[blocking intValue]];
		}
		else if ([blocking isKindOfClass:[NSString class]])
		{
			NSString* blockingTiles = (NSString*)blocking;
			if (blockingTiles == nil || [[blockingTiles lowercaseString] isEqualToString:@"all"])
			{
				// assume all tiles are blocking
				for (gid_t gid = tileset.firstGid; gid <= tileset.lastGid; gid++)
				{
					[blockingGids addInteger:gid];
				}
			}
			else if (blockingTiles.length > 0)
			{
				NSArray* components = [blockingTiles componentsSeparatedByString:@","];
				[self addGidStringComponents:components toGidArray:blockingGids gidOffset:tileset.firstGid];
			}
		}

		id nonBlocking = [tileset.properties.properties objectForKey:@"nonBlockingTiles"];
		if ([nonBlocking isKindOfClass:[KKMutableNumber class]])
		{
			[nonBlockingGids addInteger:[nonBlocking intValue]];
		}
		else if ([blocking isKindOfClass:[NSString class]])
		{
			NSString* nonBlockingTiles = (NSString*)nonBlocking;
			NSAssert([[nonBlockingTiles lowercaseString] isEqualToString:@"all"] == NO, @"the keyword 'all' is not allowed for nonBlockingTiles property");
			if (nonBlockingTiles && nonBlockingTiles.length > 0)
			{
				NSArray* components = [nonBlockingTiles componentsSeparatedByString:@","];
				[self addGidStringComponents:components toGidArray:nonBlockingGids gidOffset:tileset.firstGid];
			}
		}
	}
	
	// remove all gids explicitly marked as nonBlocking from blocking array
	KKIntegerArray* finalBlockingGids = [KKIntegerArray integerArrayWithCapacity:blockingGids.count];
	for (NSUInteger i = 0; i < blockingGids.count; i++)
	{
		BOOL gidIsBlocking = YES;
		gid_t blockingGid = blockingGids.integers[i];
		
		for (NSUInteger j = 0; j < nonBlockingGids.count; j++)
		{
			gid_t nonBlockingGid = nonBlockingGids.integers[j];
			if (blockingGid == nonBlockingGid)
			{
				gidIsBlocking = NO;
				break;
			}
		}
		
		if (gidIsBlocking)
		{
			[finalBlockingGids addInteger:blockingGid];
		}
	}
	
	LOG_EXPR(finalBlockingGids);
	
	NSArray* contours = [_mainTileLayerNode.layer pathsWithBlockingGids:finalBlockingGids];
	 */

	KKIntegerArray* nonBlockingGids = [KKIntegerArray integerArrayWithCapacity:32];
	for (KKTilemapTileset* tileset in _tilemap.tilesets)
	{
		id nonBlocking = [tileset.properties.properties objectForKey:@"nonBlockingTiles"];
		if ([nonBlocking isKindOfClass:[KKMutableNumber class]])
		{
			[nonBlockingGids addInteger:[nonBlocking intValue]];
		}
		else if ([nonBlocking isKindOfClass:[NSString class]])
		{
			NSString* nonBlockingTiles = (NSString*)nonBlocking;
			NSAssert([[nonBlockingTiles lowercaseString] isEqualToString:@"all"] == NO, @"the keyword 'all' is not allowed for nonBlockingTiles property");
			if (nonBlockingTiles && nonBlockingTiles.length > 0)
			{
				NSArray* components = [nonBlockingTiles componentsSeparatedByString:@","];
				[self addGidStringComponents:components toGidArray:nonBlockingGids gidOffset:tileset.firstGid];
			}
		}
	}
	
	LOG_EXPR(nonBlockingGids);

	unsigned int nonBlockingGidsCount = nonBlockingGids.count;
	NSUInteger* nonBlockingGidValues = nonBlockingGids.integers;
	
	KKIntegerArray* blockingGids = [KKIntegerArray integerArrayWithCapacity:32];
	for (unsigned int i = 1; i <= _tilemap.highestGid; i++)
	{
		BOOL isBlocking = YES;
		
		for (unsigned int k = 0; k < nonBlockingGidsCount; k++)
		{
			if (i == nonBlockingGidValues[k])
			{
				isBlocking = NO;
				break;
			}
		}
		
		if (isBlocking)
		{
			[blockingGids addInteger:i];
		}
	}
	
	SKNode* containerNode;
	NSArray* contours = [tileLayerNode.layer contourPathsWithBlockingGids:blockingGids];
	//NSArray* contours = [tileLayerNode.layer contourPathsFromLayer:tileLayerNode.layer];
	if (contours.count)
	{
		containerNode = [SKNode node];
		containerNode.name = [NSString stringWithFormat:@"%@:PhysicsBlockingContainerNode", tileLayerNode.name];
		[tileLayerNode addChild:containerNode];
		
		for (id contour in contours)
		{
			SKNode* bodyNode = [SKNode node];
			[bodyNode physicsBodyWithEdgeLoopFromPath:(__bridge CGPathRef)contour];
			[containerNode addChild:bodyNode];
		}
	}
	
	return containerNode;
}

-(SKNode*) createPhysicsShapesWithObjectLayerNode:(KKTilemapObjectLayerNode*)objectLayerNode
{
	SKNode* containerNode;
	KKTilemapLayer* objectLayer = objectLayerNode.layer;
	NSArray* objectPaths = [objectLayer pathsFromObjects];
	
	if (objectPaths.count)
	{
		containerNode = [SKNode node];
		containerNode.name = [NSString stringWithFormat:@"%@:PhysicsBlockingContainerNode", objectLayerNode.name];
		[_mainTileLayerNode addChild:containerNode];
		
		NSUInteger i = 0;
		for (KKTilemapObject* object in objectLayer.objects)
		{
			id objectPath = [objectPaths objectAtIndex:i++];
			CGPathRef path = (__bridge CGPathRef)objectPath;
			
			SKNode* objectNode = [SKNode node];
			objectNode.position = object.position;
			objectNode.zRotation = object.rotation;
			
			if (CGPathIsRect(path, nil))
			{
				[objectNode physicsBodyWithEdgeLoopFromPath:path];
			}
			else
			{
				[objectNode physicsBodyWithEdgeChainFromPath:path];
			}
			[containerNode addChild:objectNode];
		}
	}

	return containerNode;
}

#pragma mark Spawn Objects

-(void) spawnObjects
{
	for (KKTilemapObjectLayerNode* objectLayerNode in _objectLayerNodes)
	{
		[self spawnObjectsWithLayerNode:objectLayerNode];
	}
}

-(void) spawnObjectsWithLayerNode:(KKTilemapObjectLayerNode*)objectLayerNode
{
	NSMutableDictionary* cachedVarSetters = [NSMutableDictionary dictionaryWithCapacity:4];
	[cachedVarSetters setObject:[[KKClassVarSetter alloc] initWithClass:NSClassFromString(@"PKPhysicsBody")] forKey:@"PKPhysicsBody"];
	
	NSDictionary* objectTypes = [objectLayerNode.kkScene.kkView.model objectForKey:@"objectTypes"];
	NSAssert(objectTypes, @"view's objectTypes config dictionary is nil (scene, view or model nil?)");
	
	// for each object on layer
	KKTilemapLayer* objectLayer = objectLayerNode.layer;
	for (KKTilemapObject* tilemapObject in objectLayer.objects)
	{
		NSString* objectType = tilemapObject.type;
		if (objectType)
		{
			// find the matching objectTypes definition
			NSDictionary* objectDef = [objectTypes objectForKey:objectType];
			
			NSString* objectClassName = [objectDef objectForKey:@"className"];
			NSAssert2(objectClassName, @"Can't create object named '%@' (object type: '%@') - 'nodeClass' entry missing for object & its parents. Check objectTypes.lua", tilemapObject.name, objectType);
			
			Class objectNodeClass = NSClassFromString(objectClassName);
			NSAssert3(objectNodeClass, @"Can't create object named '%@' (object type: '%@') - no such class: %@", tilemapObject.name, objectType, objectClassName);
			NSAssert3([objectNodeClass isSubclassOfClass:[SKNode class]], @"Can't create object named '%@' (object type: '%@') - class '%@' does not inherit from SKNode", tilemapObject.name, objectType, objectClassName);
			
			// use a custom initializer where appropriate
			SKNode* objectNode;
			NSString* initMethodName = [objectDef objectForKey:@"initMethod"];
			if (initMethodName.length)
			{
				NSString* paramName = [objectDef objectForKey:@"initParam"];

				// get param from Tiled properties
				NSMutableDictionary* tilemapObjectProperties = tilemapObject.properties.properties;
				id param = [tilemapObjectProperties objectForKey:paramName];
				[tilemapObjectProperties removeObjectForKey:paramName];

				// get param from objecttypes.lua instead
				if (param == nil)
				{
					param = [objectDef objectForKey:paramName];
				}
				
				objectNode = [objectNodeClass performSelector:NSSelectorFromString(initMethodName) withObject:param];
				
				/*
				SEL selector = NSSelectorFromString(initMethodName);
				NSMethodSignature* methodSignature = [objectNodeClass instanceMethodSignatureForSelector:selector];
				NSInvocation* invocation = [NSInvocation invocationWithMethodSignature:methodSig];
				invocation.selector = selector;
				invocation.target = objectNodeClass;
				[invocation invoke];
				objectNode = [invocation getReturnValue:<#(void *)#>];M
				 */
				
				if ([objectNode isKindOfClass:[SKEmitterNode class]])
				{
					// prevents assertions in KKVarSetter
					objectClassName = @"SKEmitterNode";
				}
			}
			else
			{
				objectNode = [objectNodeClass node];
			}
			
			objectNode.position = CGPointMake(tilemapObject.position.x + tilemapObject.size.width / 2.0, tilemapObject.position.y + tilemapObject.size.height / 2.0);
			objectNode.hidden = tilemapObject.hidden;
			objectNode.zRotation = tilemapObject.rotation;
			objectNode.name = (tilemapObject.name.length ? tilemapObject.name : objectClassName);
			[objectLayerNode addChild:objectNode];

			// apply node properties & ivars
			NSDictionary* properties = [objectDef objectForKey:@"properties"];
			if (properties.count)
			{
				KKClassVarSetter* varSetter = [cachedVarSetters objectForKey:objectClassName];
				if (varSetter == nil)
				{
					varSetter = [[KKClassVarSetter alloc] initWithClass:objectNodeClass];
					[cachedVarSetters setObject:varSetter forKey:objectClassName];
				}
				
				[varSetter setIvarsWithDictionary:properties target:objectNode];
				[varSetter setPropertiesWithDictionary:properties target:objectNode];
				
				//NSLog(@"\tproperties: %@", properties);
			}

			//NSLog(@"---> Spawned object: %@", objectClassName);
			
			// create physics body
			NSDictionary* physicsBodyDef = [objectDef objectForKey:@"physicsBody"];
			if (physicsBodyDef.count)
			{
				SKPhysicsBody* body = [objectNode physicsBodyWithTilemapObject:tilemapObject];
				if (body)
				{
					// apply physics body object properties & ivars
					NSDictionary* properties = [physicsBodyDef objectForKey:@"properties"];
					if (properties.count)
					{
						KKClassVarSetter* varSetter = [cachedVarSetters objectForKey:@"PKPhysicsBody"];
						[varSetter setPropertiesWithDictionary:properties target:body];
					}
				}
				
				//NSLog(@"\tphysicsBody: %@", properties);
			}
			
			// create and add behaviors
			NSDictionary* behaviors = [objectDef objectForKey:@"behaviors"];
			for (NSDictionary* behaviorDef in [behaviors allValues])
			{
				NSString* behaviorClassName = [behaviorDef objectForKey:@"className"];
				NSAssert1(behaviorClassName, @"Can't create behavior for object type: '%@' - 'behaviorClass' entry missing. Check objectTypes.lua", objectType);
				
				Class behaviorClass = NSClassFromString(behaviorClassName);
				NSAssert2(behaviorClass, @"Can't create behavior named '%@' (object type: '%@') - no such behavior class", behaviorClassName, objectType);
				NSAssert2([behaviorClass isSubclassOfClass:[KKBehavior class]], @"Can't create behavior named '%@' (object type: '%@') - class does not inherit from KKBehavior", behaviorClassName, objectType);
				
				KKBehavior* behavior = [behaviorClass behavior];
				
				// apply behavior properties & ivars
				NSDictionary* properties = [behaviorDef objectForKey:@"properties"];
				if (properties.count)
				{
					KKClassVarSetter* varSetter = [cachedVarSetters objectForKey:behaviorClassName];
					if (varSetter == nil)
					{
						varSetter = [[KKClassVarSetter alloc] initWithClass:behaviorClass];
						[cachedVarSetters setObject:varSetter forKey:behaviorClassName];
					}
					
					[varSetter setIvarsWithDictionary:properties target:behavior];
					[varSetter setPropertiesWithDictionary:properties target:behavior];
				}
				
				[objectNode addBehavior:behavior withKey:[behaviorDef objectForKey:@"key"]];
				
				//NSLog(@"\tbehavior: %@", behaviorClassName);
			}
			
			// override properties with properties from Tiled
			properties = tilemapObject.properties.properties;
			if (properties.count)
			{
				KKClassVarSetter* varSetter = [cachedVarSetters objectForKey:objectClassName];
				if (varSetter == nil)
				{
					varSetter = [[KKClassVarSetter alloc] initWithClass:objectNodeClass];
					[cachedVarSetters setObject:varSetter forKey:objectClassName];
				}

				[varSetter setIvarsWithDictionary:properties target:objectNode];
				[varSetter setPropertiesWithDictionary:properties target:objectNode];

				//NSLog(@"\tTiled properties: %@", properties);
			}
			
			// call objectDidSpawn on newly spawned object (if available)
			if ([objectNode respondsToSelector:@selector(nodeDidSpawnWithTilemapObject:)])
			{
				[objectNode performSelector:@selector(nodeDidSpawnWithTilemapObject:) withObject:tilemapObject];
			}
		}
	}
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
