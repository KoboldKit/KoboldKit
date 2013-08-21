//
//  KKEntityDynamicsBehavior.h
//  KoboldKitPro
//
//  Created by Steffen Itterheim on 18.08.13.
//  Copyright (c) 2013 Steffen Itterheim. All rights reserved.
//

#import "KKBehavior.h"

@class KKEntity;

@interface KKEntityDynamicsBehavior : KKBehavior
{
@private
	NSMutableArray* _kinematicEntities;
	NSMutableArray* _dynamicEntities;
}

@property (atomic) CGPoint gravity;
@property (atomic) CGFloat speed;

-(void) addEntity:(KKEntity*)entity;

@end
