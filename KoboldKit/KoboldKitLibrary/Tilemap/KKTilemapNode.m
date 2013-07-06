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
#import "SKNode+KoboldKit.h"
#import "KKFollowTargetBehavior.h"
#import "KKStayInBoundsBehavior.h"

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
		_tileLayers = [NSMutableArray arrayWithCapacity:2];
	}
	return self;
}

-(void) didMoveToParent
{
	if (self.children.count == 0)
	{
		[self observeSceneEvents];
		
		for (KKTilemapLayer* layer in _tilemap.layers)
		{
			if (layer.isTileLayer)
			{
				KKTilemapTileLayerNode* tileLayer = [KKTilemapTileLayerNode tileLayerWithLayer:layer];
				tileLayer.alpha = layer.alpha;
				[self addChild:tileLayer];
				[_tileLayers addObject:tileLayer];
			}
			else
			{
				KKTilemapObjectLayerNode* objectLayer = [KKTilemapObjectLayerNode objectLayerWithLayer:layer tilemap:_tilemap];
				[self addChild:objectLayer];
			}
		}
		
		_mainTileLayerNode = [self findMainTileLayerNode];

		// parallaxing behavior
		KKFollowTargetBehavior* parallaxBehavior = [KKFollowTargetBehavior followTarget:_mainTileLayerNode];
		for (KKTilemapTileLayerNode* tileLayerNode in _tileLayers)
		{
			if (tileLayerNode != _mainTileLayerNode)
			{
				parallaxBehavior.positionMultiplier = tileLayerNode.layer.parallaxFactor;
				[tileLayerNode addBehavior:parallaxBehavior withKey:NSStringFromClass([KKFollowTargetBehavior class])];
			}
		}
	}
}

-(void) restrictScrollingToMapBoundary
{
	// camera boundary scrolling
	KKTilemapLayer* mainTileLayer = _mainTileLayerNode.layer;
	if (mainTileLayer.endlessScrollingHorizontal == NO || mainTileLayer.endlessScrollingVertical == NO)
	{
		CGRect bounds = self.bounds;
		CGRect sceneFrame = self.scene.frame;
		
		if (mainTileLayer.endlessScrollingHorizontal == NO)
		{
			bounds.origin.x = -bounds.size.width + sceneFrame.origin.x + sceneFrame.size.width;
			bounds.size.width = bounds.size.width - sceneFrame.size.width + 1;
		}
		if (mainTileLayer.endlessScrollingVertical == NO)
		{
			bounds.origin.y = -bounds.size.height + sceneFrame.origin.y + sceneFrame.size.height;
			bounds.size.height = bounds.size.height - sceneFrame.size.height + 1;
		}

		NSString* const kMapBoundaryBehaviorKey = @"KKTilemapNode:MapBoundaryScrolling";
		if ([_mainTileLayerNode behaviorForKey:kMapBoundaryBehaviorKey] == nil)
		{
			[_mainTileLayerNode addBehavior:[KKStayInBoundsBehavior stayInBounds:bounds] withKey:kMapBoundaryBehaviorKey];
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
	for (KKTilemapTileLayerNode* tileLayer in _tileLayers)
	{
		[tileLayer updateLayer];
	}
	
	_tilemap.modified = NO;
}

#pragma mark Main Layer

@dynamic mainTileLayerNode;
-(KKTilemapTileLayerNode*) mainTileLayerNode
{
	if (_mainTileLayerNode == nil)
	{
		_mainTileLayerNode = [self findMainTileLayerNode];
	}
	
	return _mainTileLayerNode;
}

-(KKTilemapTileLayerNode*) findMainTileLayerNode
{
	const CGPoint notParallaxing = CGPointMake(1.0, 1.0);
	Class tileLayerNodeClass = [KKTilemapTileLayerNode class];
	KKTilemapTileLayerNode* backgroundTileLayerNode;
	KKTilemapTileLayerNode* mainTileLayerNodeAccordingToParallax;
	KKTilemapTileLayerNode* mainTileLayerNode;
	
	for (KKTilemapTileLayerNode* tileLayerNode in self.children)
	{
		if ([tileLayerNode isKindOfClass:tileLayerNodeClass])
		{
			if (tileLayerNode.layer.mainTileLayer)
			{
				mainTileLayerNode = tileLayerNode;
				break;
			}
			else if (mainTileLayerNodeAccordingToParallax == nil &&
					 CGPointEqualToPoint(tileLayerNode.layer.parallaxFactor, notParallaxing))
			{
				// the main layer is the first tile layer with parallax factor 1.0/1.0 (not parallaxing)
				mainTileLayerNodeAccordingToParallax = tileLayerNode;
			}
			
			if (backgroundTileLayerNode == nil)
			{
				backgroundTileLayerNode = tileLayerNode;
			}
		}
	}
	
	if (mainTileLayerNode == nil)
	{
		if (mainTileLayerNodeAccordingToParallax)
		{
			mainTileLayerNode = mainTileLayerNodeAccordingToParallax;
		}
		else
		{
			mainTileLayerNode = backgroundTileLayerNode;
		}

		NSLog(@"WARNING: KKTilemapNode could not determine 'main' layer, using this layer: %@", mainTileLayerNode.layer);
	}
	
	NSLog(@"Main Tile Layer: %@", mainTileLayerNode.layer.name);
	
	return mainTileLayerNode;
}

#pragma mark Layers

-(KKTilemapTileLayerNode*) tileLayerNodeWithName:(NSString*)name
{
	KKTilemapTileLayerNode* node = (KKTilemapTileLayerNode*)[self childNodeWithName:name];
	NSAssert2([node isKindOfClass:[KKTilemapTileLayerNode class]], @"node with name %@ is not a KKTilemapTileLayerNode, it is: %@", name, node);
	return node;
}

-(KKTilemapObjectLayerNode*) objectLayerNodeWithName:(NSString*)name
{
	KKTilemapObjectLayerNode* node = (KKTilemapObjectLayerNode*)[self childNodeWithName:name];
	NSAssert2([node isKindOfClass:[KKTilemapObjectLayerNode class]], @"node with name %@ is not a KKTilemapObjectLayerNode, it is: %@", name, node);
	return node;
}

#pragma mark Collision

-(SKNode*) createPhysicsCollisionsWithBlockingGids:(KKIntegerArray*)blockingGids
{
	SKNode* containerNode;
	NSArray* contours = [_mainTileLayerNode.layer pathsWithBlockingGids:blockingGids];
	if (contours.count)
	{
		containerNode = [SKNode node];
		containerNode.name = [NSString stringWithFormat:@"%@:PhysicsBlockingContainerNode", _mainTileLayerNode.name];
		[_mainTileLayerNode addChild:containerNode];
		
		for (id contour in contours)
		{
			SKNode* bodyNode = [SKNode node];
			[bodyNode physicsBodyWithEdgeLoopFromPath:(__bridge CGPathRef)contour];
			[containerNode addChild:bodyNode];
		}
	}
	
	return containerNode;
}

-(SKNode*) createPhysicsCollisionsWithObjectLayerNamed:(NSString*)layerName
{
	SKNode* containerNode;
	KKTilemapLayer* objectLayer = [_tilemap layerNamed:layerName];
	NSArray* objectPaths = [objectLayer pathsFromObjects];
	
	if (objectPaths.count)
	{
		containerNode = [SKNode node];
		containerNode.name = [NSString stringWithFormat:@"%@:PhysicsBlockingContainerNode", layerName];
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
