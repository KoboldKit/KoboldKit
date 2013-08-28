/*
 * Copyright (c) 2012-2013 Steffen Itterheim.
 * Released under the MIT License:
 * KoboldAid/licenses/KoboldKitFree.License.txt
 */

#import "KKIntegerArray.h"

static const NSUInteger kDefaultNumberOfIntegersToAllocate = 4;

@implementation KKIntegerArray

+(id) integerArrayWithCapacity:(NSUInteger)capacity
{
	return [[self alloc] initWithCapacity:capacity];
}

-(id) initWithCapacity:(NSUInteger)capacity
{
	self = [super init];
	if (self)
	{
		_count = 0;
		_numIntegersAllocated = 0;
		[self allocateMemoryForNumberOfIntegers:capacity];
	}
	
	return self;
}

-(id) init
{
	return [self initWithCapacity:kDefaultNumberOfIntegersToAllocate];
}

-(void) dealloc
{
	free(_integers);
}

-(void) allocateMemoryForNumberOfIntegers:(NSUInteger)additionalIntegers
{
	NSUInteger requestedNumberOfIntegers = _count + additionalIntegers;
	if (requestedNumberOfIntegers > _numIntegersAllocated)
	{
		do
		{
			if (_numIntegersAllocated == 0)
			{
				_numIntegersAllocated = requestedNumberOfIntegers;
			}
			else
			{
				_numIntegersAllocated = (float)(_numIntegersAllocated) * 1.5f;
			}
		}
		while (requestedNumberOfIntegers > _numIntegersAllocated);
		
		_integers = realloc(_integers, _numIntegersAllocated * sizeof(NSUInteger));
	}
}

-(void) removeAllIntegers
{
	_count = 0;
	_numIntegersAllocated = 0;
	[self allocateMemoryForNumberOfIntegers:kDefaultNumberOfIntegersToAllocate];
}

-(void) addInteger:(NSUInteger)integer
{
	[self allocateMemoryForNumberOfIntegers:1];
	_integers[_count++] = integer;
}

-(NSUInteger) integerAtIndex:(NSUInteger)index
{
	NSAssert2(index < _count, @"index (%u) out of bounds! (num integers: %u)", (unsigned int)index, (unsigned int)_count);
	return _integers[index];
}

-(NSUInteger) lastInteger
{
	if (_count > 0)
	{
		return _integers[_count - 1];
	}
	return 0;
}

-(NSString*) description
{
	NSMutableString* str = [NSMutableString stringWithFormat:@"%@ {", [super description]];
	for (NSUInteger i = 0; i < _count; i++)
	{
		if (i > 0)
		{
			[str appendString:@","];
		}
		[str appendFormat:@"%lu", (unsigned long)_integers[i]];
	}

	[str appendFormat:@"} (%lu total)", (unsigned long)_count];
	return str;
}

@end
