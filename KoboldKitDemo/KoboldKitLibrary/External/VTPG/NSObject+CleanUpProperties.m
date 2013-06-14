//
// NSObject+CleanUpProperties.m
//
// Created by Vincent Gable on 12/4/08.
// vincent.gable@gmail.com
// http://vincentgable.com
// Copyright 2008 Vincent Gable.
// You are free to use this code however you like.
// But I would appreciate hearing what you use it for :-)
//

#import "NSObject+CleanUpProperties.h"


@implementation NSObject (CleanUpProperties)

// syntax is:
// ,S(methodNameHere):,
// for example:
// ,SintSetFoo:,
// This would be even easier with regex.
// for more information on attribute strings see:
// http://developer.apple.com/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/chapter_8_section_4.html#//apple_ref/doc/uid/TP40008048-CH101-SW5
static NSString * SetterNameFromAttributes(const char* propertyAttrsCString)
{
	NSString* propertyAttributes = [NSString stringWithUTF8String:propertyAttrsCString];
	for (NSString* property in [propertyAttributes componentsSeparatedByString : @","])
	{
		if ([property hasPrefix:@"S"] && [property hasSuffix:@":"])
		{
			return [property substringFromIndex:1];
		}
	}

	return nil;
}

static NSString* SetterNameFromPropertyName(const char* propertyNameCStr)
{
	NSString* propertyName = [NSString stringWithUTF8String:propertyNameCStr];
	NSString* firstLetterCapitalized = [[propertyName substringToIndex:1] capitalizedString];
	NSString* propertyNameTail = [propertyName substringFromIndex:1];
	return [NSString stringWithFormat:@"set%@%@:", firstLetterCapitalized, propertyNameTail];
}

// for more information on attribute strings see:
// http://developer.apple.com/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/chapter_8_section_4.html#//apple_ref/doc/uid/TP40008048-CH101-SW5
static BOOL PropertyIsObjCObject(const char* propertyAttributeString)
{
	return propertyAttributeString &&
		   propertyAttributeString[0] == 'T' &&
		   propertyAttributeString[1] == '@'; // all other pointers have a '^' here
}

// Readonly properties have
// ",R,"
// in their attribute strings
// for more information on attribute strings see:
// http://developer.apple.com/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/chapter_8_section_4.html#//apple_ref/doc/uid/TP40008048-CH101-SW5
static BOOL PropertyIsSettable(const char* propertyAttributeString)
{
	return NULL == strstr(propertyAttributeString, ",R,");
}

-(void) setEveryObjCObjectPropertyToNil;
{
	unsigned int i, propertyCount = 0;
	objc_property_t* propertyList = class_copyPropertyList([self class], &propertyCount);
	if (propertyList)
	{
		for (i = 0; i < propertyCount; i++)
		{
			const char* propertyAttrs =  property_getAttributes(propertyList[i]);
			if (PropertyIsObjCObject(propertyAttrs) && PropertyIsSettable(propertyAttrs))
			{
				NSString* setterName = SetterNameFromAttributes(propertyAttrs);
				if (!setterName)
				{
					setterName = SetterNameFromPropertyName(property_getName(propertyList[i]));
				}
				[self performSelector:NSSelectorFromString(setterName) withObject:nil];
			}
		}
		free(propertyList);
	}
}

@end
