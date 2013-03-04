//
//  PassIt.m
//  PassIt
//
//  Created by Andrew Richardson on 2013-03-03.
//  Copyright (c) 2013 Andrew Richardson. All rights reserved.
//

#import <notify.h>
#import "PIOpenInPasswordActivity.h"

static BOOL PassItEnabled = YES;

CHDeclareClass(UIActivityViewController)
CHDeclareClass(UIWebDocumentView)
CHDeclareClass(DOMHTMLAnchorElement)

CHOptimizedMethod2(self, void, UIWebDocumentView, _createSheetWithElementActions, NSArray *, actions, showLinkTitle, BOOL, showTitle)
{
	DOMNode *node = [self interactionElement];
	BOOL isAnchor = node && [(id)node isKindOfClass:CHClass(DOMHTMLAnchorElement)];
	
	if (isAnchor && PassItEnabled && PIOnePassIsInstalled()) {
		UIWebElementActionHandler handler = ^(DOMNode *node, NSURL *url, UIWebDocumentView *webDocumentView, UIWebElementActionInfo *actionInfo) {
			if (!url) return;
			
			NSURL *onePassURL = PIOnePassFormattedURL(url);
			if ([UIApp canOpenURL:onePassURL])
				[UIApp openURL:onePassURL];
		};
		
		UIWebElementAction *passAction = [[[UIWebElementAction alloc] initWithTitle:STR_OPEN_IN_1P
																	 actionHandler:handler
																			  type:UIWebElementActionTypeLink] autorelease];
		
		if (![actions isKindOfClass:[NSMutableArray class]]) actions = [NSMutableArray arrayWithArray:actions];
		NSMutableArray *mutableActions = (id)actions;
		
		// insert 1Password action after first "Open" action if possible; otherwise, just append it
		BOOL inserted = NO;
		if ([UIWebElementAction instancesRespondToSelector:@selector(type)]) {
			for (NSUInteger i = 0; i < mutableActions.count; i++) {
				UIWebElementAction *action = [mutableActions objectAtIndex:i];
				if (action.type != UIWebElementActionTypeLink) {
					[mutableActions insertObject:passAction atIndex:i];
					inserted = YES;
					break;
				}
			}
		}
		if (!inserted) [mutableActions addObject:passAction];
	}
	
	CHSuper2(UIWebDocumentView, _createSheetWithElementActions, actions, showLinkTitle, showTitle);
}

CHOptimizedClassMethod0(self, NSArray *, UIActivityViewController, _builtinActivities)
{
	static PIOpenInPasswordActivity *onePassActivity;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		onePassActivity = [PIOpenInPasswordActivity new];
	});
	
	NSArray *activities = CHSuper0(UIActivityViewController, _builtinActivities);
	
	return [activities arrayByAddingObject:onePassActivity];
}

static void UpdatePassItSettings(void)
{
	static NSString *const PassItEnabledKey = @"enabled";
	NSDictionary *userDefaults = [[NSUserDefaults standardUserDefaults] persistentDomainForName:PassItBundleID];
	NSNumber *enabled = [userDefaults objectForKey:PassItEnabledKey];
	PassItEnabled = (!enabled || [enabled boolValue]); // defaults to YES
}

CHConstructor
{
	@autoreleasepool {
		CHLoadClass(UIActivityViewController);
		CHLoadClass(UIWebDocumentView);
		CHLoadLateClass(DOMHTMLAnchorElement);
		
		CHHook2(UIWebDocumentView, _createSheetWithElementActions, showLinkTitle);
		
		CHHook0(UIActivityViewController, _builtinActivities);
		
		int notifyToken;
		notify_register_dispatch(PassItSettingChangedNotification, &notifyToken, dispatch_get_main_queue(), ^(int token) {
			UpdatePassItSettings();
		});
		
		// defer loading of settings because hey why not
		dispatch_async(dispatch_get_main_queue(), ^{
			UpdatePassItSettings();
		});
	}
}
