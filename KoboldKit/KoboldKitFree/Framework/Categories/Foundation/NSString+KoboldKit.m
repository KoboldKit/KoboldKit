/*
 * Copyright (c) 2013 Steffen Itterheim.
 * Released under the MIT License:
 * KoboldAid/licenses/KoboldKitFree.License.txt
 */

#import "NSString+KoboldKit.h"

@implementation NSString (KoboldKit)

+(NSString*) replaceOccurancesOfString:(NSString*)search
							withString:(NSString*)replace
								inFile:(NSString*)file
							  encoding:(NSStringEncoding)encoding
{
	if (search.length == 0 || replace == nil || file.length == 0)
	{
		NSLog(@"WARNING: replaceOccurancesOfString preconditions not met: search='%@', replace='%@', file='%@'",
			  search, replace, file);
		return nil;
	}
	
	NSFileManager* fileManager = [NSFileManager defaultManager];
	BOOL isDirectory;
	if ([fileManager fileExistsAtPath:file isDirectory:&isDirectory] == NO || isDirectory == YES)
	{
		return nil;
	}
	
	NSError* error;
	NSString* sourceString = [NSString stringWithContentsOfFile:file encoding:encoding error:&error];
	if (error)
	{
		NSLog(@"ERROR: replaceOccurancesOfString reading file %@ - error: %@", file, error);
		return nil;
	}

	NSString* replacedString = sourceString;
	if (sourceString.length)
	{
		replacedString = [sourceString stringByReplacingOccurrencesOfString:search withString:replace];
		[replacedString writeToFile:file atomically:YES encoding:encoding error:&error];
		if (error)
		{
			NSLog(@"ERROR: replaceOccurancesOfString writing file %@ - error: %@", file, error);
			return nil;
		}
	}
	
	return replacedString;
}

static NSCharacterSet* KKNonAsciiCharacterSet = nil;

-(NSString*) stringByDeletingNonAsciiCharacters
{
	if (KKNonAsciiCharacterSet == nil)
	{
		NSMutableString* onlyAsciiString = [NSMutableString stringWithCapacity:self.length];
		for (int i = 32; i < 127; i++)
		{
			[onlyAsciiString appendFormat:@"%c", i];
		}
		KKNonAsciiCharacterSet = [[NSCharacterSet characterSetWithCharactersInString:onlyAsciiString] invertedSet];
	}
	
	return [[self componentsSeparatedByCharactersInSet:KKNonAsciiCharacterSet] componentsJoinedByString:@""];
}

-(NSString*) stringByTrimmingWhiteSpaceCharacters
{
	return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

-(NSString*) stringByDeletingIllegalFileSystemCharacters
{
	NSCharacterSet* illegalFileNameCharacters = [NSCharacterSet characterSetWithCharactersInString:@"/\\%?*|\"<>:"];
	return [[self componentsSeparatedByCharactersInSet:illegalFileNameCharacters] componentsJoinedByString:@""];
}

-(NSString*) stringByDeletingIllegalXcodeCharacters
{
	NSString* newString;
	newString = [self stringByDeletingNonAsciiCharacters];
	newString = [newString stringByDeletingIllegalFileSystemCharacters];

	NSCharacterSet* illegalXcodeCharacters = [NSCharacterSet characterSetWithCharactersInString:@"!+~&'(),=@[]^`{}"];
	newString = [[newString componentsSeparatedByCharactersInSet:illegalXcodeCharacters] componentsJoinedByString:@""];

	newString = [newString stringByTrimmingWhiteSpaceCharacters];
	return newString;
}

-(BOOL) containsString:(NSString*)subString
{
	return ([self rangeOfString:subString].location != NSNotFound);
}

-(CGRect) rectValue
{
#if TARGET_OS_IPHONE
	CGRect rect = CGRectFromString(self);
	return rect;
#else
	NSRect rect = NSRectFromString(self);
	return CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
#endif
}

-(CGSize) sizeValue
{
#if TARGET_OS_IPHONE
	CGSize size = CGSizeFromString(self);
	return size;
#else
	NSSize size = NSSizeFromString(self);
	return CGSizeMake(size.width, size.height);
#endif
}

-(CGPoint) pointValue
{
#if TARGET_OS_IPHONE
	CGPoint point = CGPointFromString(self);
	return point;
#else
	NSPoint point = NSPointFromString(self);
	return CGPointMake(point.x, point.y);
#endif
}

-(SKColor*) color
{
	CIColor* ciColor = [CIColor colorWithString:self];
	SKColor* skColor = [SKColor colorWithCIColor:ciColor];
	return skColor;
}

@end
