/*
 * Copyright (c) 2013 Steffen Itterheim.
 * Released under the MIT License:
 * KoboldAid/licenses/KoboldKitFree.License.txt
 */

#import "KKView.h"
#import "KKScene.h"
#import "KKModel.h"
#import "KKLua.h"
#import "NSDictionary+KoboldKit.h"
#import "NSBundle+KoboldKit.h"
#import "KKClassVarSetter.h"

static BOOL _showsPhysicsShapes = NO;
static BOOL _showsNodeFrames = NO;
static BOOL _showsNodeAnchorPoints = NO;

@implementation KKView

-(id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
	{
		[self initDefaults];
    }
    return self;
}

-(id) initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if (self)
	{
		[self initDefaults];
	}
	return self;
}

-(id) init
{
	self = [super init];
	if (self)
	{
		[self initDefaults];
	}
	return self;
}

-(void) initDefaults
{
	_sceneStack = [NSMutableArray array];
	_model = [KKModel model];

	[KKLua setup];
	[self reloadConfig];
}

#pragma mark Properties

-(KKGLContext*) context
{
#if TARGET_OS_IPHONE
	return [EAGLContext currentContext];
#else
	return [NSOpenGLContext currentContext];
#endif
}

#pragma mark Config

-(void) reloadConfig
{
	[self loadConfig:@"config.lua"];
	[self loadConfig:@"devconfig.lua"];
	[self loadConfig:@"objectTemplates.lua" inheritProperties:YES];
	[self loadConfig:@"behaviorTemplates.lua"];
	[self loadConfig:@"tiledPropertiesMapping.lua"];

	BOOL disableAllDebugLabels = [_model boolForKeyPath:@"devconfig.disableAllDebugLabels"];
	if (disableAllDebugLabels == NO)
	{
		self.showsDrawCount = [_model boolForKeyPath:@"devconfig.showsDrawCount"];
		self.showsFPS = [_model boolForKeyPath:@"devconfig.showsFPS"];
		self.showsNodeCount = [_model boolForKeyPath:@"devconfig.showsNodeCount"];
		self.showsPhysicsShapes = [_model boolForKeyPath:@"devconfig.showsPhysicsShapes"];
		self.showsNodeFrames = [_model boolForKeyPath:@"devconfig.showsNodeFrames"];
		self.showsNodeAnchorPoints = [_model boolForKeyPath:@"devconfig.showsNodeAnchorPoints"];
		
		[self setValue:@([_model boolForKeyPath:@"devconfig.showsCoreAnimationFPS"]) forKey:@"_showsCoreAnimationFPS"];
		[self setValue:@([_model boolForKeyPath:@"devconfig.showsGPUStats"]) forKey:@"_showsGPUStats"];
		[self setValue:@([_model boolForKeyPath:@"devconfig.showsCPUStats"]) forKey:@"_showsCPUStats"];
		[self setValue:@([_model boolForKeyPath:@"devconfig.showsCulledNodesInNodeCount"]) forKey:@"_showsCulledNodesInNodeCount"];
		[self setValue:@([_model boolForKeyPath:@"devconfig.showsTotalAreaRendered"]) forKey:@"_showsTotalAreaRendered"];
		[self setValue:@([_model boolForKeyPath:@"devconfig.showsSpriteBounds"]) forKey:@"_showsSpriteBounds"];
		[self setValue:@([_model boolForKeyPath:@"devconfig.shouldCenterStats"]) forKey:@"_shouldCenterStats"];
	}
}

-(void) loadConfig:(NSString*)configFile
{
	[self loadConfig:configFile inheritProperties:NO];
}

-(void) loadConfig:(NSString*)configFile inheritProperties:(BOOL)flattenHierarchy
{
	NSString* path = [NSBundle pathForFile:configFile];
	if (path)
	{
		NSMutableDictionary* config = [NSMutableDictionary dictionaryWithContentsOfLuaScript:path];
		if (config)
		{
			if (flattenHierarchy)
			{
				[self flattenHierarchyWithConfig:config];
			}
			
			NSString* key = [[configFile lastPathComponent] stringByDeletingPathExtension];
			[_model setObject:config forKey:key];
		}
	}
}

-(void) flattenHierarchyWithConfig:(NSMutableDictionary*)config
{
	for (id key in config)
	{
		id value = [config valueForKey:key];
		if ([value isKindOfClass:[NSMutableDictionary class]])
		{
			// check for inheritance
			NSMutableDictionary* objectDef = (NSMutableDictionary*)value;
			NSString* parentName = [objectDef objectForKey:@"inheritsFrom"];
			
			while (parentName.length)
			{
				// inherit values from the parent object
				NSDictionary* parentObjectDef = [config objectForKey:parentName];
				NSAssert2(parentObjectDef, @"object type '%@' tries to inherit from unknown parent object type '%@'", key, parentName);
				if (parentObjectDef)
				{
					[self inheritValuesFrom:parentObjectDef childObject:objectDef];
					parentName = [parentObjectDef objectForKey:@"inheritsFrom"];
				}
			}
		}
	}
}

-(void) inheritValuesFrom:(NSDictionary*)parentObject childObject:(NSMutableDictionary*)childObject
{
	Class dictionaryClass = [NSDictionary class];
	for (id parentKey in parentObject)
	{
		// inherit parent object only if child doesn't override it
		id object = [childObject objectForKey:parentKey];
		if (object == nil)
		{
			[childObject setObject:[parentObject objectForKey:parentKey] forKey:parentKey];
		}
		else if ([object isKindOfClass:dictionaryClass])
		{
			// recurse
			[self inheritValuesFrom:[parentObject objectForKey:parentKey] childObject:object];
		}
	}
}

#pragma mark Present Scene

-(void) presentScene:(SKScene *)scene
{
	[self presentScene:scene transition:nil];
}

-(void) presentScene:(SKScene *)scene transition:(SKTransition *)transition
{
	if (_sceneStack.count > 0)
	{
		[_sceneStack removeLastObject];
	}
	[_sceneStack addObject:scene];
	
	transition ? [super presentScene:scene transition:transition] : [super presentScene:scene];
}

-(void) presentScene:(KKScene *)scene unwindStack:(BOOL)unwindStack
{
	[self presentScene:scene transition:nil unwindStack:unwindStack];
}

-(void) presentScene:(KKScene *)scene transition:(KKTransition *)transition unwindStack:(BOOL)unwindStack
{
	if (unwindStack)
	{
		[_sceneStack removeAllObjects];
		[_sceneStack addObject:scene];
	}

	transition ? [super presentScene:scene transition:transition] : [super presentScene:scene];
}

-(void) pushScene:(KKScene*)scene
{
	[self pushScene:scene transition:nil];
}

-(void) pushScene:(KKScene*)scene transition:(KKTransition*)transition
{
	self.scene.paused = YES;
	[_sceneStack addObject:self.scene];
	
	transition ? [super presentScene:scene transition:transition] : [super presentScene:scene];
}

-(void) popScene
{
	[self popSceneWithTransition:nil];
}

-(void) popSceneWithTransition:(KKTransition*)transition
{
	if (_sceneStack.count > 1)
	{
		KKScene* scene = [_sceneStack lastObject];
		[_sceneStack removeLastObject];
		
		transition ? [super presentScene:scene transition:transition] : [super presentScene:scene];
		scene.paused = NO;
	}
}

-(void) popToRootScene
{
	[self popToRootSceneWithTransition:nil];
}

-(void) popToRootSceneWithTransition:(KKTransition*)transition
{
	if (_sceneStack.count > 1)
	{
		KKScene* scene = [_sceneStack firstObject];
		if (scene)
		{
			[_sceneStack removeAllObjects];
			[_sceneStack addObject:scene];
			
			transition ? [super presentScene:scene transition:transition] : [super presentScene:scene];
			scene.paused = NO;
		}
	}
}

-(void) popToSceneNamed:(NSString*)name
{
	[self popToSceneNamed:name transition:nil];
}

-(void) popToSceneNamed:(NSString*)name transition:(KKTransition*)transition
{
	if (_sceneStack.count > 1)
	{
		NSMutableIndexSet* indexes = [NSMutableIndexSet indexSet];
		for (NSUInteger i = _sceneStack.count - 2; i == 0; i--)
		{
			[indexes addIndex:i];
			KKScene* scene = [_sceneStack objectAtIndex:i];
			if ([scene.name isEqualToString:name])
			{
				[_sceneStack removeObjectsAtIndexes:indexes];
				[_sceneStack addObject:scene];
				
				transition ? [super presentScene:scene transition:transition] : [super presentScene:scene];
				scene.paused = NO;
				break;
			}
		}
	}
}

#pragma mark Debug

@dynamic showsPhysicsShapes;
+(BOOL) showsPhysicsShapes
{
	return _showsPhysicsShapes;
}
-(BOOL) showsPhysicsShapes
{
	return _showsPhysicsShapes;
}
-(void) setShowsPhysicsShapes:(BOOL)showsPhysicsShapes
{
	_showsPhysicsShapes = showsPhysicsShapes;
}

@dynamic showsNodeFrames;
+(BOOL) showsNodeFrames
{
	return _showsNodeFrames;
}
-(BOOL) showsNodeFrames
{
	return _showsNodeFrames;
}
-(void) setShowsNodeFrames:(BOOL)showsNodeFrames
{
	_showsNodeFrames = showsNodeFrames;
}

@dynamic showsNodeAnchorPoints;
+(BOOL) showsNodeAnchorPoints
{
	return _showsNodeAnchorPoints;
}
-(BOOL) showsNodeAnchorPoints
{
	return _showsNodeAnchorPoints;
}
-(void) setShowsNodeAnchorPoints:(BOOL)showsNodeAnchorPoints
{
	_showsNodeAnchorPoints = showsNodeAnchorPoints;
}

@end
