//
//  OGWWorld.m
//  KoboldKitPro
//
//  Created by Steffen Itterheim on 14.09.13.
//  Copyright (c) 2013 Steffen Itterheim. All rights reserved.
//

#import "OGWWorld.h"
#import "OGWTypes.h"

#include "GWWorld.h"

@implementation OGWWorld

-(NSArray*) entitiesWithType:(NSInteger)entityType
{
	id array = [_entities objectForKey:[NSNumber numberWithInteger:entityType]];
	return array;
}

@end
