//
//  KKPhysicsShapeNode.h
//  KoboldKit
//
//  Created by Steffen Itterheim on 27.06.13.
//  Copyright (c) 2013 Steffen Itterheim. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

// incomplete, supposed to render physics body shapes, possibly superceded by SKNode+KoboldKit functionality
@interface KKPhysicsDebugNode : SKNode
{
	@private
	NSMutableArray* _contacts;
	SKNode* _contactNode;
}

-(void) addContact:(SKPhysicsContact*)contact;
-(void) removeContact:(SKPhysicsContact*)contact;
-(void) removeAllContacts;

@end
