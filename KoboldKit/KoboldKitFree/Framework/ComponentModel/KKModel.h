/*
 * Copyright (c) 2012-2013 Steffen Itterheim.
 * Released under the MIT License:
 * KoboldAid/licenses/KoboldKitFree.License.txt
 */

#import <Foundation/Foundation.h>

@class KKNodeController;
@class KKMutableNumber;

/** Model object allows you to story integral data types by key (name) as mutable numbers.
 Useful to store automatically NSCoding/NSCopying conformant values to any node without having to subclass it. */
@interface KKModel : NSObject <NSCoding, NSCopying>
{
	@private
	NSMutableDictionary* _keyedValues;
}

/** @returns The model's controller object. You should never change this reference yourself! */
@property (atomic, weak) KKNodeController* controller;

/** @returns A new instance. */
+(id) model;

/** @name Bool Variables */

/** Set value of the given type for key. Value is mutable, it is not an NSNumber to avoid alloc/dealloc for every set.
 @param boolValue A boolean.
 @param key A unique string to identify the variable.
*/
-(void) setBool:(BOOL)boolValue forKey:(NSString*)key;
/** Returns the value of the given type for key. Returns NO if there's no value with this key. 
 @param key A unique string identifying the variable.
 @returns The BOOL value for the key, or NO if there's no variable with that key.
 */
-(BOOL) boolForKey:(NSString*)key;

/** @name Float Variables */

/** Set value of the given type for key. Value is mutable, it is not an NSNumber to avoid alloc/dealloc for every set.
 @param floatValue A float.
 @param key A unique string to identify the variable.
*/
-(void) setFloat:(float)floatValue forKey:(NSString*)key;
/** Returns the value of the given type for key. Returns 0 if there's no value with this key. 
 @param key A unique string identifying the variable.
 @returns The float value for the key, or 0.0f if there's no variable with that key.
*/
-(float) floatForKey:(NSString*)key;

/** @name Double Variables */

/** Set value of the given type for key. Value is mutable, it is not an NSNumber to avoid alloc/dealloc for every set. 
 @param doubleValue A double.
 @param key A unique string to identify the variable.
*/
-(void) setDouble:(double)doubleValue forKey:(NSString*)key;
/** Returns the value of the given type for key. Returns 0 if there's no value with this key. 
 @param key A unique string identifying the variable.
 @returns The double value for the key, or 0.0 if there's no variable with that key.
*/
-(double) doubleForKey:(NSString*)key;

/** @name Integer Variables */

/** Set value (32-Bit) of the given type for key. Value is mutable, it is not an NSNumber to avoid alloc/dealloc for every set. 
 @param int32Value A 32-bit integer.
 @param key A unique string to identify the variable.
*/
-(void) setInt32:(int32_t)int32Value forKey:(NSString*)key;
/** Returns the value (32-Bit) of the given type for key. Returns 0 if there's no value with this key.
 @param key A unique string identifying the variable.
 @returns The int32_t value for the key, or 0 if there's no variable with that key.
*/
-(int32_t) int32ForKey:(NSString*)key;
/** Set value (32-Bit) of the given type for key. Value is mutable, it is not an NSNumber to avoid alloc/dealloc for every set. 
 @param unsignedInt32Value An unsigned 32-bit integer.
 @param key A unique string to identify the variable.
*/
-(void) setUnsignedInt32:(uint32_t)unsignedInt32Value forKey:(NSString*)key;
/** Returns the value (32-Bit) of the given type for key. Returns 0 if there's no value with this key.
 @param key A unique string identifying the variable.
 @returns The uint32_t value for the key, or 0 if there's no variable with that key.
*/
-(uint32_t) unsignedInt32ForKey:(NSString*)key;
/** Set value (64-Bit) of the given type for key. Value is mutable, it is not an NSNumber to avoid alloc/dealloc for every set. 
 @param int64Value A 64-bit integer.
 @param key A unique string to identify the variable.
*/
-(void) setInt64:(int64_t)int64Value forKey:(NSString*)key;
/** Returns the value (64-Bit) of the given type for key. Returns 0 if there's no value with this key. 
 @param key A unique string identifying the variable.
 @returns The int64_t value for the key, or 0 if there's no variable with that key.
*/
-(int64_t) int64ForKey:(NSString*)key;
/** Set value (64-Bit) of the given type for key. Value is mutable, it is not an NSNumber to avoid alloc/dealloc for every set. 
 @param unsignedInt64Value An unsigned 64-bit integer.
 @param key A unique string to identify the variable.
*/
-(void) setUnsignedInt64:(uint64_t)unsignedInt64Value forKey:(NSString*)key;
/** Returns the value (64-Bit) of the given type for key. Returns 0 if there's no value with this key. 
 @param key A unique string identifying the variable.
 @returns The uint64_t value for the key, or 0 if there's no variable with that key.
*/
-(uint64_t) unsignedInt64ForKey:(NSString*)key;

/** @name Arbitrary Object Variables */

/** Assign or replace any object with the given key. If object is nil, the object for that key will be removed. 
 @param object The object to store in the dictionary.
 @param key A unique string to identify the object.
*/
-(void) setObject:(id)object forKey:(NSString*)key;
/**  @param key A unique string identifying the object.
 @returns The object for key or nil if there's no object associated with this key. */
-(id) objectForKey:(NSString*)key;

/** KVC / KVO */

/** @param keyPath The KVC path to a value.
 @returns The value for the path, or nil. */
-(id) valueForKeyPath:(NSString*)keyPath;

/** @param keyPath The KVC path to a value.
 @returns The value for the path, or nil. */
-(BOOL) boolForKeyPath:(NSString*)keyPath;
/** @param keyPath The KVC path to a value.
 @returns The value for the path, or nil. */
-(float) floatForKeyPath:(NSString*)keyPath;
/** @param keyPath The KVC path to a value.
 @returns The value for the path, or nil. */
-(double) doubleForKeyPath:(NSString*)keyPath;
/** @param keyPath The KVC path to a value.
 @returns The value for the path, or nil. */
-(int32_t) intForKeyPath:(NSString*)keyPath;
/** @param keyPath The KVC path to a value.
 @returns The value for the path, or nil. */
-(uint32_t) unsignedIntForKeyPath:(NSString*)keyPath;

/** @name Getting a Mutable Number */

/** Accessing the KKMutableNumber object directly allows you to change the value without having to reassign it using a setter method.
 @returns The underlying KKMutableNumber object for a specific variable.
 @param key A unique string identifying the variable.
 @returns A mutable number object or nil if no variable with the given key was found. */
-(KKMutableNumber*) mutableNumberForKey:(NSString*)key;

@end
