/*
 * Copyright (c) 2012-2013 Steffen Itterheim.
 * Released under the MIT License:
 * KoboldAid/licenses/KoboldKitFree.License.txt
 */


#import "KKModel.h"
#import "KKMutableNumber.h"

@implementation KKModel

+(id) model
{
	return [KKModel new];
}

-(void) dealloc
{
	//NSLog(@"dealloc: %@", self);
}

#pragma mark Key/Value Model
-(void) setValue:(id)value forKey:(NSString*)key
{
	[self setValue:value forKeyPath:key];
}

-(void) setValue:(id)value forKeyPath:(NSString*)keyPath
{
	if (_keyedValues == nil)
	{
		_keyedValues = [NSMutableDictionary dictionary];
	}
	
	[_keyedValues setValue:value forKeyPath:keyPath];
}

#pragma mark BOOL
-(void) setBool:(BOOL)boolValue forKey:(NSString*)key
{
	KKMutableNumber* value = [_keyedValues valueForKey:key];
	if (value)
	{
		value.boolValue = boolValue;
	}
	else
	{
		[self setValue:[[KKMutableNumber alloc] initWithBool:boolValue] forKey:key];
	}
}

-(BOOL) boolForKey:(NSString*)key
{
	KKMutableNumber* value = [_keyedValues valueForKey:key];
	return value ? value.boolValue : NO;
}

#pragma mark float
-(void) setFloat:(float)floatValue forKey:(NSString*)key
{
	KKMutableNumber* value = [_keyedValues valueForKey:key];
	if (value)
	{
		value.floatValue = floatValue;
	}
	else
	{
		[self setValue:[[KKMutableNumber alloc] initWithFloat:floatValue] forKey:key];
	}
}

-(float) floatForKey:(NSString*)key
{
	KKMutableNumber* value = [_keyedValues valueForKey:key];
	return value ? value.floatValue : 0.0f;
}

#pragma mark double
-(void) setDouble:(double)doubleValue forKey:(NSString*)key
{
	KKMutableNumber* value = [_keyedValues valueForKey:key];
	if (value)
	{
		value.doubleValue = doubleValue;
	}
	else
	{
		[self setValue:[[KKMutableNumber alloc] initWithDouble:doubleValue] forKey:key];
	}
}

-(double) doubleForKey:(NSString*)key
{
	KKMutableNumber* value = [_keyedValues valueForKey:key];
	return value ? value.doubleValue : 0.0;
}

#pragma mark int32
-(void) setInt32:(int32_t)int32Value forKey:(NSString*)key
{
	KKMutableNumber* value = [_keyedValues valueForKey:key];
	if (value)
	{
		value.intValue = int32Value;
	}
	else
	{
		[self setValue:[[KKMutableNumber alloc] initWithInt:int32Value] forKey:key];
	}
}

-(int32_t) int32ForKey:(NSString*)key
{
	KKMutableNumber* value = [_keyedValues valueForKey:key];
	return value ? value.intValue : 0;
}

-(void) setUnsignedInt32:(uint32_t)unsignedInt32Value forKey:(NSString*)key
{
	KKMutableNumber* value = [_keyedValues valueForKey:key];
	if (value)
	{
		value.unsignedIntValue = unsignedInt32Value;
	}
	else
	{
		[self setValue:[[KKMutableNumber alloc] initWithUnsignedInt:unsignedInt32Value] forKey:key];
	}
}

-(uint32_t) unsignedInt32ForKey:(NSString*)key
{
	KKMutableNumber* value = [_keyedValues valueForKey:key];
	return value ? value.unsignedIntValue : 0;
}

#pragma mark int64
-(void) setInt64:(int64_t)int64Value forKey:(NSString*)key
{
	KKMutableNumber* value = [_keyedValues valueForKey:key];
	if (value)
	{
		value.longLongValue = int64Value;
	}
	else
	{
		[self setValue:[[KKMutableNumber alloc] initWithLongLong:int64Value] forKey:key];
	}
}

-(int64_t) int64ForKey:(NSString*)key
{
	KKMutableNumber* value = [_keyedValues valueForKey:key];
	return value ? value.longLongValue : 0;
}

-(void) setUnsignedInt64:(uint64_t)unsignedInt64Value forKey:(NSString*)key
{
	KKMutableNumber* value = [_keyedValues valueForKey:key];
	if (value)
	{
		value.unsignedLongLongValue = unsignedInt64Value;
	}
	else
	{
		[self setValue:[[KKMutableNumber alloc] initWithUnsignedLongLong:unsignedInt64Value] forKey:key];
	}
}

-(uint64_t) unsignedInt64ForKey:(NSString*)key
{
	KKMutableNumber* value = [_keyedValues valueForKey:key];
	return value ? value.unsignedLongLongValue : 0;
}

-(KKMutableNumber*) mutableNumberForKey:(NSString*)key
{
	return [_keyedValues valueForKey:key];
}

#pragma mark object

-(void) setObject:(id)object forKey:(NSString*)key
{
	if (_keyedValues == nil)
	{
		_keyedValues = [NSMutableDictionary dictionary];
	}

	if (object == nil)
	{
		[_keyedValues removeObjectForKey:key];
	}
	else
	{
		[_keyedValues setObject:object forKey:key];
	}
}

-(id) objectForKey:(NSString*)key
{
	return [_keyedValues objectForKey:key];
}

#pragma mark KVC / KVO

-(id) valueForKeyPath:(NSString*)keyPath
{
	return [_keyedValues valueForKeyPath:keyPath];
}

-(BOOL) boolForKeyPath:(NSString*)keyPath
{
	id value = [_keyedValues valueForKeyPath:keyPath];
	if ([value isKindOfClass:[KKMutableNumber class]] || [value isKindOfClass:[NSNumber class]])
	{
		return [(NSNumber*)value boolValue];
	}
	return NO;
}
-(float) floatForKeyPath:(NSString*)keyPath
{
	id value = [_keyedValues valueForKeyPath:keyPath];
	if ([value isKindOfClass:[KKMutableNumber class]] || [value isKindOfClass:[NSNumber class]])
	{
		return [(NSNumber*)value floatValue];
	}
	return NO;
}
-(double) doubleForKeyPath:(NSString*)keyPath
{
	id value = [_keyedValues valueForKeyPath:keyPath];
	if ([value isKindOfClass:[KKMutableNumber class]] || [value isKindOfClass:[NSNumber class]])
	{
		return [(NSNumber*)value doubleValue];
	}
	return NO;
}
-(int32_t) intForKeyPath:(NSString*)keyPath
{
	id value = [_keyedValues valueForKeyPath:keyPath];
	if ([value isKindOfClass:[KKMutableNumber class]] || [value isKindOfClass:[NSNumber class]])
	{
		return [(NSNumber*)value intValue];
	}
	return NO;
}
-(uint32_t) unsignedIntForKeyPath:(NSString*)keyPath
{
	id value = [_keyedValues valueForKeyPath:keyPath];
	if ([value isKindOfClass:[KKMutableNumber class]] || [value isKindOfClass:[NSNumber class]])
	{
		return [(NSNumber*)value unsignedIntValue];
	}
	return NO;
}

#pragma mark !! Update methods below whenever class layout changes !!
#pragma mark NSCoding

// to be overridden by concrete implementation
-(id) initWithCoder:(NSCoder*)aDecoder
{
	[NSException raise:NSInternalInconsistencyException format:@"not yet implemented"];
	return nil;
}

-(void) encodeWithCoder:(NSCoder*)aCoder
{
	[NSException raise:NSInternalInconsistencyException format:@"not yet implemented"];
}

#pragma mark NSCopying

-(instancetype) copyWithZone:(NSZone *)zone
{
	[NSException raise:NSInternalInconsistencyException format:@"not yet implemented"];
	return nil;
}

#pragma mark Equality

DEVELOPER_TODO("model isEqualTo..")

@end
