//
//  KKXcodeProject.h
//  KKNewProject
//
//  Created by Steffen Itterheim on 27.08.13.
//  Copyright (c) 2013 Steffen Itterheim. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KKXcodeProject : NSObject

@property (readonly) NSString* path;
@property (readonly) NSString* directory;
@property (readonly) NSString* projectName;
@property (readonly) NSString* name;
@property (readonly) NSString* description;

+(KKXcodeProjectsTableViewDataSource*) xcodeProjectsAtPath:(NSString*)path;

+(id) xcodeProjectWithPath:(NSString*)projectPath;

-(NSString*) projectPathWithDirectory:(NSString*)directory projectName:(NSString*)projectName;
-(BOOL) copyToDirectory:(NSString*)directory name:(NSString*)name error:(NSError**)error;

@end
