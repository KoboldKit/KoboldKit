//
//  OGWWorld.h
//  KoboldKitPro
//
//  Created by Steffen Itterheim on 14.09.13.
//  Copyright (c) 2013 Steffen Itterheim. All rights reserved.
//

#import <Foundation/Foundation.h>

class GWWorld;

@interface OGWWorld : NSObject
{
	@protected
	GWWorld* cppWorld;
	
	@private
	NSMutableDictionary* _entities;
}

-(NSArray*) entitiesWithType:(NSInteger)entityType;

@end
