//
//  GWTypes.h
//  OpenGW
//
//  Created by Steffen Itterheim on 16.09.13.
//  Copyright (c) 2013 Steffen Itterheim. All rights reserved.
//

#ifndef OpenGW_GWTypes_h
#define OpenGW_GWTypes_h

/* Definition of `GWFLOAT_TYPE', `GWFLOAT_IS_DOUBLE', `GWFLOAT_MIN', and `GWFLOAT_MAX'. */
#if defined(__LP64__) && __LP64__
#define GWFLOAT_TYPE double
#define GWFLOAT_IS_DOUBLE 1
#define GWFLOAT_MIN DBL_MIN
#define GWFLOAT_MAX DBL_MAX
#else
#define GWFLOAT_TYPE float
#define GWFLOAT_IS_DOUBLE 0
#define GWFLOAT_MIN FLT_MIN
#define GWFLOAT_MAX FLT_MAX
#endif

/* Definition of the `GWFloat' type. */
typedef GWFLOAT_TYPE GWFloat;

struct GWSize
{
	GWFloat x;
	GWFloat y;
};
typedef struct GWSize GWSize;

struct GWVector2D
{
	GWFloat x;
	GWFloat y;
};
typedef struct GWVector2D GWVector2D;

struct GWVector3D
{
	GWFloat x;
	GWFloat y;
	GWFloat z;
};
typedef struct GWVector3D GWVector3D;

/* Default vector/point types are 2D vectors. Truly 3D worlds may want to change GWVector to be represented by GWVector3D. */
typedef GWVector2D GWVector;
typedef GWVector2D GWPoint;

#endif
