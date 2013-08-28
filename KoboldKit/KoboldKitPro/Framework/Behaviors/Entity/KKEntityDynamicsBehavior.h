/*
 * Copyright (c) 2013 Steffen Itterheim.
 * Released under a PROPRIETARY License:
 * KoboldKit/KoboldKitPro/KoboldKitPro.License.txt
 */

#import "KKBehavior.h"

@class KKEntity;

@interface KKEntityDynamicsBehavior : KKBehavior
{
@private
	NSMutableArray* _kinematicEntities;
	NSMutableArray* _dynamicEntities;
	NSMutableArray* _playerEntities;
}

@property (atomic) CGPoint gravity;
@property (atomic) CGFloat speed;

-(void) addEntity:(KKEntity*)entity;

@end
