//
//  KKPhysicsShapeNode.h
//  KoboldKit
//
//  Created by Steffen Itterheim on 27.06.13.
//  Copyright (c) 2013 Steffen Itterheim. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

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
