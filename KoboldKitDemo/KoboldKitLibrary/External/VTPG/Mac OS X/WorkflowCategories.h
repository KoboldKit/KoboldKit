//
// WorkflowCategories.h
// IMLocation
//
// Created by Vincent Gable on 12/5/08.
// Copyright 2008 Vincent Gable. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Automator/Automator.h>

@interface AMWorkflow (VTPGExtras)
// TODO: Rename, this forces a URL to exist there.
+(AMWorkflow*) workflowFromURL:(NSURL*)workflowURL error:(NSError**)outError;

+(AMWorkflow*) workflowAtURL:(NSURL*)url error:(NSError**)outError;
+(AMWorkflow*) workflowAtURL:(NSURL*)url;

+(AMWorkflow*) loadOrCreateWorkflowAt:(NSURL*)workflowURL;

-(void) addEveryActionToFile:(NSURL*)targetWorkflowURL;
@end