//
//  SKScene+KoboldKit.h
//  KoboldKit
//
//  Created by Steffen Itterheim on 26.06.13.
//  Copyright (c) 2013 Steffen Itterheim. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface SKScene (KoboldKit)

-(void) enumerateBodiesUsingBlock:(void (^)(SKPhysicsBody *body, BOOL *stop))block;

@end
