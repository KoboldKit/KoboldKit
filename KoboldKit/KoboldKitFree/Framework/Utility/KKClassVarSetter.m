/*
 * Copyright (c) 2012-2013 Steffen Itterheim.
 * Released under the MIT License:
 * KoboldAid/licenses/KoboldKitFree.License.txt
 */

#import "KKClassVarSetter.h"
#import "KKMutableNumber.h"
#import "KKTypes.h"

#import <objc/runtime.h>

@implementation KKIvarInfo

static Class kStringClass;
static Class kMutableNumberClass;

-(id) init
{
	self = [super init];
	if (self)
	{
		kStringClass = [NSString class];
		kMutableNumberClass = [KKMutableNumber class];
	}

	return self;
}

-(NSString*) description
{
	return [NSString stringWithFormat:@"%@  %@    %@    type=%lu", [super description], _name, _encoding, _type];
}

-(void) setEncoding:(NSString*)encoding
{
	_encoding = encoding;
	[self updateTypeFromEncoding];
}

-(void) updateTypeFromEncoding
{
	_type = KKIvarTypeUnknown;
    
    static NSDictionary *encodingTypeForPrefix = nil;
    encodingTypeForPrefix = @{ @"B": @(KKIvarTypeBOOL),
                               @"c": @(KKIvarTypeChar),
                               @"C": @(KKIvarTypeUnsignedChar),
                               @"i": @(KKIvarTypeInt),
                               @"I": @(KKIvarTypeUnsignedInt),
                               @"f": @(KKIvarTypeFloat),
                               @"{CGPoint=": @(KKIvarTypePoint),
                               @"{CGVector=": @(KKIvarTypeVector),
                               @"{CGSize=": @(KKIvarTypeSize),
                               @"{CGRect=": @(KKIvarTypeRect),
                               @"@\"NSString\"": @(KKIvarTypeString) };
    
    for (NSString *prefix in [encodingTypeForPrefix allKeys]) {
        if ([_encoding hasPrefix:prefix]) {
            _type = [encodingTypeForPrefix[prefix] unsignedIntegerValue];
            break;
        }
    }
	
	/*
	if (_type == KKIvarTypeUnknown)
	{
		NSLog(@"KKIvarInfo: ivar '%@' has unsupported encoding '%@'", _name, _encoding);
	}
	 */
}

-(void) setIvarInTarget:(id)target value:(id)value
{
	NSAssert1([value isKindOfClass:kMutableNumberClass] || [value isKindOfClass:kStringClass],
			  @"can't set ivar, value must be a KKMutableNumber or a NSString, but it's a %@", NSStringFromClass([value class]));

	void* targetPointer = (uint8_t*)(__bridge void*)target;
	void* ivarPointer = targetPointer + ivar_getOffset(_ivar); // pointer to ivar location in target

	if ([value isKindOfClass:kMutableNumberClass])
	{
		switch (_type)
		{
			case KKIvarTypeBOOL:
				*((char*)ivarPointer) = [(KKMutableNumber*)value boolValue];
				break;
				
			case KKIvarTypeChar:
				*((char*)ivarPointer) = [(KKMutableNumber*)value charValue];
				break;

			case KKIvarTypeUnsignedChar:
				*((unsigned char*)ivarPointer) = [(KKMutableNumber*)value unsignedCharValue];
				break;

			case KKIvarTypeInt:
				*((int*)ivarPointer) = [(KKMutableNumber*)value intValue];
				break;

			case KKIvarTypeUnsignedInt:
				*((unsigned int*)ivarPointer) = [(KKMutableNumber*)value unsignedIntValue];
				break;

			case KKIvarTypeDouble:
				*((double*)ivarPointer) = [(KKMutableNumber*)value doubleValue];
				break;

			case KKIvarTypeFloat:
				*((float*)ivarPointer) = [(KKMutableNumber*)value floatValue];
				break;

			default:
				[NSException raise:@"can't set ivar"
				            format:@"failed to set ivar %@ to number value %@ in target %@ - reason: ivar's type isn't handled in the switch", self, value, target];
		}
	}
	else if ([value isKindOfClass:kStringClass])
	{
		NSString* stringValue = value;

		// IMPORTANT:
		// Struct values need to be assigned as copies to the ivar, because the local var created here will be garbage
		// after the method returns. This is what the extra CG..Make() calls are for. Don't "optimize" by removing them!
		switch (_type)
		{
			case KKIvarTypePoint:
			{
				CGPoint point = pointFromString(stringValue);
				*((CGPoint*)ivarPointer) = CGPointMake(point.x, point.y);
				break;
			}

			case KKIvarTypeVector:
			{
				CGVector vector = vectorFromString(stringValue);
				*((CGVector*)ivarPointer) = CGVectorMake(vector.dx, vector.dy);
				break;
			}

			case KKIvarTypeSize:
			{
				CGSize size = sizeFromString(stringValue);
				*((CGSize*)ivarPointer) = CGSizeMake(size.width, size.height);
				break;
			}

			case KKIvarTypeRect:
			{
				CGRect rect = rectFromString(stringValue);
				*((CGRect*)ivarPointer) = CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
				break;
			}

			case KKIvarTypeString:
				object_setIvar(target, _ivar, [stringValue copy]);
				break;

			default:
				[NSException raise:@"can't set ivar"
				            format:@"failed to set ivar %@ to string value %@ in target %@ - reason: ivar's type isn't handled in the switch. Possibly a float number with comma as decimal separator?", self, value, target];
		}
	}
}

@end

@implementation KKClassVarSetter

-(id) initWithClass:(Class)klass
{
	self = [super init];
	if (self)
	{
		_class = klass;
		[self createIvarList];
	}

	return self;
}

-(void) dealloc
{
	free(_ivars);
}

-(void) createIvarList
{
	unsigned int ivarCount = 0;
	if (_ivars == nil)
	{
		_ivars = class_copyIvarList(_class, &ivarCount);
		_ivarInfos = [NSMutableArray arrayWithCapacity:ivarCount];
	}

	for (unsigned int i = 0; i < ivarCount; i++)
	{
		Ivar ivar = _ivars[i];
		NSString* encoding = [NSString stringWithCString:ivar_getTypeEncoding(ivar) encoding:NSASCIIStringEncoding];

		// ignore all object types except for NSString
		if ([encoding hasPrefix:@"@"] && [encoding hasPrefix:@"@\"NSString\""] == NO)
		{
			continue;
		}

		KKIvarInfo* ivarInfo = [KKIvarInfo new];
		ivarInfo.ivar = ivar;
		ivarInfo.name = [NSString stringWithCString:ivar_getName(ivar) encoding:NSASCIIStringEncoding];
		ivarInfo.encoding = encoding;
		[_ivarInfos addObject:ivarInfo];
	}

	// LOG_EXPR(_ivarInfos);
}

-(KKIvarInfo*) ivarInfoForName:(NSString*)name
{
	KKIvarInfo* foundIvarInfo = nil;

	for (KKIvarInfo* ivarInfo in _ivarInfos)
	{
		if ([ivarInfo.name isEqualToString:name])
		{
			foundIvarInfo = ivarInfo;
			break;
		}
	}

	return foundIvarInfo;
}

-(id) convertedObject:(id)obj forKey:(id)key
{
	if ([obj isKindOfClass:[NSDictionary class]])
	{
		NSDictionary* dict = (NSDictionary*)obj;
		NSAssert1(dict.count == 1, @"can't convert dictionary (%@) with multiple values", dict);
		for (NSString* dictKey in dict)
		{
			if ([dictKey isEqualToString:@"color"])
			{
				return [(NSString*)[dict objectForKey:dictKey] color];
			}
		}
	}
	else if ([obj isKindOfClass:[NSString class]] && [[key lowercaseString] containsString:@"color"])
	{
		return [(NSString*)obj color];
	}
	return obj;
}

-(void) setIvarsWithDictionary:(NSDictionary*)ivarsDictionary target:(id)target
{
	[self setIvarsWithDictionary:ivarsDictionary mapping:nil target:target];
}

-(void) setIvarsWithDictionary:(NSDictionary*)ivarsDictionary mapping:(NSDictionary *)mapping target:(id)target
{
	NSAssert2([target isKindOfClass:_class], @"class mismatch! target class %@ != expected class %@", NSStringFromClass([target class]), NSStringFromClass(_class));

	[ivarsDictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL* stop)
	{
		NSAssert1([key isKindOfClass:[NSString class]], @"dictionary key must be a NSString, but it's a %@", NSStringFromClass([key class]));

		if (mapping)
		{
			NSString* mappedKey = [mapping objectForKey:key];
			if (mappedKey)
			{
				key = mappedKey;
			}
		}
		
		if ([key hasPrefix:@"_"])
		{
			KKIvarInfo* ivarInfo = [self ivarInfoForName:key];
			if (ivarInfo)
			{
				obj = [self convertedObject:obj forKey:key];

				//NSLog(@"var: %@ = %@", name, obj);
				[ivarInfo setIvarInTarget:target value:obj];
			}
		}
	}];
}

-(void) setPropertiesWithDictionary:(NSDictionary *)propertiesDictionary target:(id)target
{
	[self setPropertiesWithDictionary:propertiesDictionary mapping:nil target:target];
}

-(void) setPropertiesWithDictionary:(NSDictionary*)propertiesDictionary mapping:(NSDictionary *)mapping target:(id)target
{
	NSAssert2([target isKindOfClass:_class], @"class mismatch! target class %@ != expected class %@", NSStringFromClass([target class]), NSStringFromClass(_class));
	
	[propertiesDictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL* stop)
	{
		NSAssert1([key isKindOfClass:[NSString class]], @"dictionary key must be a NSString, but it's a %@", NSStringFromClass([key class]));

		if (mapping)
		{
			NSString* mappedKey = [mapping objectForKey:key];
			if (mappedKey)
			{
				key = mappedKey;
			}
		}
		
		if (((NSString*)key).length && [key hasPrefix:@"_"] == NO)
		{
			obj = [self convertedObject:obj forKey:key];
			
			//NSLog(@"set property '%@' value '%@'", key, obj);
			[target setValue:obj forKeyPath:key];
		}
	}];
}

@end
