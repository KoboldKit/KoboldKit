//
//  KTIntegerArray.h
//  Cocos2D+Box2D-GenerateTilemapCollisions
//
//  Created by Steffen Itterheim on 29.05.13.
//  Copyright (c) 2013 Steffen Itterheim. All rights reserved.
//

#import <Foundation/Foundation.h>

/** Wraps a C array of NSUInteger with a slim NSArray type interface. */
@interface KKIntegerArray : NSObject
{
@private
	NSUInteger _numIntegersAllocated;
}

@property (atomic, readonly) NSUInteger count;
@property (atomic, readonly) NSUInteger* integers;

+(id) integerArrayWithCapacity:(NSUInteger)capacity;

-(void) addInteger:(NSUInteger)integer;
-(void) removeAllIntegers;
-(NSUInteger) integerAtIndex:(NSUInteger)index;
-(NSUInteger) lastInteger;

@end
