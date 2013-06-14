//
//
// Created by Steffen Itterheim on 19.10.12.
//
//

#import "KKMutableNumber.h"

NSString* const CodingKeyForMutableNumber = @"KKMutableNumber:value";

#define toBool(n) ((n >= YES) ? YES : NO)

@implementation KTBoolNumber
-(id) initWithBool:(BOOL)boolNumber
{
	if ((self = [super init]))
	{
		_number = boolNumber;
	}

	return self;
}

-(id) initWithCoder:(NSCoder*)aDecoder
{
	return [self initWithBool:[aDecoder decodeBoolForKey:CodingKeyForMutableNumber]];
}

-(void) encodeWithCoder:(NSCoder*)aCoder
{
	[aCoder encodeBool:_number forKey:CodingKeyForMutableNumber];
}

-(BOOL) boolValue
{
	return (BOOL)_number;
}

-(void) setBoolValue:(BOOL)value
{
	_number = toBool(value);
}

-(char) charValue
{
	return (char)_number;
}

-(void) setCharValue:(char)value
{
	_number = toBool(value);
}

-(double) doubleValue
{
	return (double)_number;
}

-(void) setDoubleValue:(double)value
{
	_number = toBool(value);
}

-(float) floatValue
{
	return (float)_number;
}

-(void) setFloatValue:(float)value
{
	_number = toBool(value);
}

-(NSInteger) integerValue
{
	return (NSInteger)_number;
}

-(void) setIntegerValue:(NSInteger)value
{
	_number = toBool(value);
}

-(int) intValue
{
	return (int)_number;
}

-(void) setIntValue:(int)value
{
	_number = toBool(value);
}

-(long long) longLongValue
{
	return (long long)_number;
}

-(void) setLongLongValue:(long long)value
{
	_number = toBool(value);
}

-(long) longValue
{
	return (long)_number;
}

-(void) setLongValue:(long)value
{
	_number = toBool(value);
}

-(short) shortValue
{
	return (short)_number;
}

-(void) setShortValue:(short)value
{
	_number = toBool(value);
}

-(unsigned char) unsignedCharValue
{
	return (unsigned char)_number;
}

-(void) setUnsignedCharValue:(unsigned char)value
{
	_number = toBool(value);
}

-(unsigned int) unsignedIntValue
{
	return (unsigned int)_number;
}

-(void) setUnsignedIntValue:(unsigned int)value
{
	_number = toBool(value);
}

-(NSUInteger) unsignedIntegerValue
{
	return (NSUInteger)_number;
}

-(void) setUnsignedIntegerValue:(NSUInteger)value
{
	_number = toBool(value);
}

-(unsigned long long) unsignedLongLongValue
{
	return (unsigned long long)_number;
}

-(void) setUnsignedLongLongValue:(unsigned long long)value
{
	_number = toBool(value);
}

-(unsigned long) unsignedLongValue
{
	return (unsigned long)_number;
}

-(void) setUnsignedLongValue:(unsigned long)value
{
	_number = toBool(value);
}

-(unsigned short) unsignedShortValue
{
	return (unsigned short)_number;
}

-(void) setUnsignedShortValue:(unsigned short)value
{
	_number = toBool(value);
}

@end

@implementation KTFloatNumber
-(id) initWithFloat:(float)floatNumber
{
	if ((self = [super init]))
	{
		_number = floatNumber;
	}

	return self;
}

-(id) initWithCoder:(NSCoder*)aDecoder
{
	return [self initWithFloat:[aDecoder decodeFloatForKey:CodingKeyForMutableNumber]];
}

-(void) encodeWithCoder:(NSCoder*)aCoder
{
	[aCoder encodeFloat:_number forKey:CodingKeyForMutableNumber];
}

-(BOOL) boolValue
{
	return (BOOL)_number;
}

-(void) setBoolValue:(BOOL)value
{
	_number = value;
}

-(char) charValue
{
	return (char)_number;
}

-(void) setCharValue:(char)value
{
	_number = value;
}

-(double) doubleValue
{
	return (double)_number;
}

-(void) setDoubleValue:(double)value
{
	_number = value;
}

-(float) floatValue
{
	return (float)_number;
}

-(void) setFloatValue:(float)value
{
	_number = value;
}

-(NSInteger) integerValue
{
	return (NSInteger)_number;
}

-(void) setIntegerValue:(NSInteger)value
{
	_number = value;
}

-(int) intValue
{
	return (int)_number;
}

-(void) setIntValue:(int)value
{
	_number = value;
}

-(long long) longLongValue
{
	return (long long)_number;
}

-(void) setLongLongValue:(long long)value
{
	_number = value;
}

-(long) longValue
{
	return (long)_number;
}

-(void) setLongValue:(long)value
{
	_number = value;
}

-(short) shortValue
{
	return (short)_number;
}

-(void) setShortValue:(short)value
{
	_number = value;
}

-(unsigned char) unsignedCharValue
{
	return (unsigned char)_number;
}

-(void) setUnsignedCharValue:(unsigned char)value
{
	_number = value;
}

-(unsigned int) unsignedIntValue
{
	return (unsigned int)_number;
}

-(void) setUnsignedIntValue:(unsigned int)value
{
	_number = value;
}

-(NSUInteger) unsignedIntegerValue
{
	return (NSUInteger)_number;
}

-(void) setUnsignedIntegerValue:(NSUInteger)value
{
	_number = value;
}

-(unsigned long long) unsignedLongLongValue
{
	return (unsigned long long)_number;
}

-(void) setUnsignedLongLongValue:(unsigned long long)value
{
	_number = value;
}

-(unsigned long) unsignedLongValue
{
	return (unsigned long)_number;
}

-(void) setUnsignedLongValue:(unsigned long)value
{
	_number = value;
}

-(unsigned short) unsignedShortValue
{
	return (unsigned short)_number;
}

-(void) setUnsignedShortValue:(unsigned short)value
{
	_number = value;
}

@end

@implementation KTDoubleNumber
-(id) initWithDouble:(double)doubleNumber
{
	if ((self = [super init]))
	{
		_number = doubleNumber;
	}

	return self;
}

-(id) initWithCoder:(NSCoder*)aDecoder
{
	return [self initWithDouble:[aDecoder decodeDoubleForKey:CodingKeyForMutableNumber]];
}

-(void) encodeWithCoder:(NSCoder*)aCoder
{
	[aCoder encodeDouble:_number forKey:CodingKeyForMutableNumber];
}

-(BOOL) boolValue
{
	return (BOOL)_number;
}

-(void) setBoolValue:(BOOL)value
{
	_number = value;
}

-(char) charValue
{
	return (char)_number;
}

-(void) setCharValue:(char)value
{
	_number = value;
}

-(double) doubleValue
{
	return (double)_number;
}

-(void) setDoubleValue:(double)value
{
	_number = value;
}

-(float) floatValue
{
	return (float)_number;
}

-(void) setFloatValue:(float)value
{
	_number = value;
}

-(NSInteger) integerValue
{
	return (NSInteger)_number;
}

-(void) setIntegerValue:(NSInteger)value
{
	_number = value;
}

-(int) intValue
{
	return (int)_number;
}

-(void) setIntValue:(int)value
{
	_number = value;
}

-(long long) longLongValue
{
	return (long long)_number;
}

-(void) setLongLongValue:(long long)value
{
	_number = value;
}

-(long) longValue
{
	return (long)_number;
}

-(void) setLongValue:(long)value
{
	_number = value;
}

-(short) shortValue
{
	return (short)_number;
}

-(void) setShortValue:(short)value
{
	_number = value;
}

-(unsigned char) unsignedCharValue
{
	return (unsigned char)_number;
}

-(void) setUnsignedCharValue:(unsigned char)value
{
	_number = value;
}

-(unsigned int) unsignedIntValue
{
	return (unsigned int)_number;
}

-(void) setUnsignedIntValue:(unsigned int)value
{
	_number = value;
}

-(NSUInteger) unsignedIntegerValue
{
	return (NSUInteger)_number;
}

-(void) setUnsignedIntegerValue:(NSUInteger)value
{
	_number = value;
}

-(unsigned long long) unsignedLongLongValue
{
	return (unsigned long long)_number;
}

-(void) setUnsignedLongLongValue:(unsigned long long)value
{
	_number = value;
}

-(unsigned long) unsignedLongValue
{
	return (unsigned long)_number;
}

-(void) setUnsignedLongValue:(unsigned long)value
{
	_number = value;
}

-(unsigned short) unsignedShortValue
{
	return (unsigned short)_number;
}

-(void) setUnsignedShortValue:(unsigned short)value
{
	_number = value;
}

@end

@implementation KTInt32Number
-(id) initWithInt32:(int)int32Number
{
	if ((self = [super init]))
	{
		_number = int32Number;
	}

	return self;
}

-(id) initWithCoder:(NSCoder*)aDecoder
{
	return [self initWithInt32:[aDecoder decodeInt32ForKey:CodingKeyForMutableNumber]];
}

-(void) encodeWithCoder:(NSCoder*)aCoder
{
	[aCoder encodeInt32:_number forKey:CodingKeyForMutableNumber];
}

-(BOOL) boolValue
{
	return (BOOL)_number;
}

-(void) setBoolValue:(BOOL)value
{
	_number = value;
}

-(char) charValue
{
	return (char)_number;
}

-(void) setCharValue:(char)value
{
	_number = value;
}

-(double) doubleValue
{
	return (double)_number;
}

-(void) setDoubleValue:(double)value
{
	_number = value;
}

-(float) floatValue
{
	return (float)_number;
}

-(void) setFloatValue:(float)value
{
	_number = value;
}

-(NSInteger) integerValue
{
	return (NSInteger)_number;
}

-(void) setIntegerValue:(NSInteger)value
{
	_number = (int32_t)value;
}

-(int) intValue
{
	return (int)_number;
}

-(void) setIntValue:(int)value
{
	_number = value;
}

-(long long) longLongValue
{
	return (long long)_number;
}

-(void) setLongLongValue:(long long)value
{
	_number = (int32_t)value;
}

-(long) longValue
{
	return (long)_number;
}

-(void) setLongValue:(long)value
{
	_number = (int32_t)value;
}

-(short) shortValue
{
	return (short)_number;
}

-(void) setShortValue:(short)value
{
	_number = value;
}

-(unsigned char) unsignedCharValue
{
	return (unsigned char)_number;
}

-(void) setUnsignedCharValue:(unsigned char)value
{
	_number = value;
}

-(unsigned int) unsignedIntValue
{
	return (unsigned int)_number;
}

-(void) setUnsignedIntValue:(unsigned int)value
{
	_number = value;
}

-(NSUInteger) unsignedIntegerValue
{
	return (NSUInteger)_number;
}

-(void) setUnsignedIntegerValue:(NSUInteger)value
{
	_number = (int32_t)value;
}

-(unsigned long long) unsignedLongLongValue
{
	return (unsigned long long)_number;
}

-(void) setUnsignedLongLongValue:(unsigned long long)value
{
	_number = (int32_t)value;
}

-(unsigned long) unsignedLongValue
{
	return (unsigned long)_number;
}

-(void) setUnsignedLongValue:(unsigned long)value
{
	_number = (int32_t)value;
}

-(unsigned short) unsignedShortValue
{
	return (unsigned short)_number;
}

-(void) setUnsignedShortValue:(unsigned short)value
{
	_number = value;
}

@end

@implementation KTInt64Number
-(id) initWithInt64:(int64_t)int64Number
{
	if ((self = [super init]))
	{
		_number = int64Number;
	}

	return self;
}

-(id) initWithCoder:(NSCoder*)aDecoder
{
	return [self initWithInt64:[aDecoder decodeInt64ForKey:CodingKeyForMutableNumber]];
}

-(void) encodeWithCoder:(NSCoder*)aCoder
{
	[aCoder encodeInt64:_number forKey:CodingKeyForMutableNumber];
}

-(BOOL) boolValue
{
	return (BOOL)_number;
}

-(void) setBoolValue:(BOOL)value
{
	_number = value;
}

-(char) charValue
{
	return (char)_number;
}

-(void) setCharValue:(char)value
{
	_number = value;
}

-(double) doubleValue
{
	return (double)_number;
}

-(void) setDoubleValue:(double)value
{
	_number = value;
}

-(float) floatValue
{
	return (float)_number;
}

-(void) setFloatValue:(float)value
{
	_number = value;
}

-(NSInteger) integerValue
{
	return (NSInteger)_number;
}

-(void) setIntegerValue:(NSInteger)value
{
	_number = value;
}

-(int) intValue
{
	return (int)_number;
}

-(void) setIntValue:(int)value
{
	_number = value;
}

-(long long) longLongValue
{
	return (long long)_number;
}

-(void) setLongLongValue:(long long)value
{
	_number = value;
}

-(long) longValue
{
	return (long)_number;
}

-(void) setLongValue:(long)value
{
	_number = value;
}

-(short) shortValue
{
	return (short)_number;
}

-(void) setShortValue:(short)value
{
	_number = value;
}

-(unsigned char) unsignedCharValue
{
	return (unsigned char)_number;
}

-(void) setUnsignedCharValue:(unsigned char)value
{
	_number = value;
}

-(unsigned int) unsignedIntValue
{
	return (unsigned int)_number;
}

-(void) setUnsignedIntValue:(unsigned int)value
{
	_number = value;
}

-(NSUInteger) unsignedIntegerValue
{
	return (NSUInteger)_number;
}

-(void) setUnsignedIntegerValue:(NSUInteger)value
{
	_number = value;
}

-(unsigned long long) unsignedLongLongValue
{
	return (unsigned long long)_number;
}

-(void) setUnsignedLongLongValue:(unsigned long long)value
{
	_number = value;
}

-(unsigned long) unsignedLongValue
{
	return (unsigned long)_number;
}

-(void) setUnsignedLongValue:(unsigned long)value
{
	_number = value;
}

-(unsigned short) unsignedShortValue
{
	return (unsigned short)_number;
}

-(void) setUnsignedShortValue:(unsigned short)value
{
	_number = value;
}

@end

@implementation KKMutableNumber

@dynamic boolValue, charValue, doubleValue, floatValue, integerValue, intValue, longLongValue, longValue, shortValue;
@dynamic unsignedCharValue, unsignedIntegerValue, unsignedIntValue, unsignedLongLongValue, unsignedLongValue, unsignedShortValue;

#pragma mark Cluster Init

+(id) numberWithBool:(BOOL)number
{
	return [[KTBoolNumber alloc] initWithBool:number];
}

+(id) numberWithChar:(char)number
{
	return [[KTInt32Number alloc] initWithInt32:number];
}

+(id) numberWithDouble:(double)number
{
	return [[KTDoubleNumber alloc] initWithDouble:number];
}

+(id) numberWithFloat:(float)number
{
	return [[KTFloatNumber alloc] initWithFloat:number];
}

+(id) numberWithInt:(int)number
{
	return [[KTInt32Number alloc] initWithInt32:number];
}

+(id) numberWithInteger:(NSInteger)number
{
#if TARGET_OS_IPHONE
	return [[KTInt32Number alloc] initWithInt32:number];
#elif TARGET_OS_MAC
	return [[KTInt64Number alloc] initWithInt64:number];
#endif
}

+(id) numberWithLong:(long)number
{
#if TARGET_OS_IPHONE
	return [[KTInt32Number alloc] initWithInt32:number];
#elif TARGET_OS_MAC
	return [[KTInt64Number alloc] initWithInt64:number];
#endif
}

+(id) numberWithLongLong:(long long)number
{
	return [[KTInt64Number alloc] initWithInt64:number];
}

+(id) numberWithShort:(short)number
{
	return [[KTInt32Number alloc] initWithInt32:number];
}

+(id) numberWithUnsignedChar:(unsigned char)number
{
	return [[KTInt32Number alloc] initWithInt32:number];
}

+(id) numberWithUnsignedInt:(unsigned int)number
{
	return [[KTInt32Number alloc] initWithInt32:number];
}

+(id) numberWithUnsignedInteger:(NSUInteger)number
{
#if TARGET_OS_IPHONE
	return [[KTInt32Number alloc] initWithInt32:number];
#elif TARGET_OS_MAC
	return [[KTInt64Number alloc] initWithInt64:number];
#endif
}

+(id) numberWithUnsignedLong:(unsigned long)number
{
#if TARGET_OS_IPHONE
	return [[KTInt32Number alloc] initWithInt32:number];
#elif TARGET_OS_MAC
	return [[KTInt64Number alloc] initWithInt64:number];
#endif
}

+(id) numberWithUnsignedLongLong:(unsigned long long)number
{
	return [[KTInt64Number alloc] initWithInt64:number];
}

+(id) numberWithUnsignedShort:(unsigned short)number
{
	return [[KTInt32Number alloc] initWithInt32:number];
}

-(id) initWithBool:(BOOL)number
{
	return [[KTBoolNumber alloc] initWithBool:number];
}

-(id) initWithChar:(char)number
{
	return [[KTInt32Number alloc] initWithInt32:number];
}

-(id) initWithDouble:(double)number
{
	return [[KTDoubleNumber alloc] initWithDouble:number];
}

-(id) initWithFloat:(float)number
{
	return [[KTFloatNumber alloc] initWithFloat:number];
}

-(id) initWithInt:(int)number
{
	return [[KTInt32Number alloc] initWithInt32:number];
}

-(id) initWithInteger:(NSInteger)number
{
#if TARGET_OS_IPHONE
	return [[KTInt32Number alloc] initWithInt32:number];
#elif TARGET_OS_MAC
	return [[KTInt64Number alloc] initWithInt64:number];
#endif
}

-(id) initWithLong:(long)number
{
#if TARGET_OS_IPHONE
	return [[KTInt32Number alloc] initWithInt32:number];
#elif TARGET_OS_MAC
	return [[KTInt64Number alloc] initWithInt64:number];
#endif
}

-(id) initWithLongLong:(long long)number
{
	return [[KTInt64Number alloc] initWithInt64:number];
}

-(id) initWithShort:(short)number
{
	return [[KTInt32Number alloc] initWithInt32:number];
}

-(id) initWithUnsignedChar:(unsigned char)number
{
	return [[KTInt32Number alloc] initWithInt32:number];
}

-(id) initWithUnsignedInt:(unsigned int)number
{
	return [[KTInt32Number alloc] initWithInt32:number];
}

-(id) initWithUnsignedInteger:(NSUInteger)number
{
#if TARGET_OS_IPHONE
	return [[KTInt32Number alloc] initWithInt32:number];
#elif TARGET_OS_MAC
	return [[KTInt64Number alloc] initWithInt64:number];
#endif
}

-(id) initWithUnsignedLong:(unsigned long)number
{
#if TARGET_OS_IPHONE
	return [[KTInt32Number alloc] initWithInt32:number];
#elif TARGET_OS_MAC
	return [[KTInt64Number alloc] initWithInt64:number];
#endif
}

-(id) initWithUnsignedLongLong:(unsigned long long)number
{
	return [[KTInt64Number alloc] initWithInt64:number];
}

-(id) initWithUnsignedShort:(unsigned short)number
{
	return [[KTInt32Number alloc] initWithInt32:number];
}

#pragma mark !! Update methods below whenever class layout changes !!
#pragma mark NSCoding

// to be overridden by concrete implementation
-(id) initWithCoder:(NSCoder*)aDecoder
{
	[NSException raise:NSInternalInconsistencyException format:@"KKMutableNumber should not be decoded, it's an abstract class cluster interface"];
	return nil;
}

-(void) encodeWithCoder:(NSCoder*)aCoder
{
	[NSException raise:NSInternalInconsistencyException format:@"KKMutableNumber should not be encoded, it's an abstract class cluster interface"];
}

#pragma mark NSCopying

-(instancetype) copyWithZone:(NSZone *)zone
{
	[NSException raise:NSInternalInconsistencyException format:@"KKMutableNumber should not be encoded, it's an abstract class cluster interface"];
	return nil;
}

#pragma mark Equality

@end
