/*
 * Copyright (c) 2012-2013 Steffen Itterheim.
 * Released under the MIT License:
 * KoboldAid/licenses/KoboldKitFree.License.txt
 */


#import <Foundation/Foundation.h>

/** Wraps a C array of NSUInteger with a slim NSArray type interface. */
@interface KKIntegerArray : NSObject
{
@private
	NSUInteger _numIntegersAllocated;
}

/** Number of integers in the array. */
@property (atomic, readonly) NSUInteger count;
/** The integer array as C memory buffer. */
@property (atomic, readonly) NSUInteger* integers;

/** @param capacity The initial size of the array.
 @returns A new instance. */
+(id) integerArrayWithCapacity:(NSUInteger)capacity;

/** Adds an integer at the end of the array.
 @param integer The integer to add. */
-(void) addInteger:(NSUInteger)integer;
/** Empties the array. */
-(void) removeAllIntegers;
/** @param index An array index.
 @returns The integer at the index. */
-(NSUInteger) integerAtIndex:(NSUInteger)index;
/** @returns The last integer in the array. Returns 0 if the array is empty. */
-(NSUInteger) lastInteger;

@end
