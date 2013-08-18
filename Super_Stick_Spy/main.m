//
//  main.m
//  KoboldKitDemo
//
//  Created by Steffen Itterheim on 13.06.13.
//  Copyright (c) 2013 Steffen Itterheim. All rights reserved.
//

#import "AppDelegate.h"

int main(int argc, char * argv[])
{
	@autoreleasepool
	{
#if TARGET_OS_IPHONE
	    return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
#else
		return NSApplicationMain(argc, (const char**)argv);
#endif
	}
}
