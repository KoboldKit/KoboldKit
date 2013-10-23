//
//  _Geometry_Functions.h
//  OpenGW
//
//  Created by Steffen Itterheim on 20/10/13.
//  Copyright (c) 2013 Steffen Itterheim. All rights reserved.
//

#import <Foundation/Foundation.h>

/** GWGeometry.h/.m contains many C math functions for GWVector/GWPoint types.
 
 GWGeometry was adapted from MIT-Licensed CGGeometry.h/.m included in the cocos2d-iphone project, which in turn is based on cpVect.h from the Chipmunk2D project. The license text is included at the bottom of this page.
 
 <pre>
 Returns opposite of point.
 GW_INLINE GWVector GWVectorNegate(GWVector v)
 <p/>
 Calculates sum of two points.
 GW_INLINE GWVector GWVectorAdd(GWVector v1, GWVector v2)
 <p/>
 Calculates difference of two points.
 GW_INLINE GWVector GWVectorSubtract(GWVector v1, GWVector v2)
 <p/>
 Returns point multiplied by given factor.
 GW_INLINE GWVector GWVectorMultiply(GWVector v, GWFloat s)
 <p/>
 Calculates midpoint between two points.
 GW_INLINE GWVector GWVectorMidpoint(GWVector v1, GWVector v2)
 <p/>
 Calculates dot product of two points.
 GW_INLINE GWFloat GWVectorDotProduct(GWVector v1, GWVector v2)
 <p/>
 Calculates cross product of two points.
 GW_INLINE GWFloat GWVectorCrossProduct(GWVector v1, GWVector v2)
 <p/>
 Calculates perpendicular of v, rotated 90 degrees counter-clockwise -- cross(v, perp(v)) >= 0
 GW_INLINE GWVector GWVectorPerpendicularCounterClockwise(GWVector v)
 <p/>
 Calculates perpendicular of v, rotated 90 degrees clockwise -- cross(v, rperp(v)) <= 0
 GW_INLINE GWVector GWVectorPerpendicularClockwise(GWVector v)
 <p/>
 Calculates the projection of v1 over v2.
 GW_INLINE GWVector GWVectorProjection(GWVector v1, GWVector v2)
 <p/>
 Rotates two points.
 GW_INLINE GWVector GWVectorRotate(GWVector v1, GWVector v2)
 <p/>
 Unrotates two points.
 GW_INLINE GWVector GWVectorUnrotate(GWVector v1, GWVector v2)
 <p/>
 Calculates the square length of a GWVector (not calling sqrt() )
 GW_INLINE GWFloat GWVectorLengthSquared(GWVector v)
 <p/>
 Calculates the square distance between two points (not calling sqrt() )
 GW_INLINE GWFloat GWVectorDistanceSquared(GWVector p1, GWVector p2)
 <p/>
 Calculates distance between point an origin
 GW_INLINE GWFloat GWVectorLength(GWVector v);
 <p/>
 Calculates the distance between two points
 GW_INLINE GWFloat GWVectorDistance(GWVector v1, GWVector v2);
 <p/>
 Returns point multiplied to a length of 1.
 GW_INLINE GWVector GWVectorNormalize(GWVector v);
 <p/>
 Converts radians to a normalized vector.
 GW_INLINE GWVector GWVectorFromAngle(GWFloat a);
 <p/>
 Converts a vector to radians.
 GW_INLINE GWFloat GWVectorToAngle(GWVector v);
 <p/>
 Linear Interpolation between two points a and b
 GW_INLINE GWVector GWVectorInterpolate(GWVector a, GWVector b, GWFloat alpha);
 <p/>
 Clamp a value between from and to.
 GW_INLINE GWFloat GWClamp(GWFloat value, GWFloat min_inclusive, GWFloat max_inclusive);
 <p/>
 Clamp a point between from and to.
 GW_INLINE GWVector GWVectorClamp(GWVector p, GWVector from, GWVector to);
 <p/>
 Quickly convert GWSize to a GWVector
 GW_INLINE GWVector GWVectorFromSize(GWSize s);
 <p/>
 Multiplies a nd b components, a.x*b.x, a.y*b.y
 GW_INLINE GWVector GWVectorPointwiseProduct(GWVector a, GWVector b);
 <p/>
 Run a math operation function on each point component
 * absf, fllorf, ceilf, roundf
 * any function that has the signature: GWFloat func(GWFloat);
 * For example: let's try to take the floor of x,y
 * GWVectorComputeFunction(p,floorf);
 GWVector GWVectorComputeFunction(GWVector p, GWFloat (*opFunc)(GWFloat));
 <p/>
 if points have fuzzy equality which means equal with some degree of variance.
 GWBool GWVectorFuzzyEqual(GWVector a, GWVector b, GWFloat variance);
 <p/>
 returns the angle in radians between two vector directions
 GWFloat GWVectorAngle(GWVector a, GWVector b);
 <p/>
 returns the signed angle in radians between two vector directions
 GWFloat GWVectorAngleSigned(GWVector a, GWVector b);
 <p/>
 Rotates a point counter clockwise by the angle around a pivot
 param v is the point to rotate
 param pivot is the pivot, naturally
 param angle is the angle of rotation cw in radians
 returns the rotated point
 GWVector GWVectorRotateByAngle(GWVector v, GWVector pivot, GWFloat angle);
 <p/>
 A general line-line intersection test
 param p1 is the startpoint for the first line P1 = (p1 - p2)
 param p2 is the endpoint for the first line P1 = (p1 - p2)
 param p3 is the startpoint for the second line P2 = (p3 - p4)
 param p4 is the endpoint for the second line P2 = (p3 - p4)
 param s is the range for a hitpoint in P1 (pa = p1 + s*(p2 - p1))
 param t is the range for a hitpoint in P3 (pa = p2 + t*(p4 - p3))
 returns bool indicating successful intersection of a line
 note that to truly test intersection for segments we have to make
 sure that s & t lie within [0..1] and for rays, make sure s & t > 0
 the hit point is		p3 + t * (p4 - p3);
 the hit point also is	p1 + s * (p2 - p1);
 GWBool GWVectorLineIntersect(GWVector p1, GWVector p2, GWVector p3, GWVector p4, GWFloat* s, GWFloat* t);
 <p/>
 returns YES if Segment A-B intersects with segment C-D
 GWBool GWVectorSegmentIntersect(GWVector A, GWVector B, GWVector C, GWVector D);
 <p/>
 returns the intersection point of line A-B, C-D
 GWVector GWVectorIntersectPoint(GWVector A, GWVector B, GWVector C, GWVector D);
 </pre>
 
 <h2>MIT License</h2>
 *********************************************************************************
 * Copyright (c) 2007 Scott Lembcke
 *
 * Copyright (c) 2010 Lam Pham
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 *
 */
@interface _Geometry_Functions
// stub class only for documentation
@end
