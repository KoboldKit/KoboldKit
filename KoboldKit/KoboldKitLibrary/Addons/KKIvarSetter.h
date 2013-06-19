//
// KKIvarSetter.h
// KoboldTouch-Libraries
//
// Created by Steffen Itterheim on 02.03.13.
//
//

#import <Foundation/Foundation.h>

typedef enum
{
	KKIvarTypeUnknown = 0,
	KKIvarTypeChar,
	KKIvarTypeUnsignedChar,
	KKIvarTypeInt,
	KKIvarTypeUnsignedInt,
	KKIvarTypeDouble,
	KKIvarTypeFloat,
	KKIvarTypePoint,
	KKIvarTypeSize,
	KKIvarTypeRect,
	KKIvarTypeString,
} KKIvarType;

/** INTERNAL USE! Class that represents an ivar in order to set and get an ivar's value. */
@interface KKIvarInfo : NSObject
/** The Objective-C Ivar object. */
@property (nonatomic) Ivar ivar;
/** The name of the ivar. */
@property (nonatomic, copy) NSString* name;
/** The @encoding of the ivar. Not all ObjC encodings are supported, mainly integral data types plus the point, size and rect structures. */
@property (nonatomic, copy) NSString* encoding;
/** The type of the ivar which is deducted from the encoding. */
@property (nonatomic, readonly) KKIvarType type;
/** Set the ivar in the given target to the value. */
-(void) setIvarInTarget:(id)target value:(id)value;
@end

/** Utility class that allows to set an object's ivars from a NSDictionary. The dictionary must have strings as keys (the ivar names)
   and KKMutableNumber or NSString types as values. */
@interface KKIvarSetter : NSObject
{
	@private
	Class _class;
	Ivar* _ivars;
	NSMutableArray* _ivarInfos;
}

/** Initialize ivar setter with a class. */
-(id) initWithClass:(Class)class;

/** Sets the ivars in the target if their key in the dictionary matches the ivar name and type. The dictionary must have NSString as keys
   and either NSString or KKMutableNumber as values. The target's class must match the class the KKIvarSetter object was initialized with. */
-(void) setIvarsFromDictionary:(NSDictionary*)ivarsDictionary target:(id)target;

@end
