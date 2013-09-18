/*
 * Copyright (c) 2012-2013 Steffen Itterheim.
 * Released under the MIT License:
 * KoboldAid/licenses/KoboldKitFree.License.txt
 */

#import <Foundation/Foundation.h>

/** A simple and efficient array of CGPoint structs.

   The array is an allocated block of memory instead of boxing the CGPoint in NSValue objects. For most efficient use,
   set the array's capacity to hold the same number of points you're going to add. Otherwise buffer will grow as needed,
   allocating 50% more memory each time.

   Feature set is minimal, please request if you need something. For example there are deliberately no "insert point" or "remove point"
   methods because they're probably not going to be used (frequently). */
@interface KKPointArray : NSObject
{
	@private
	NSUInteger _numPointsAllocated;
}

/** Returns the number of points in the array. */
@property (atomic, readonly) NSUInteger count;
/** Returns the points array. Caution: Do not free() this buffer! Do not use index out of bounds! There are no safety checks here! */
@property (atomic, readonly) CGPoint* points;

/** Creates a points array, reserving capacity amount of memory for points.
 @param capacity The initial capacity reserved for the array.
 @returns A new instance. */
+(id) pointArrayWithCapacity:(NSUInteger)capacity;
/** Creates a points array by copying count points from the points buffer (array). You can delete (free) your points buffer after calling this method. 
 @param points A memory buffer containing CGPoints. The buffer is copied.
 @param count The number of CGPoint in the buffer. 
 @returns A new instance. */
+(id) pointArrayWithPoints:(CGPoint*)points count:(NSUInteger)count;

/** Adds the given number of points from an existing CGPoint array or memory buffer.
 @param points Memeory buffer containing points. Buffer is copied.
 @param count The number of CGPoint in the buffer. */
-(void) addPoints:(CGPoint*)points count:(NSUInteger)count;
/** Adds a single point to the array.
 @param point The point to add. */
-(void) addPoint:(CGPoint)point;
/** Removes all points from the array. You can then start re-adding points. */
-(void) removeAllPoints;

/** Returns the point at the given index. If the index is out of bounds an exception is raised.
 @param index The index of a point.
 @returns The point at the given index. */
-(CGPoint) pointAtIndex:(NSUInteger)index;

/** @returns The last point in the array. */
-(CGPoint) lastPoint;
/** Removes the last point from the array. Does nothing if the array is empty. */
-(void) removeLastPoint;
/** Removes all points from index to last point. Does nothing if index >= count. The array then contains (index - 1) points.
 @param index The lowest index from which to remove all remaining points. */
-(void) removePointsStartingAtIndex:(NSUInteger)index;

@end
