//
// ShellTask.m
//
//
// Created by Vincent Gable on 6/1/07.
// vincent.gable@gmail.com
// Copyright 2007 Vincent Gable, you're free to use this code in *any* way you like,
// but I'd really appreciate it if you told me what you used it for.  It could make my day.
//

#import "ShellTask.h"

@implementation ShellTask


// Returns an NSTask that is equvalent to
// sh -c <command>
// where <command> is passed directly to sh via argv, and is NOT quoted (so ~ expansion still works).
// stdin for the task is set to /dev/null .
// Note that the PWD for the task is whatever the current PWD for the executable sending the taskForCommand: message.
// Sending the task a - launch message will tell sh to run it.
+(NSTask*) taskForShellCommand:(NSString*)command
{
	NSTask* task = [[[NSTask alloc] init] autorelease];
	[task setLaunchPath:@"/bin/sh"];                                 // we are launching sh, it is wha will process command for us
	[task setStandardInput:[NSFileHandle fileHandleWithNullDevice]]; // stdin is directed to /dev/null


	NSArray* args = [NSArray arrayWithObjects:@"-c",                 // -c tells sh to execute commands from the next argument
					 command,                                        // sh will read and execute the commands in this string.
					 nil];
	[task setArguments:args];

	return task;
}

// Executes the shell command, command, waits for it to finish
// returning it's output to std in and stderr.
//
// NOTE: may deadlock under some circumstances if the output gets so big it fills the pipe.
// See http://dev.notoptimal.net/search/label/NSTask for an overview of the problem, and a solution.
// I have not experienced the problem myself, so I can’t comment.
+(NSString*) executeShellCommandSynchronously:(NSString*)command
{
	NSTask* task = [self taskForShellCommand:command];

	// we pipe stdout and stderr into a file handle that we read to
	NSPipe* outputPipe = [NSPipe pipe];
	[task setStandardOutput:outputPipe];
	[task setStandardError:outputPipe];
	NSFileHandle* outputFileHandle = [outputPipe fileHandleForReading];

	[task launch];

	return [[[NSString alloc] initWithData:[outputFileHandle readDataToEndOfFile] encoding:NSUTF8StringEncoding] autorelease];
}

+(oneway void) executeShellCommandAsynchronously:(NSString*)command
{
	[[self taskForShellCommand:command] launch];

	return;
}

@end
