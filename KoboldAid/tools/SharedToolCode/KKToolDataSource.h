//
//  KKToolDataSources.h
//  KKNewProject
//
//  Created by Steffen Itterheim on 27.08.13.
//  Copyright (c) 2013 Steffen Itterheim. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KKToolDataSource : NSObject
@property (readonly) NSMutableArray* array;
@property (readonly) NSMutableDictionary* dictionary;

-(void) setObject:(id)object forKey:(NSString*)key;
@end

@interface KKXcodeProjectsTableViewDataSource : KKToolDataSource <NSTableViewDataSource>

@end
