/*
 * Copyright (c) 2013 Steffen Itterheim.
 * Released under the MIT License:
 * KoboldAid/licenses/KoboldKitFree.License.txt
 */

#import <Foundation/Foundation.h>


/** NSString category methods */
@interface NSString (KoboldKit)

/** Replaces occurances of string in a text file. Does nothing if file does not exist. File is written atomically.
 @param search The string to search for.
 @param replace The string to replace occurances of 'search' with.
 @param file The file (with optional path) in which to replace strings.
 @param encoding The NSStringEncoding used by the file.
 @returns Returns the file contents with search string occurances replaced, or nil if there was an error in input or reading the file.
 */
+(NSString*) replaceOccurancesOfString:(NSString*)search withString:(NSString*)replace inFile:(NSString*)file encoding:(NSStringEncoding)encoding;

/** Removes all characters not in the ASCII character set (decimal range 32-126).
 @returns The string with all non-ASCII characters removed. */
-(NSString*) stringByDeletingNonAsciiCharacters;
/** Removes illegal filesystem characters from the string.
 @returns The string with all illegal file system characters removed. */
-(NSString*) stringByDeletingIllegalFileSystemCharacters; //  The illegal characters are: /\?%*|"<>:
/** Removes whitespace and newline characters from the beginning and end of the string.
 @returns The string with whitespace and newline characters trimmed. */
-(NSString*) stringByTrimmingWhiteSpaceCharacters;
/** Removes characters from the string that are illegal to use in .xcodeproj bundle and related files.
 @returns The string with all illegal .xcodeproj characters removed. */
-(NSString*) stringByDeletingIllegalXcodeCharacters; // The illegal characters are all illegal file system characters plus: !+~&'(),=@[]^`{}#

/** @returns A CGRect converted from a string rect representation like "{{10, 20}, {300, 400}}". */
-(CGRect) rectValue;
/** @returns A CGSize converted from a string size representation like "{10, 20}". */
-(CGSize) sizeValue;
/** @returns A CGPoint converted from a string point representation like "{300, 400}". */
-(CGPoint) pointValue;

/** @returns String converted to SKColor object. The string must be in the form "1.0 1.0 1.0 1.0" where the
 values stand for the RGBA color values in the same order. */
-(SKColor*) color;

/** Performs a case sensitive search for a substring. Returns YES if the string contains the substring.
 @param subString The sub string to search for.
 @returns YES if the subString is contained in the string. */
-(BOOL) containsString:(NSString*)subString;

@end


/** Converts a string to a CGPoint. Same as CGPointFromString/NSPointFromString but works on both platforms. */
static inline CGPoint pointFromString(NSString* pointString)
{
#if TARGET_OS_IPHONE
	return CGPointFromString(pointString);
#else
	return NSPointFromString(pointString);
#endif
}

/** Converts a string to a CGVector. Same as CGVectorFromString/NSVectorFromString but works on both platforms. */
static inline CGVector vectorFromString(NSString* vectorString)
{
	CGPoint point;
#if TARGET_OS_IPHONE
	point = CGPointFromString(vectorString);
#else
	point = NSPointFromString(vectorString);
#endif
	return CGVectorMake(point.x, point.y);
}

/** Converts a string to a CGSize. Same as CGSizeFromString/NSSizeFromString but works on both platforms. */
static inline CGSize sizeFromString(NSString* pointString)
{
#if TARGET_OS_IPHONE
	return CGSizeFromString(pointString);
#else
	return NSSizeFromString(pointString);
#endif
}

/** Converts a string to a CGRect. Same as CGRectFromString/NSRectFromString but works on both platforms. */
static inline CGRect rectFromString(NSString* pointString)
{
#if TARGET_OS_IPHONE
	return CGRectFromString(pointString);
#else
	return NSRectFromString(pointString);
#endif
}
