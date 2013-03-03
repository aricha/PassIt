//
//  PassIt.mm
//  PassIt
//
//  Created by Andrew Richardson on 2013-03-03.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

// CaptainHook by Ryan Petrich
// see https://github.com/rpetrich/CaptainHook/

#import <Foundation/Foundation.h>
#import "CaptainHook/CaptainHook.h"
#include <notify.h> // not required; for examples only

// Objective-C runtime hooking using CaptainHook:
//   1. declare class using CHDeclareClass()
//   2. load class using CHLoadClass() or CHLoadLateClass() in CHConstructor
//   3. hook method using CHOptimizedMethod()
//   4. register hook using CHHook() in CHConstructor
//   5. (optionally) call old method using CHSuper()


@interface PassIt : NSObject

@end

@implementation PassIt

-(id)init
{
	if ((self = [super init]))
	{
	}

    return self;
}

@end


@class ClassToHook;

CHDeclareClass(ClassToHook); // declare class

CHOptimizedMethod(0, self, void, ClassToHook, messageName) // hook method (with no arguments and no return value)
{
	// write code here ...
	
	CHSuper(0, ClassToHook, messageName); // call old (original) method
}

CHOptimizedMethod(2, self, BOOL, ClassToHook, arg1, NSString*, value1, arg2, BOOL, value2) // hook method (with 2 arguments and a return value)
{
	// write code here ...

	return CHSuper(2, ClassToHook, arg1, value1, arg2, value2); // call old (original) method and return its return value
}

static void WillEnterForeground(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo)
{
	// not required; for example only
}

static void ExternallyPostedNotification(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo)
{
	// not required; for example only
}

CHConstructor // code block that runs immediately upon load
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	// listen for local notification (not required; for example only)
	CFNotificationCenterRef center = CFNotificationCenterGetLocalCenter();
	CFNotificationCenterAddObserver(center, NULL, WillEnterForeground, CFSTR("UIApplicationWillEnterForegroundNotification"), NULL, CFNotificationSuspensionBehaviorCoalesce);
	
	// listen for system-side notification (not required; for example only)
	// this would be posted using: notify_post("com.arichardson.PassIt.eventname");
	CFNotificationCenterRef darwin = CFNotificationCenterGetDarwinNotifyCenter();
	CFNotificationCenterAddObserver(darwin, NULL, ExternallyPostedNotification, CFSTR("com.arichardson.PassIt.eventname"), NULL, CFNotificationSuspensionBehaviorCoalesce);
	
	// CHLoadClass(ClassToHook); // load class (that is "available now")
	// CHLoadLateClass(ClassToHook);  // load class (that will be "available later")
	
	CHHook(0, ClassToHook, messageName); // register hook
	CHHook(2, ClassToHook, arg1, arg2); // register hook
	
	[pool drain];
}
