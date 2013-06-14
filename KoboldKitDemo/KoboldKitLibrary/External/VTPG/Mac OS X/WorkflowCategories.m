//
// WorkflowCategories.m
// IMLocation
//
// Created by Vincent Gable on 12/5/08.
// Copyright 2008 Vincent Gable. All rights reserved.
//

#import "WorkflowCategories.h"
#import <OSAKit/OSAKit.h> // OSAScriptErrorMessage

@implementation AMWorkflow (VTPGExtras)

+(AMWorkflow*) workflowAtURL:(NSURL*)url error:(NSError**)outError;
{
	if (!url)
	{
		NSLog(@"nil passed to %s", __FUNCTION__);
		return nil;
	}
	return [[[AMWorkflow alloc] initWithContentsOfURL:url error:(id*)outError] autorelease];
}

+(AMWorkflow*) workflowAtURL:(NSURL*)url
{
	if (!url)
	{
		NSLog(@"nil passed to %s", __FUNCTION__);
		return nil;
	}
	id error = nil;
	AMWorkflow* workflow = [[self class] workflowAtURL:url error:&error];
	if (error)
	{
		NSLog(@"%s got error %@ loading %@", __FUNCTION__, error, url);
	}
	return workflow;
}

+(AMWorkflow*) workflowFromURL:(NSURL*)workflowURL error:(NSError**)outError
{
	id error = nil;
	AMWorkflow* aWorkflow = [[self class] workflowAtURL:workflowURL error:&error];

	// create the workflow file if it has not been created yet.
	if ([[error domain] isEqualTo:NSCocoaErrorDomain] && [error code] == 4) // file not found error
	{
		// try to make an empty workflow file

		error = nil;                                                        // clear the error file-not-found error
		aWorkflow = [[[AMWorkflow alloc] init] autorelease];
		[aWorkflow writeToURL:workflowURL error:&error];
	}

	if (outError)
	{
		*outError = error;
	}

	return aWorkflow;
}

+(AMWorkflow*) loadOrCreateWorkflowAt:(NSURL*)workflowURL;
{
	return [[self class] workflowFromURL:workflowURL error:nil];
}

-(void) addEveryActionToFile:(NSURL*)targetWorkflowURL;
{
	AMWorkflow* targetWorkflow = [AMWorkflow loadOrCreateWorkflowAt:targetWorkflowURL];
	for (AMAction* anAction in [self actions])
	{
		[targetWorkflow addAction:anAction];
	}

	id error = nil;
	[targetWorkflow writeToURL:targetWorkflowURL error:&error];
	if (error)
	{
		NSLog(@"***WARNING: Could not write to url %@, error %@", targetWorkflowURL, error);
	}
}

@end