//
// KKIvarSetter.m
// KoboldTouch-Libraries
//
// Created by Steffen Itterheim on 02.03.13.
//
//

#import "KKIvarSetter.h"
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
	return [NSString stringWithFormat:@"%@  %@    %@    type=%i", [super description], _name, _encoding, _type];
}

-(void) setEncoding:(NSString*)encoding
{
	_encoding = encoding;
	[self updateTypeFromEncoding];
}

-(void) updateTypeFromEncoding
{
	_type = KKIvarTypeUnknown;

	if ([_encoding hasPrefix:@"c"])
	{
		_type = KKIvarTypeChar;
	}
	else if ([_encoding hasPrefix:@"C"])
	{
		_type = KKIvarTypeUnsignedChar;
	}
	else if ([_encoding hasPrefix:@"i"])
	{
		_type = KKIvarTypeInt;
	}
	else if ([_encoding hasPrefix:@"I"])
	{
		_type = KKIvarTypeUnsignedInt;
	}
	else if ([_encoding hasPrefix:@"f"])
	{
		_type = KKIvarTypeFloat;
	}
	else if ([_encoding hasPrefix:@"d"])
	{
		_type = KKIvarTypeDouble;
	}
	else if ([_encoding hasPrefix:@"{CGPoint="])
	{
		_type = KKIvarTypePoint;
	}
	else if ([_encoding hasPrefix:@"{CGSize="])
	{
		_type = KKIvarTypeSize;
	}
	else if ([_encoding hasPrefix:@"{CGRect="])
	{
		_type = KKIvarTypeRect;
	}
	else if ([_encoding hasPrefix:@"@\"NSString\""])
	{
		_type = KKIvarTypeString;
	}
} /* updateTypeFromEncoding */

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
		} /* switch */
	}
	else if ([value isKindOfClass:kStringClass])
	{
		NSString* stringValue = value;

		switch (_type)
		{
			case KKIvarTypePoint:
			{
				CGPoint point = pointFromString(stringValue);
				*((CGPoint*)ivarPointer) = CGPointMake(point.x, point.y);
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
		} /* switch */
	}
}         /* setIvarInTarget */

@end

@implementation KKIvarSetter

-(id) initWithClass:(Class)class
{
	self = [super init];
	if (self)
	{
		_class = class;
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

		KKIvarInfo* ivarInfo = [[KKIvarInfo alloc] init];
		ivarInfo.ivar = ivar;
		ivarInfo.name = [NSString stringWithCString:ivar_getName(ivar) encoding:NSASCIIStringEncoding];
		ivarInfo.encoding = encoding;
		[_ivarInfos addObject:ivarInfo];
	}

	// LOG_EXPR(_ivarInfos);
} /* createIvarList */

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

-(void) setIvarsFromDictionary:(NSDictionary*)ivarsDictionary target:(id)target
{
	NSAssert2([target isKindOfClass:_class], @"class mismatch! target class %@ != expected class %@", NSStringFromClass([target class]), NSStringFromClass(_class));

	[ivarsDictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL* stop)
	{
		NSAssert1([key isKindOfClass:[NSString class]], @"dictionary key must be a NSString, but it's a %@", NSStringFromClass([key class]));
		NSString* name = key;

		KKIvarInfo* ivarInfo = [self ivarInfoForName:name];
		if (ivarInfo)
		{
			//NSLog(@"Tiled var: %@ = %@", name, obj);
			[ivarInfo setIvarInTarget:target value:obj];
		}
	}];
} /* setIvarsFromDictionary */

@end
