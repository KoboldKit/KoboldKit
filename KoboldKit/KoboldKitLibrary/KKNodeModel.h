//
//  KKNodeModel.h
//  KoboldKit
//
//  Created by Steffen Itterheim on 14.06.13.
//  Copyright (c) 2013 Steffen Itterheim. All rights reserved.
//

#import <Foundation/Foundation.h>

@class KKNodeController;
@class KKMutableNumber;

/** Model object allows you to story integral data types by key (name) as mutable numbers.
 Useful to store automatically NSCoding/NSCopying conformant values to any node without having to subclass it. */
@interface KKNodeModel : NSObject <NSCoding, NSCopying>
{
	@private
	NSMutableDictionary* _keyedValues;
}

/** @returns The model's controller object. You should never change this reference yourself! */
@property (nonatomic, weak) KKNodeController* controller;

/** Set value of the given type for key. Value is mutable, it is not an NSNumber to avoid alloc/dealloc for every set. */
-(void) setBool:(BOOL)boolValue forKey:(NSString*)key;
/** Returns the value of the given type for key. Returns NO if there's no value with this key. */
-(BOOL) boolForKey:(NSString*)key;
/** Set value of the given type for key. Value is mutable, it is not an NSNumber to avoid alloc/dealloc for every set. */
-(void) setFloat:(float)floatValue forKey:(NSString*)key;
/** Returns the value of the given type for key. Returns 0 if there's no value with this key. */
-(float) floatForKey:(NSString*)key;
/** Set value of the given type for key. Value is mutable, it is not an NSNumber to avoid alloc/dealloc for every set. */
-(void) setDouble:(double)doubleValue forKey:(NSString*)key;
/** Returns the value of the given type for key. Returns 0 if there's no value with this key. */
-(double) doubleForKey:(NSString*)key;
/** Set value (32-Bit) of the given type for key. Value is mutable, it is not an NSNumber to avoid alloc/dealloc for every set. */
-(void) setInt32:(int32_t)int32Value forKey:(NSString*)key;
/** Returns the value (32-Bit) of the given type for key. Returns 0 if there's no value with this key. */
-(int32_t) int32ForKey:(NSString*)key;
/** Set value (32-Bit) of the given type for key. Value is mutable, it is not an NSNumber to avoid alloc/dealloc for every set. */
-(void) setUnsignedInt32:(uint32_t)unsignedInt32Value forKey:(NSString*)key;
/** Returns the value (32-Bit) of the given type for key. Returns 0 if there's no value with this key. */
-(uint32_t) unsignedInt32ForKey:(NSString*)key;
/** Set value (64-Bit) of the given type for key. Value is mutable, it is not an NSNumber to avoid alloc/dealloc for every set. */
-(void) setInt64:(int64_t)int64Value forKey:(NSString*)key;
/** Returns the value (64-Bit) of the given type for key. Returns 0 if there's no value with this key. */
-(int64_t) int64ForKey:(NSString*)key;
/** Set value (64-Bit) of the given type for key. Value is mutable, it is not an NSNumber to avoid alloc/dealloc for every set. */
-(void) setUnsignedInt64:(uint64_t)unsignedInt64Value forKey:(NSString*)key;
/** Returns the value (64-Bit) of the given type for key. Returns 0 if there's no value with this key. */
-(uint64_t) unsignedInt64ForKey:(NSString*)key;
/** Assign or replace any object with the given key. If object is nil, the object for that key will be removed. */
-(void) setObject:(id)object forKey:(NSString*)key;
/** Returns the object for key. Returns nil if there's no object associated with this key. */
-(id) objectForKey:(NSString*)key;

/** Returns the underlying KTMutableNumber object for a specific variable key. You can then modify the
 number value without having to reassign it to the model. */
-(KKMutableNumber*) mutableNumberForKey:(NSString*)key;

@end
