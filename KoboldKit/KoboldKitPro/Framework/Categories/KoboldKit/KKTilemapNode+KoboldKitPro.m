/*
 * Copyright (c) 2012-2013 Steffen Itterheim.
 * Released under a PROPRIETARY License:
 * KoboldKit/KoboldKitPro/KoboldKitPro.License.txt
 */

#import "KKTilemapNode+KoboldKitPro.h"
#import "KKEntityDynamicsBehavior.h"
#import "KKEntity.h"

@implementation KKTilemapNode (KoboldKitPro)

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
	KKEntityDynamicsBehavior* entityDynamicsBehavior = [self behaviorKindOfClass:[KKEntityDynamicsBehavior class]];
	
	NSMutableDictionary* varSetterCache = [NSMutableDictionary dictionaryWithCapacity:4];
	[varSetterCache setObject:[[KKClassVarSetter alloc] initWithClass:NSClassFromString(@"PKPhysicsBody")] forKey:@"PKPhysicsBody"];
	
	NSDictionary* objectTemplates = [objectLayerNode.kkScene.kkView.model objectForKey:@"objectTemplates"];
	NSAssert(objectTemplates, @"view's objectTemplates config dictionary is nil (scene, view or model nil?)");
	
	NSDictionary* behaviorTemplates = [objectLayerNode.kkScene.kkView.model objectForKey:@"behaviorTemplates"];
	NSAssert(behaviorTemplates, @"view's behaviorTemplates config dictionary is nil (scene, view or model nil?)");
	
	// for each object on layer
	KKTilemapLayer* objectLayer = objectLayerNode.layer;
	for (KKTilemapObject* tilemapObject in objectLayer.objects)
	{
		NSString* objectType = tilemapObject.type;
		if (objectType)
		{
			// find the matching objectTemplates definition
			NSDictionary* objectDef = [objectTemplates objectForKey:objectType];
			
			NSString* objectClassName = [objectDef objectForKey:@"className"];
			NSAssert2(objectClassName, @"Can't create object named '%@' (object type: '%@') - 'nodeClass' entry missing for object & its parents. Check objectTemplates.lua", tilemapObject.name, objectType);
			
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
				
				// get param from objectTemplates.lua instead
				if (param == nil)
				{
					param = [objectDef objectForKey:paramName];
				}
				
				SUPPRESS_PERFORM_SELECTOR_LEAK_WARNING(objectNode = [objectNodeClass performSelector:NSSelectorFromString(initMethodName)
																						  withObject:param]);
				
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
			
			// apply node properties & ivars
			NSDictionary* nodeProperties = [objectDef objectForKey:@"properties"];
			if (nodeProperties.count)
			{
				KKClassVarSetter* varSetter = [varSetterCache objectForKey:objectClassName];
				if (varSetter == nil)
				{
					varSetter = [[KKClassVarSetter alloc] initWithClass:objectNodeClass];
					[varSetterCache setObject:varSetter forKey:objectClassName];
				}
				
				[varSetter setIvarsWithDictionary:nodeProperties target:objectNode];
				[varSetter setPropertiesWithDictionary:nodeProperties target:objectNode];
				
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
						KKClassVarSetter* varSetter = [varSetterCache objectForKey:@"PKPhysicsBody"];
						[varSetter setPropertiesWithDictionary:properties target:body];
					}
				}
				
				//NSLog(@"\tphysicsBody: %@", properties);
			}
			
			// create and add behaviors
			NSDictionary* behaviors = [objectDef objectForKey:@"behaviors"];
			for (NSString* behaviorDefKey in behaviors)
			{
				NSDictionary* behaviorDef = [behaviors objectForKey:behaviorDefKey];
				KKBehavior* behavior = [self behaviorWithTemplate:behaviorDef objectNode:objectNode varSetterCache:varSetterCache];
				
				[objectNode addBehavior:behavior withKey:behaviorDefKey];
			}
			
			// override properties with properties from Tiled
			NSMutableDictionary* tiledProperties = tilemapObject.properties.properties;
			if (tiledProperties.count)
			{
				KKClassVarSetter* varSetter = [varSetterCache objectForKey:objectClassName];
				if (varSetter == nil)
				{
					varSetter = [[KKClassVarSetter alloc] initWithClass:objectNodeClass];
					[varSetterCache setObject:varSetter forKey:objectClassName];
				}
				
				// process behavior templates first
				for (NSString* propertyKey in tiledProperties.allKeys)
				{
					// test if a behavior template property exists
					NSDictionary* behaviorTemplate = [behaviorTemplates objectForKey:propertyKey];
					if (behaviorTemplate)
					{
						// test if the behavior is enabled, and remove the key to avoid varsetter from trying to "set" it
						KKMutableNumber* behaviorEnabled = [tiledProperties objectForKey:propertyKey];
						[tiledProperties removeObjectForKey:propertyKey];
						
						if (behaviorEnabled.boolValue)
						{
							KKBehavior* behavior = [self behaviorWithTemplate:behaviorTemplate objectNode:objectNode varSetterCache:varSetterCache];
							[objectNode addBehavior:behavior withKey:propertyKey];
						}
					}
				}
				
				[varSetter setIvarsWithDictionary:tiledProperties target:objectNode];
				[varSetter setPropertiesWithDictionary:tiledProperties target:objectNode];
				
				//NSLog(@"\tTiled properties: %@", properties);
			}
			
			[objectLayerNode addChild:objectNode];

			// create entity
			if (entityDynamicsBehavior)
			{
				if ([tilemapObject.name isEqualToString:@"player"])
				{
					NSAssert1(objectNode.physicsBody == nil, @"entity dynamics can't be used with node (%@) because it has a physicsBody", objectNode);
					
					KKEntity* entity = [KKEntity entityWithNode:objectNode tilemapObject:tilemapObject];
					entity.type = KKEntityTypeDynamic;
					entity.maximumVelocity = CGPointMake(15.0, 15.0);
					[entityDynamicsBehavior addEntity:entity];
					LOG_EXPR(entity);
				}
			}

			// call objectDidSpawn on newly spawned object (if available)
			if ([objectNode respondsToSelector:@selector(nodeDidSpawnWithTilemapObject:)])
			{
				[objectNode performSelector:@selector(nodeDidSpawnWithTilemapObject:) withObject:tilemapObject];
			}
		}
	}
}

-(KKBehavior*) behaviorWithTemplate:(NSDictionary*)behaviorDef objectNode:(SKNode*)objectNode varSetterCache:(NSMutableDictionary*)varSetterCache
{
	NSString* behaviorClassName = [behaviorDef objectForKey:@"className"];
	NSAssert1(behaviorClassName, @"Can't create behavior (%@) - 'behaviorClass' entry missing. Check objectTemplates.lua", behaviorDef);
	
	Class behaviorClass = NSClassFromString(behaviorClassName);
	NSAssert1(behaviorClass, @"Can't create behavior named '%@' - no such behavior class", behaviorClassName);
	NSAssert1([behaviorClass isSubclassOfClass:[KKBehavior class]], @"Can't create behavior named '%@' - class does not inherit from KKBehavior", behaviorClassName);
	
	KKBehavior* behavior = [behaviorClass behavior];
	
	// apply behavior properties & ivars
	NSDictionary* behaviorProperties = [behaviorDef objectForKey:@"properties"];
	if (behaviorProperties.count)
	{
		KKClassVarSetter* varSetter = [varSetterCache objectForKey:behaviorClassName];
		if (varSetter == nil)
		{
			varSetter = [[KKClassVarSetter alloc] initWithClass:behaviorClass];
			[varSetterCache setObject:varSetter forKey:behaviorClassName];
		}
		
		[varSetter setIvarsWithDictionary:behaviorProperties target:behavior];
		[varSetter setPropertiesWithDictionary:behaviorProperties target:behavior];
	}
	
	return behavior;
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
	
	NSUInteger nonBlockingGidsCount = nonBlockingGids.count;
	NSUInteger* nonBlockingGidValues = nonBlockingGids.integers;
	
	KKIntegerArray* blockingGids = [KKIntegerArray integerArrayWithCapacity:32];
	for (NSUInteger i = 1; i <= _tilemap.highestGid; i++)
	{
		BOOL isBlocking = YES;
		
		for (NSUInteger k = 0; k < nonBlockingGidsCount; k++)
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

@end
