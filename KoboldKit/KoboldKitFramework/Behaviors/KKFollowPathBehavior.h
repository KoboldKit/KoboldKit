//
//  KKFollowPathBehavior.h
//  KoboldKit
//
//  Created by Steffen Itterheim on 04.08.13.
//  Copyright (c) 2013 Steffen Itterheim. All rights reserved.
//

#import "KKBehavior.h"

@interface KKFollowPathBehavior : KKBehavior

@property (atomic, copy) NSString* pathName;
@property (atomic) CGFloat moveSpeed;
@property (atomic) CGFloat initialWaitDuration;
@property (atomic) NSUInteger repeatCount;
@property (atomic) BOOL relativeToObject;
@property (atomic) BOOL orientToPath;

@end
