//
//  KKEntityDynamicsBehavior.m
//  KoboldKitPro
//
//  Created by Steffen Itterheim on 18.08.13.
//  Copyright (c) 2013 Steffen Itterheim. All rights reserved.
//

#import "KKEntityDynamicsBehavior.h"
#import "KKEntity.h"

@implementation KKEntityDynamicsBehavior

-(void) didInitialize
{
	_kinematicEntities = [NSMutableArray arrayWithCapacity:10];
	_dynamicEntities = [NSMutableArray arrayWithCapacity:10];
}

-(void) didJoinController
{
	[self.node.kkScene addSceneEventsObserver:self];
}

-(void) didLeaveController
{
	[self.node.kkScene removeSceneEventsObserver:self];
}


-(void) addEntity:(KKEntity *)entity
{
	NSAssert1(entity.type != KKEntityTypeStatic, @"KKEntityDynamicsBehavior doesn't accept static entities (%@)", entity);

	if (entity.type == KKEntityTypeDynamic)
	{
		[_dynamicEntities addObject:entity];
	}
	else
	{
		[_kinematicEntities addObject:entity];
	}
}

-(void) didEvaluateActions
{
	
}

@end
