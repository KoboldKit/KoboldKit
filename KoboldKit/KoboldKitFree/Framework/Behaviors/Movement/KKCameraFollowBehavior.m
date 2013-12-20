/*
 * Copyright (c) 2013 Steffen Itterheim.
 * Released under the MIT License:
 * KoboldAid/licenses/KoboldKitFree.License.txt
 */


#import "KKCameraFollowBehavior.h"
#import "SKNode+KoboldKit.h"
#import "KKScene.h"

@implementation KKCameraFollowBehavior

-(void) didJoinController
{
	[self.node.kkScene addSceneEventsObserver:self];

	// defaults to parent's parent (in a tilemap hierarchy this is the tile layer of the object)
	if (_scrollingNode == nil)
	{
		_scrollingNode = self.node.parent.parent;
	}

	// update once immediately
	[self didSimulatePhysics];
}

-(void) didLeaveController
{
	[self.node.kkScene removeSceneEventsObserver:self];
}

-(void) didSimulatePhysics
{
	if (_scrollingNode)
	{
		SKNode* node = self.node;
		CGPoint cameraPositionInScene = [node.scene convertPoint:node.position fromNode:_scrollingNode];
		CGPoint pos = CGPointMake(_scrollingNode.position.x - cameraPositionInScene.x,
								  _scrollingNode.position.y - cameraPositionInScene.y);
		_scrollingNode.position = pos;
	}
}

#pragma mark !! Update methods below whenever class layout changes !!
#pragma mark NSCoding

static NSString* const ArchiveKeyForScrollingNode = @"scrollingNode";

-(id) initWithCoder:(NSCoder*)decoder
{
	self = [super init];
	if (self)
	{
        _scrollingNode = [decoder decodeObjectForKey:ArchiveKeyForScrollingNode];
	}
	return self;
}

-(void) encodeWithCoder:(NSCoder*)encoder
{
    [encoder encodeObject:_scrollingNode forKey:ArchiveKeyForScrollingNode];
}

#pragma mark NSCopying

-(id) copyWithZone:(NSZone*)zone
{
	KKCameraFollowBehavior* copy = [[super copyWithZone:zone] init];
	copy->_scrollingNode = _scrollingNode;
	return copy;
}

#pragma mark Equality
-(BOOL) isEqualToBehavior:(KKBehavior*)behavior
{
	if ([self isMemberOfClass:[behavior class]] == NO)
		return NO;
    
    KKCameraFollowBehavior *followBehavior = (KKCameraFollowBehavior *)behavior;
    if ([followBehavior.scrollingNode isEqualToNode:_scrollingNode])
        return YES;
    
	return NO;
}

@end
