/* cocos2d for iPhone
 * http://www.cocos2d-iphone.org
 *
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
 */

/*
 * Kobold Kit: ported CGVector functions to CGVector equivalents.
 */

#import "stdio.h"
#import "math.h"

#import "CGVectorExtension.h"
#import "CGPointExtension.h"

#if CGFLOAT_IS_DOUBLE
#define kCGVectorEpsilon DBL_EPSILON
#else
#define kCGVectorEpsilon FLT_EPSILON
#endif

const CGVector CGVectorZero = {0.0, 0.0};

CGFloat
ccvLength(const CGVector v)
{
	return sqrtf(ccvLengthSQ(v));
}

CGFloat
ccvDistance(const CGVector v1, const CGVector v2)
{
	return ccvLength(ccvSub(v1, v2));
}

CGVector
ccvNormalize(const CGVector v)
{
	return ccvMult(v, 1.0f / ccvLength(v));
}

CGVector
ccvForAngle(const CGFloat a)
{
	return ccv(cosf(a), sinf(a));
}

CGFloat
ccvToAngle(const CGVector v)
{
	return atan2f(v.dy, v.dx);
}

CGVector ccvLerp(CGVector a, CGVector b, float alpha)
{
	return ccvAdd(ccvMult(a, 1.f - alpha), ccvMult(b, alpha));
}

CGVector ccvClamp(CGVector p, CGVector min_inclusive, CGVector max_inclusive)
{
	return ccv(clampf(p.dx, min_inclusive.dx, max_inclusive.dx), clampf(p.dy, min_inclusive.dy, max_inclusive.dy));
}

CGVector ccvFromSize(CGSize s)
{
	return ccv(s.width, s.height);
}

CGVector ccvCompOp(CGVector p, float (* opFunc)(float))
{
	return ccv(opFunc(p.dx), opFunc(p.dy));
}

BOOL ccvFuzzyEqual(CGVector a, CGVector b, float var)
{
	if (a.dx - var <= b.dx && b.dx <= a.dx + var)
	{
		if (a.dy - var <= b.dy && b.dy <= a.dy + var)
		{
			return true;
		}
	}
	return false;
}

CGVector ccvCompMult(CGVector a, CGVector b)
{
	return ccv(a.dx * b.dx, a.dy * b.dy);
}

float ccvAngleSigned(CGVector a, CGVector b)
{
	CGVector a2 = ccvNormalize(a);
	CGVector b2 = ccvNormalize(b);
	float angle = atan2f(a2.dx * b2.dy - a2.dy * b2.dx, ccvDot(a2, b2));
	if (fabs(angle) < kCGVectorEpsilon)
	{
		return 0.f;
	}
	return angle;
}

CGVector ccvRotateByAngle(CGVector v, CGVector pivot, float angle)
{
	CGVector r = ccvSub(v, pivot);
	float cosa = cosf(angle), sina = sinf(angle);
	float t = r.dx;
	r.dx = t * cosa - r.dy * sina + pivot.dx;
	r.dy = t * sina + r.dy * cosa + pivot.dy;
	return r;
}

BOOL ccvSegmentIntersect(CGVector A, CGVector B, CGVector C, CGVector D)
{
	float S, T;

	if (ccvLineIntersect(A, B, C, D, &S, &T)
		&& (S >= 0.0f && S <= 1.0f && T >= 0.0f && T <= 1.0f))
	{
		return YES;
	}

	return NO;
}

CGVector ccvIntersectPoint(CGVector A, CGVector B, CGVector C, CGVector D)
{
	float S, T;

	if (ccvLineIntersect(A, B, C, D, &S, &T))
	{
		// Point of intersection
		CGVector P;
		P.dx = A.dx + S * (B.dx - A.dx);
		P.dy = A.dy + S * (B.dy - A.dy);
		return P;
	}

	return CGVectorZero;
}

BOOL ccvLineIntersect(CGVector A, CGVector B,
					  CGVector C, CGVector D,
					  float* S, float* T)
{
	// FAIL: Line undefined
	if ((A.dx == B.dx && A.dy == B.dy) || (C.dx == D.dx && C.dy == D.dy))
	{
		return NO;
	}

	const float BAx = B.dx - A.dx;
	const float BAy = B.dy - A.dy;
	const float DCx = D.dx - C.dx;
	const float DCy = D.dy - C.dy;
	const float ACx = A.dx - C.dx;
	const float ACy = A.dy - C.dy;

	const float denom = DCy * BAx - DCx * BAy;

	*S = DCx * ACy - DCy * ACx;
	*T = BAx * ACy - BAy * ACx;

	if (denom == 0)
	{
		if (*S == 0 || *T == 0)
		{
			// Lines incident
			return YES;
		}
		// Lines parallel and not incident
		return NO;
	}

	*S = *S / denom;
	*T = *T / denom;

	// Point of intersection
	// CGVector P;
	// P.dx = A.dx + *S * (B.dx - A.dx);
	// P.dy = A.dy + *S * (B.dy - A.dy);

	return YES;
} /* ccvLineIntersect */

float ccvAngle(CGVector a, CGVector b)
{
	float angle = acosf(ccvDot(ccvNormalize(a), ccvNormalize(b)));
	if (fabs(angle) < kCGVectorEpsilon)
	{
		return 0.f;
	}
	return angle;
}
