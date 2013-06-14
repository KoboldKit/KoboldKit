//
// NilCategories.h
//
// Created by Vincent Gable on 2009-04-21
// Copyright 2009 Vincent Gable. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark UUID
@interface NSString (NilCategories)
-(NSURL*) convertToURL;
-(NSURL*) convertToURLRelitiveToURL:(NSURL*)baseURL;
@end

@interface NSArray (NilCategories)
-(id) objectOrNilAtIndex:(NSUInteger)index;
@end

@interface NSMutableDictionary (NilCategories)
-(void) setObjectToObjectForKey:(id)key inDictionary:(NSDictionary*)otherDictionary;
@end;
