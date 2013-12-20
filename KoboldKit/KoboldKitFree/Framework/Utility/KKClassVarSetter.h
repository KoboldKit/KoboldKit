/*
 * Copyright (c) 2012-2013 Steffen Itterheim.
 * Released under the MIT License:
 * KoboldAid/licenses/KoboldKitFree.License.txt
 */

#import <Foundation/Foundation.h>

// var types
typedef NS_ENUM(NSUInteger, KKIvarType)
{
	KKIvarTypeUnknown = 0,
	KKIvarTypeBOOL,
	KKIvarTypeChar,
	KKIvarTypeUnsignedChar,
	KKIvarTypeInt,
	KKIvarTypeUnsignedInt,
	KKIvarTypeDouble,
	KKIvarTypeFloat,
	KKIvarTypePoint,
	KKIvarTypeVector,
	KKIvarTypeSize,
	KKIvarTypeRect,
	KKIvarTypeString,
};

/** INTERNAL USE! Class that represents an ivar in order to set and get an ivar's value. */
@interface KKIvarInfo : NSObject
/** The Objective-C Ivar object. */
@property (atomic) Ivar ivar;
/** The name of the ivar. */
@property (atomic, copy) NSString* name;
/** The @encoding of the ivar. Not all ObjC encodings are supported, mainly integral data types plus the point, size and rect structures. */
@property (nonatomic, copy) NSString* encoding;
/** The type of the ivar which is deducted from the encoding. */
@property (atomic, readonly) KKIvarType type;
/** Set the ivar in the given target to the value.
 @param target The target object for the ivar.
 @param value The value to assign to the ivar. */
-(void) setIvarInTarget:(id)target value:(id)value;
@end

/** Utility class that allows to set an object's ivars from a NSDictionary. The dictionary must have strings as keys (the ivar names)
   and KKMutableNumber or NSString types as values. */
@interface KKClassVarSetter : NSObject
{
	@private
	Class _class;
	Ivar* _ivars;
	NSMutableArray* _ivarInfos;
}

/** Initialize ivar setter with a class.
 @param class The class on which to set variables.
 @returns A new instance of KKClassVarSetter */
-(id) initWithClass:(Class)klass;

/** Sets the ivars in the target if their key in the dictionary matches the ivar name and type. The dictionary must have NSString as keys
   and either NSString or KKMutableNumber as values. The target's class must match the class the KKClassVarSetter object was initialized with.
 @param ivarsDictionary A NSString keyed dictionary with values for ivars. The keys must begin with _ which is the standard prefix of ivar names.
 @param target The target to which to set the ivar values. */
-(void) setIvarsWithDictionary:(NSDictionary*)ivarsDictionary target:(id)target;
/** nd */
-(void) setIvarsWithDictionary:(NSDictionary*)ivarsDictionary mapping:(NSDictionary*)mapping target:(id)target;

/** Calls property setters in the target by using setValue:forKey: (KVC). The dictionary must have NSString as keys
 and either NSString or KKMutableNumber as values which must match or be convertible to the property's type. 
 The target's class must match the class the KKClassVarSetter object was initialized with.
 @param propertiesDictionary A NSString keyed dictionary with values for properties. The keys must match existing properties' names for the given class.
 @param target The target to which to set the properties. */
-(void) setPropertiesWithDictionary:(NSDictionary*)propertiesDictionary target:(id)target;
/** nd */
-(void) setPropertiesWithDictionary:(NSDictionary*)propertiesDictionary mapping:(NSDictionary*)mapping target:(id)target;

@end
