//
// Categories.m
// IMLocation
//
// Created by Vincent Gable on 5/28/07.
// Copyright 2007 Vincent Gable. All rights reserved.
//

#import "Categories.h"
#import "VTPG_Common.h"

@implementation NSString  (UUID)
+(NSString*) stringWithUUID
{
	CFUUIDRef uuidObj = CFUUIDCreate(nil);
	NSString* UUIDstring = (NSString*)CFUUIDCreateString(nil, uuidObj);
	CFRelease(uuidObj);
	return [UUIDstring autorelease];
}

@end

@implementation NSString  (RangeAvoidance)
-(BOOL) hasSubstring:(NSString*)substring;
{
	if (IsEmpty(substring))
	{
		return NO;
	}
	NSRange substringRange = [self rangeOfString:substring];
	return substringRange.location != NSNotFound && substringRange.length > 0;
}

-(NSString*) substringAfterSubstring:(NSString*)substring;
{
	if ([self hasSubstring:substring])
	{
		return [self substringFromIndex:NSMaxRange([self rangeOfString:substring])];
	}
	return nil;
}

// Note: -isCaseInsensitiveLike should work when avalible!
-(BOOL) isEqualToStringIgnoringCase:(NSString*)otherString;
{
	if (!otherString)
	{
		return NO;
	}
	return NSOrderedSame == [self compare:otherString options:NSCaseInsensitiveSearch + NSWidthInsensitiveSearch];
}
@end

@implementation NSObject (VTPGExtensions)
+(id) make;
{
	return [[[[self class] alloc] init] autorelease];
}

@end


@implementation NSString (IndempotentPercentEscapes)
-(NSString*) stringByReplacingPercentEscapesOnce;
{
	NSString* unescaped = [self stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	// self may be a string that looks like an invalidly escaped string,
	// eg @"100%", in that case it clearly wasn't escaped,
	// so we return it as our unescaped string.
	return unescaped ? unescaped : self;
}
-(NSString*) stringByAddingPercentEscapesOnce;
{
	return [[self stringByReplacingPercentEscapesOnce] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}
@end

@implementation NSURL (IsEqualTesting)
// http://vgable.com/blog/2009/04/22/nsurl-isequal-gotcha/
-(BOOL) isEqualToURL:(NSURL*)otherURL;
{
	return [[self absoluteURL] isEqual:[otherURL absoluteURL]] ||
		   ([self isFileURL] && [otherURL isFileURL] && [[self path] isEqual:[otherURL path]]);
}
@end

@implementation NSBundle (VTPGExtensions)
-(NSString*) bundleVersion;
{
	return [self objectForInfoDictionaryKey:@"CFBundleVersion"];
}

-(NSURL*) URLForResource:(NSString*)name ofType:(NSString*)ext;
{
	NSString* path = [self pathForResource:name ofType:ext];
	if (!path)
	{
		return nil; // fileURLWithPath: will throw an exception if path is nil.
	}
	return [NSURL fileURLWithPath:path];
}

@end

@implementation NSDate (VTPGDateComparison)

-(BOOL) isBefore:(NSDate*)otherDate;
{
	return [self timeIntervalSinceDate:otherDate] < 0;
}

-(BOOL) isAfter:(NSDate*)otherDate;
{
	return [self timeIntervalSinceDate:otherDate] > 0;
}
@end

@implementation NSFileManager (VTPGExtensions)

-(NSDate*) modificationDateOfItemAtURL:(NSURL*)fileURL
{
	return [[self attributesOfItemAtPath:[fileURL path] error:nil] fileModificationDate];
}

@end

@implementation NSMutableArray (ArrayQueue)
-(id) takeObject
{
	id object = nil;
	if ([self count])
	{
		object = [self objectAtIndex:0];
		[[object retain] autorelease];
		[self removeObjectAtIndex:0];
	}
	return object;
}

@end

@implementation NSMutableArray (ArrayStack)
-(id) pop;
{
	id obj = nil;
	if ([self count])
	{
		obj = [self lastObject];
		[[obj retain] autorelease];
		[self removeLastObject];
	}
	return obj;
}
@end

#pragma mark HigherOrderOperations
@implementation NSObject (HigherOrderOperations)
// returns self
-(id) performSelector:(SEL)oneArgumentSelector withEachItemOf:(id)container;
{
	for (id obj in container)
	{
		[self performSelector:oneArgumentSelector withObject:obj];
	}
	return self;
}

-(NSMutableArray*) mutableNonNilResultsOfPerformingSelector:(SEL)oneArgumentSelector withEachItemOf:(id)container;
{
	NSMutableArray* results = [NSMutableArray array];
	for (id obj in container)
	{
		id aResult = [self performSelector:oneArgumentSelector withObject:obj];
		if (aResult)
		{
			[results addObject:aResult];
		}
	}
	return results;
}


-(NSArray*) nonNilResultsOfPerformingSelector:(SEL)oneArgumentSelector withEachItemOf:(id)container
{
	return [self mutableNonNilResultsOfPerformingSelector:oneArgumentSelector withEachItemOf:container];
}

@end



@implementation NSArray (HigherOrderOperations)

// foldl op r [a, b, c] => ((r `op` a) `op` b) `op` c
-(id) foldlWithSelector:(SEL)sel initialObject:(id)firstObject
{
	id target = firstObject;
	for (id obj in self)
	{
		target = [target performSelector:sel withObject:obj];
	}
	return target;
}

-(NSMutableArray*) mutableResultsOfApplyingSelector:(SEL)sel withObject:arg;
{
	NSMutableArray* results = [NSMutableArray arrayWithCapacity:[self count]];
	for (id object in self)
	{
		id result = [object performSelector:sel withObject:arg];
		[results addObject:result];
	}
	return results;
}

-(NSMutableArray*) mutableNonNilResultsOfApplyingSelector:(SEL)sel withObject:arg;
{
	NSMutableArray* results = [NSMutableArray arrayWithCapacity:[self count]];
	for (id object in self)
	{
		id result = [object performSelector:sel withObject:arg];
		if (result)
		{
			[results addObject:result];
		}
	}
	return results;
}

-(NSMutableArray*) mutableNonNilResultsOfApplyingSelector:(SEL)sel;
{
	return [self mutableNonNilResultsOfApplyingSelector:sel withObject:nil];
}

-(NSArray*) resultsOfApplyingSelector:(SEL)sel withObject:arg;
{
	return [self mutableResultsOfApplyingSelector:sel withObject:arg];
}

-(NSArray*) resultsOfApplyingSelector:(SEL)sel;
{
	return [self resultsOfApplyingSelector:sel withObject:nil];
}

@end

@implementation NSDictionary (HigherOrderOperations)

-(NSMutableDictionary*) mutableResultsOfApplyingSelector:(SEL)sel withObject:arg
{
	NSMutableDictionary* results = [NSMutableDictionary dictionaryWithCapacity:[self count]];

	for (id key in [self allKeys])
	{
		id result = [[self objectForKey:key] performSelector:sel withObject:arg];
		if (result)
		{
			[results setObject:result forKey:key];
		}
	}

	return results;
}

-(NSDictionary*) resultsOfApplyingSelector:(SEL)sel withObject:arg
{
	return [NSDictionary dictionaryWithDictionary:[self mutableResultsOfApplyingSelector:sel withObject:arg]];
}
@end
