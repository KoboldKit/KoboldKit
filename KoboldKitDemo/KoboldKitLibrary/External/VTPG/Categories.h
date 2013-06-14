//
// Categories.h
// IMLocation
//
// Created by Vincent Gable on 5/28/07.
// Copyright 2007 Vincent Gable. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark UUID
@interface NSString (UUID)
// returns a new string built from a new UUID.
+(NSString*) stringWithUUID;
@end

@interface NSString  (RangeAvoidance)
-(BOOL) hasSubstring:(NSString*)substring;
-(NSString*) substringAfterSubstring:(NSString*)substring;

// Note: -isCaseInsensitiveLike is probably a better alternitive if it's avalible.
-(BOOL) isEqualToStringIgnoringCase:(NSString*)otherString;
@end

#pragma mark Misc
@interface NSObject (VTPGExtensions)
+(id) make;
@end
@interface NSString (IndempotentPercentEscapes)
// uses UTF8 encoding, behavior is undefined if for other encodings.
-(NSString*) stringByAddingPercentEscapesOnce;
-(NSString*) stringByReplacingPercentEscapesOnce;
@end

@interface NSMutableArray (ArrayQueue)
-(id) takeObject;
@end
@interface NSMutableArray (ArrayStack)
-(id) pop;
@end

@interface NSURL (IsEqualTesting)
-(BOOL) isEqualToURL:(NSURL*)otherURL;
@end

@interface NSBundle (VTPGExtensions)
-(NSString*) bundleVersion;
-(NSURL*) URLForResource:(NSString*)name ofType:(NSString*)ext;
@end

#pragma mark HigherOrderOperations
@interface NSObject (HigherOrderOperations)

// implements the visitor pattern
// returns self, so it can be chained
-(id) performSelector:(SEL)oneArgumentSelector withEachItemOf:(id)container;

// analogus to map
-(NSArray*) nonNilResultsOfPerformingSelector:(SEL)oneArgumentSelector withEachItemOf:(id)container;
-(NSMutableArray*) mutableNonNilResultsOfPerformingSelector:(SEL)oneArgumentSelector withEachItemOf:(id)container;

@end
@interface NSArray (HigherOrderOperations)
-(NSMutableArray*) mutableNonNilResultsOfApplyingSelector:(SEL)sel;
-(NSMutableArray*) mutableNonNilResultsOfApplyingSelector:(SEL)sel withObject:arg;

-(NSMutableArray*) mutableResultsOfApplyingSelector:(SEL)sel withObject:arg;
-(NSArray*) resultsOfApplyingSelector:(SEL)sel withObject:arg;
-(NSArray*) resultsOfApplyingSelector:(SEL)sel;
@end

@interface NSDictionary (HigherOrderOperations)
-(NSMutableDictionary*) mutableResultsOfApplyingSelector:(SEL)sel withObject:arg;
-(NSDictionary*) resultsOfApplyingSelector:(SEL)sel withObject:arg;
@end

#pragma mark NSFileManager Extensions
@interface NSFileManager (VTPGExtensions)
-(NSDate*) modificationDateOfItemAtURL:(NSURL*)fileURL;
@end

@interface NSDate (VTPGDateComparison)
-(BOOL) isBefore:(NSDate*)otherDate;
-(BOOL) isAfter:(NSDate*)otherDate;
@end
