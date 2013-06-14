//
// ShellTask.h
//
//
// Created by Vincent Gable on 6/1/07.
// vincent.gable@gmail.com
// Copyright 2007 Vincent Gable, you're free to use this code in *any* way you like,
// but I'd really appreciate it if you told me what you used it for.  It could make my day.
//

#import <Foundation/Foundation.h>


@interface ShellTask : NSObject {
}
// Returns an NSTask that is equvalent to
// sh -c <command>
// where <command> is passed directly to sh via argv, and is NOT quoted (so ~ expansion still works).
// stdin for the task is set to /dev/null .
// Note that the PWD for the task is whatever the current PWD for the executable sending the taskForCommand: message.
// Sending the task a - launch message will tell sh to run it.
+(NSTask*) taskForShellCommand:(NSString*)command;

// executes command, without blocking any threads.
+(oneway void) executeShellCommandAsynchronously:(NSString*)command;

// executes command, and returns it's output as a string.
// Blocks untill every action in command has completed.
// WARNING: Will gobble up memory if the command has **lots** of output.
// If the command has infinite output it will cause the system to slow down and eventually crash the caller.
// NOTE: may deadlock under some circumstances if the output gets so big it fills the pipe.
// See http://dev.notoptimal.net/search/label/NSTask for an overview of the problem, and a solution.
// I have not experienced the problem myself, so I can’t comment.
+(NSString*) executeShellCommandSynchronously:(NSString*)command;
@end
