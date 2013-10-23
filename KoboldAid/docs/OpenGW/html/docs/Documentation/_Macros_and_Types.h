//
//  _Macros_and_Types.h
//  OpenGW
//
//  Created by Steffen Itterheim on 20/10/13.
//  Copyright (c) 2013 Steffen Itterheim. All rights reserved.
//

#ifndef OpenGW__Macros_and_Types_h
#define OpenGW__Macros_and_Types_h

/** 
 <h2>GWConfig.h / OGWConfig.h</h2>
 
 Configuration macros.
 
 <pre>
 // Defines which atomic lock strategy (if any) to use. Defaults to GCD locking via dispatch_sync.
 OGW_ATOMIC_USE_DISPATCH_SYNC
 <p/>
 The options are:
 OGW_ATOMIC_USE_DISPATCH_SYNC - default, uses dispatch_async(lock, block)
 OGW_ATOMIC_USE_SPIN_LOCK - uses NSSpinLock
 OGW_ATOMIC_USE_MUTEX_LOCK - uses pthread_mutex_(un)lock
 OGW_ATOMIC_USE_NSLOCK - uses NSLock
 OGW_ATOMIC_USE_SYNCHRONIZE - uses @synchronize(self)
 OGW_ATOMIC_USE_NONATOMIC - uses no locking mechanism at all - only use this if GW_CATEGORY_ALLOW_CONCURRENT_UPDATES in GWConfig.h is set to 0
 </pre>
 
 <h2>GWTypes.h / OGWTypes.h</h2>

Most GW* types are mapped directly to their CG/NS counterparts. Corresponding CG* functions are available as GW pendants (and where they are not, they need to be added).
The GW redefinitions are mainly used to make porting to other languages easier.
 
`GWVector2D` and `GWVector3D` can be used to (in the future) switch OpenGW to a fully 3D world simulation. Though currently no 3D math operations
 are included, meaning OpenGW can still be used for 3D worlds but only those representing a view on to a 2D world (for example games like Diablo, Starcraft).
 
`GW_FLOAT` defines the floating point representation.
 
<pre>
GWFLOAT_TYPE		// double on 64-bit, float on 32-bit systems
GWFLOAT_IS_DOUBLE	// is 1 if GWFLOAT_TYPE is double
GWFLOAT_MIN			// min value
GWFLOAT_MAX			// max value
GWFLOAT_EPSILON		// epsilon value
</pre>

Floating point functions mapped to float or double according to GWFLOAT_TYPE.
 
 <pre>
GW_SQRT(x)
GW_ATAN2(x, y)
GW_ACOS(x)
GW_COS(x)
GW_SIN(x)
GW_ABS(x)
// and so on...
</pre>

 
 
 */
@interface _Macros_and_Types
// stub class only for documentation
@end

#endif
