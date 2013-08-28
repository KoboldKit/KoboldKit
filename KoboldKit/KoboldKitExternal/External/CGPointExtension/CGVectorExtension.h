/*********************************************************************************
 * cocos2d for iPhone
 * http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2007 Scott Lembcke
 *
 * Copyright (c) 2010 Lam Pham
 *
 * Copyright (c) 2013 Steffen Itterheim
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
 */

/*
 * Kobold Kit: ported CGVector functions to CGVector equivalents.
 */

/** @header
 point extensions
 */

/** @name CGVectorExtension */

/**
   @file
   CGVector extensions based on Chipmunk's cpVect file.
   These extensions work both with CGVector and cpVect.

   The "ccv" prefix means: "CoCos2d Point"

   Examples:
   - ccvAdd( ccv(1,1), ccv(2,2) ); // preferred cocos2d way
   - ccvAdd( CGVectorMake(1,1), CGVectorMake(2,2) ); // also ok but more verbose

   - cpvadd( cpv(1,1), cpv(2,2) ); // way of the chipmunk
   - ccvAdd( cpv(1,1), cpv(2,2) ); // mixing chipmunk and cocos2d (avoid)
   - cpvadd( CGVectorMake(1,1), CGVectorMake(2,2) ); // mixing chipmunk and CG (avoid)
 */

#ifdef TARGET_OS_IPHONE
#import <CoreGraphics/CGGeometry.h>
#elif TARGET_OS_MAC
#import <Foundation/Foundation.h>
#endif

#import <math.h>
#import <objc/objc.h>

/** @def CC_SWAP
 simple macro that swaps 2 variables */
#define CC_SWAP(x, y) ({__typeof__(x) temp = (x); x = y; y = temp;})

#ifdef __cplusplus
extern "C" {
#endif

/* The "zero" vector -- equivalent to CGVectorMake(0, 0). */
CG_EXTERN const CGVector CGVectorZero;
	
/** Helper macro that creates a CGVector
   @return CGVector
   @since v0.7.2
 */
static inline CGVector ccv(CGFloat x, CGFloat y)
{
	return CGVectorMake(x, y);
}

/** Returns opposite of point.
   @return CGVector
   @since v0.7.2
 */
static inline CGVector
ccvNeg(const CGVector v)
{
	return ccv(-v.dx, -v.dy);
}

/** Calculates sum of two points.
   @return CGVector
   @since v0.7.2
 */
static inline CGVector
ccvAdd(const CGVector v1, const CGVector v2)
{
	return ccv(v1.dx + v2.dx, v1.dy + v2.dy);
}

/** Calculates difference of two points.
   @return CGVector
   @since v0.7.2
 */
static inline CGVector
ccvSub(const CGVector v1, const CGVector v2)
{
	return ccv(v1.dx - v2.dx, v1.dy - v2.dy);
}

/** Returns point multiplied by given factor.
   @return CGVector
   @since v0.7.2
 */
static inline CGVector
ccvMult(const CGVector v, const CGFloat s)
{
	return ccv(v.dx * s, v.dy * s);
}

/** Calculates midpoint between two points.
   @return CGVector
   @since v0.7.2
 */
static inline CGVector
ccvMidpoint(const CGVector v1, const CGVector v2)
{
	return ccvMult(ccvAdd(v1, v2), 0.5f);
}

/** Calculates dot product of two points.
   @return CGFloat
   @since v0.7.2
 */
static inline CGFloat
ccvDot(const CGVector v1, const CGVector v2)
{
	return v1.dx * v2.dx + v1.dy * v2.dy;
}

/** Calculates cross product of two points.
   @return CGFloat
   @since v0.7.2
 */
static inline CGFloat
ccvCross(const CGVector v1, const CGVector v2)
{
	return v1.dx * v2.dy - v1.dy * v2.dx;
}

/** Calculates perpendicular of v, rotated 90 degrees counter-clockwise -- cross(v, perp(v)) >= 0
   @return CGVector
   @since v0.7.2
 */
static inline CGVector
ccvPerp(const CGVector v)
{
	return ccv(-v.dy, v.dx);
}

/** Calculates perpendicular of v, rotated 90 degrees clockwise -- cross(v, rperp(v)) <= 0
   @return CGVector
   @since v0.7.2
 */
static inline CGVector
ccvRPerp(const CGVector v)
{
	return ccv(v.dy, -v.dx);
}

/** Calculates the projection of v1 over v2.
   @return CGVector
   @since v0.7.2
 */
static inline CGVector
ccvProject(const CGVector v1, const CGVector v2)
{
	return ccvMult(v2, ccvDot(v1, v2) / ccvDot(v2, v2));
}

/** Rotates two points.
   @return CGVector
   @since v0.7.2
 */
static inline CGVector
ccvRotate(const CGVector v1, const CGVector v2)
{
	return ccv(v1.dx * v2.dx - v1.dy * v2.dy, v1.dx * v2.dy + v1.dy * v2.dx);
}

/** Unrotates two points.
   @return CGVector
   @since v0.7.2
 */
static inline CGVector
ccvUnrotate(const CGVector v1, const CGVector v2)
{
	return ccv(v1.dx * v2.dx + v1.dy * v2.dy, v1.dy * v2.dx - v1.dx * v2.dy);
}

/** Calculates the square length of a CGVector (not calling sqrt() )
   @return CGFloat
   @since v0.7.2
 */
static inline CGFloat
ccvLengthSQ(const CGVector v)
{
	return ccvDot(v, v);
}

/** Calculates the square distance between two points (not calling sqrt() )
   @return CGFloat
   @since v1.1
 */
static inline CGFloat
ccvDistanceSQ(const CGVector p1, const CGVector p2)
{
	return ccvLengthSQ(ccvSub(p1, p2));
}

/** Calculates distance between point an origin
   @return CGFloat
   @since v0.7.2
 */
CGFloat ccvLength(const CGVector v);

/** Calculates the distance between two points
   @return CGFloat
   @since v0.7.2
 */
CGFloat ccvDistance(const CGVector v1, const CGVector v2);

/** Returns point multiplied to a length of 1.
   @return CGVector
   @since v0.7.2
 */
CGVector ccvNormalize(const CGVector v);

/** Converts radians to a normalized vector.
   @return CGVector
   @since v0.7.2
 */
CGVector ccvForAngle(const CGFloat a);

/** Converts a vector to radians.
   @return CGFloat
   @since v0.7.2
 */
CGFloat ccvToAngle(const CGVector v);

/** Clamp a point between from and to.
   @since v0.99.1
 */
CGVector ccvClamp(CGVector p, CGVector from, CGVector to);

/** Quickly convert CGSize to a CGVector
   @since v0.99.1
 */
CGVector ccvFromSize(CGSize s);

/** Run a math operation function on each point component
 * absf, fllorf, ceilf, roundf
 * any function that has the signature: float func(float);
 * For example: let's try to take the floor of x,y
 * ccvCompOp(p,floorf);
   @since v0.99.1
 */
CGVector ccvCompOp(CGVector p, float (* opFunc)(float));

/** Linear Interpolation between two points a and b
   @returns
    alpha == 0 ? a
    alpha == 1 ? b
    otherwise a value between a..b
   @since v0.99.1
 */
CGVector ccvLerp(CGVector a, CGVector b, float alpha);


/** @returns if points have fuzzy equality which means equal with some degree of variance.
   @since v0.99.1
 */
BOOL ccvFuzzyEqual(CGVector a, CGVector b, float variance);


/** Multiplies a nd b components, a.dx*b.dx, a.dy*b.dy
   @returns a component-wise multiplication
   @since v0.99.1
 */
CGVector ccvCompMult(CGVector a, CGVector b);

/** @returns the signed angle in radians between two vector directions
   @since v0.99.1
 */
float ccvAngleSigned(CGVector a, CGVector b);

/** @returns the angle in radians between two vector directions
   @since v0.99.1
 */
float ccvAngle(CGVector a, CGVector b);

/** Rotates a point counter clockwise by the angle around a pivot
   @param v is the point to rotate
   @param pivot is the pivot, naturally
   @param angle is the angle of rotation cw in radians
   @returns the rotated point
   @since v0.99.1
 */
CGVector ccvRotateByAngle(CGVector v, CGVector pivot, float angle);

/** A general line-line intersection test
   @param p1
    is the startpoint for the first line P1 = (p1 - p2)
   @param p2
    is the endpoint for the first line P1 = (p1 - p2)
   @param p3
    is the startpoint for the second line P2 = (p3 - p4)
   @param p4
    is the endpoint for the second line P2 = (p3 - p4)
   @param s
    is the range for a hitpoint in P1 (pa = p1 + s*(p2 - p1))
   @param t
    is the range for a hitpoint in P3 (pa = p2 + t*(p4 - p3))
   @return bool
    indicating successful intersection of a line
    note that to truly test intersection for segments we have to make
    sure that s & t lie within [0..1] and for rays, make sure s & t > 0
    the hit point is		p3 + t * (p4 - p3);
    the hit point also is	p1 + s * (p2 - p1);
   @since v0.99.1
 */
BOOL ccvLineIntersect(CGVector p1, CGVector p2,
					  CGVector p3, CGVector p4,
					  float* s, float* t);

/*
   ccvSegmentIntersect returns YES if Segment A-B intersects with segment C-D
   @since v1.0.0
 */
BOOL ccvSegmentIntersect(CGVector A, CGVector B, CGVector C, CGVector D);

/*
   ccvIntersectPoint returns the intersection point of line A-B, C-D
   @since v1.0.0
 */
CGVector ccvIntersectPoint(CGVector A, CGVector B, CGVector C, CGVector D);

#ifdef __cplusplus
}
#endif
