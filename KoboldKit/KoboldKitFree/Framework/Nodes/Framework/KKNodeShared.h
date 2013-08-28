/*
 * Copyright (c) 2013 Steffen Itterheim.
 * Released under the MIT License:
 * KoboldAid/licenses/KoboldKitFree.License.txt
 */


#import "KKFramework.h"

/** Since Kobold Kit can't modify SKNode certain functionality must be implemented in each KK*Node subclass.
 To avoid copy/pasting the code all over the place, this class acts like a common parent class, like a multiple inheritance stand-in.
 
 Functionality that would normally be handled by a method in SKNode (say a custom dealloc) must be implemented by each KK*Node
 subclass and the actual functionality is in a class method in this class. */
@interface KKNodeShared : NSObject
+(void) deallocWithNode:(SKNode*)node;
+(void) sendChildrenWillMoveFromParentWithNode:(SKNode*)node;
+(void) didMoveToParentWithNode:(SKNode*)node;
+(void) willMoveFromParentWithNode:(SKNode*)node;
@end

#define KKNODE_SHARED_CODE \
-(void) dealloc { \
	[KKNodeShared deallocWithNode:self]; \
} \
-(void) addChild:(SKNode*)node { \
	[super addChild:node]; \
	[KKNodeShared didMoveToParentWithNode:node]; \
} \
-(void) insertChild:(SKNode*)node atIndex:(NSInteger)index { \
	[super insertChild:node atIndex:index]; \
	[KKNodeShared didMoveToParentWithNode:node]; \
} \
-(void) removeFromParent { \
	[KKNodeShared willMoveFromParentWithNode:self]; \
	[super removeFromParent]; \
} \
-(void) removeAllChildren { \
	[KKNodeShared sendChildrenWillMoveFromParentWithNode:self]; \
	[super removeAllChildren]; \
} \
-(void) removeChildrenInArray:(NSArray*)array { \
	[KKNodeShared sendChildrenWillMoveFromParentWithNode:self]; \
	[super removeChildrenInArray:array]; \
} \
