/*
 * Copyright (c) 2012-2013 Steffen Itterheim.
 * Released under the MIT License:
 * KoboldAid/licenses/KoboldKitFree.License.txt
 */

#import "KKTilemapProperties.h"
#import "KKMutableNumber.h"

static NSNumberFormatter* __numberFormatter = nil;

@implementation KKTilemapProperties

-(id) init
{
	self = [super init];
	if (self)
	{
		_properties = [NSMutableDictionary dictionaryWithCapacity:1];

		if (__numberFormatter == nil)
		{
			__numberFormatter = [[NSNumberFormatter alloc] init];
			[__numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
			// Why not make it locale-aware? Because it would make TMX maps created by US developers unusable by
			// devs in other countries whose decimal separator is not a dot but a comma.
			[__numberFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
		}
	}

	return self;
} /* init */

-(void) setNumber:(KKMutableNumber*)number forKey:(NSString*)key
{
	[_properties setObject:number forKey:key];
}

-(void) setString:(NSString*)string forKey:(NSString*)key
{
	[_properties setObject:string forKey:key];
}

-(KKMutableNumber*) numberForKey:(NSString*)name
{
	id object = [_properties objectForKey:name];
	NSAssert2(object == nil || [object isKindOfClass:[KKMutableNumber class]],
			  @"requested number for key '%@' was not a KKMutableNumber but a %@",
			  name, NSStringFromClass([object class]));
	return (KKMutableNumber*)object;
}

-(NSString*) stringForKey:(NSString*)name
{
	id object = [_properties objectForKey:name];
	NSAssert2(object == nil || [object isKindOfClass:[NSString class]],
			  @"requested string for key '%@' was not a NSString but a %@",
			  name, NSStringFromClass([object class]));
	return (NSString*)object;
}

-(KKMutableNumber*) numberFromString:(NSString*)string
{
	NSNumber* number = [__numberFormatter numberFromString:string];

	if (number)
	{
		if (number.objCType[0] == 'f' || number.objCType[0] == 'd')
		{
			return [KKMutableNumber numberWithFloat:number.floatValue];
		}
		else
		{
			return [KKMutableNumber numberWithInt:number.intValue];
		}
	}
	else if ([string isEqualToString:@"YES"])
	{
		return [KKMutableNumber numberWithBool:YES];
	}
	else if ([string isEqualToString:@"NO"])
	{
		return [KKMutableNumber numberWithBool:NO];
	}

#if DEBUG
	else
	{
		// do a quick test to see if the user used , instead of . for floating point values
		NSString* testString = [string stringByReplacingOccurrencesOfString:@"," withString:@"."];
		NSNumber* testNumber = [__numberFormatter numberFromString:testString];
		if (testNumber)
		{
			NSLog(@"KTTMXReader WARNING: The string '%@' supposedly represents a number, but used a , as decimal separator. Do not use , (comma) as decimal separator, use . (dot) instead.", string);
		}
	}
#endif /* if DEBUG */

	return nil;
}

-(void) setValue:(NSString*)string forKey:(NSString*)key
{
	KKMutableNumber* number = [self numberFromString:string];
	if (number)
	{
		[self setNumber:number forKey:key];
	}
	else
	{
		[self setString:string forKey:key];
	}
}

@dynamic count;
-(NSUInteger) count
{
	return _properties.count;
}

@end

