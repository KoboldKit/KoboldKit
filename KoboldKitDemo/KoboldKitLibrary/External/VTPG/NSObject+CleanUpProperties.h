//
// NSObject+CleanUpProperties.h
//
// Created by Vincent Gable on 12/4/08.
// vincent.gable@gmail.com
// http://vincentgable.com
// Copyright 2008 Vincent Gable.
// You are free to use this code however you like.
// But I would appreciate hearing what you use it for :-)
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

@interface NSObject (CleanUpProperties)
-(void) setEveryObjCObjectPropertyToNil;

#define PROPERTY_ONLY_OBJECT_DEALLOC \
	-(void) dealloc { \
		[self setEveryObjCObjectPropertyToNil]; \
		[super dealloc]; \
	}

@end
