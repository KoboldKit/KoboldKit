/*
 * Copyright (c) 2013 Steffen Itterheim.
 * Released under the MIT License:
 * KoboldAid/licenses/KoboldKitFree.License.txt
 */

#import "RemoveSpaceshipBehavior.h"

@implementation RemoveSpaceshipBehavior

-(void) didJoinController
{
	[self.node.kkScene addSceneEventsObserver:self];
}

-(void) didLeaveController
{
	[self.node.kkScene removeSceneEventsObserver:self];
}

-(void) update:(CFTimeInterval)currentTime
{
	if (self.node.position.y < _removeHeight)
	{
		[self.node removeFromParent];
	}
}

@end
