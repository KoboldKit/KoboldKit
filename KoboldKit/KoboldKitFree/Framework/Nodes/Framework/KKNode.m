/*
 * Copyright (c) 2013 Steffen Itterheim.
 * Released under the MIT License:
 * KoboldAid/licenses/KoboldKitFree.License.txt
 */


#import "KKNode.h"
#import "SKNode+KoboldKit.h"
#import "KKNodeController.h"
#import "KKBehavior.h"
#import "KKNodeShared.h"

@implementation KKNode
KKNODE_SHARED_CODE

#pragma mark Description

-(NSString*) description
{
	return [NSString stringWithFormat:@"%@ controller:%@ behaviors:%@", [super description], self.controller, self.controller.behaviors];
}

#pragma mark !! Update methods below whenever class layout changes !!
#pragma mark NSCoding

#pragma mark NSCopying

-(instancetype) copyWithZone:(NSZone*)zone
{
	// call original implementation - if this look wrong to you, read up on Method Swizzling: http://www.cocoadev.com/index.pl?MethodSwizzling)
	KKNode* copy = [super copyWithZone:zone];
	
	// if the node contains controllers make sure their copies reference the copied node
	KKNodeController* controller = copy.controller;
	NSAssert2(controller && self.controller || controller == nil && self.controller == nil, @"controller (%@) of node (%@) was not copied!", self.controller, self);
	if (controller)
	{
		controller.node = copy;
		for (KKBehavior* behavior in controller.behaviors)
		{
			behavior.controller = copy.controller;
			behavior.node = copy;
		}
	}
	
	return copy;
}

@end
