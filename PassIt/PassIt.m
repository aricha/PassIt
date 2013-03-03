//
//  PassIt.m
//  PassIt
//
//  Created by Andrew Richardson on 2013-03-03.
//  Copyright (c) 2013 Andrew Richardson. All rights reserved.
//

#ifdef DEBUG
	#define CHDebug
#endif
#define CHAppName "PassIt"

static NSString *PassItBundleID = @"com.arichardson.PassIt";
static const char *PassItSettingChangedNotification = "com.arichardson.PassIt.settingsChanged";

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "CaptainHook/CaptainHook.h"
#import <notify.h>

@class DOMNode;

@interface UIWebTiledView : UIView
@end

@interface UIWebDocumentView : UIWebTiledView
- (DOMNode *)interactionElement;
@end

@interface UIWebElementActionInfo : NSObject
@property(readonly, assign, nonatomic) CGPoint interactionLocation;
@end

typedef void(^UIWebElementActionHandler)(DOMNode *node, NSURL *url, UIWebDocumentView *webDocumentView, UIWebElementActionInfo *actionInfo);

typedef NS_ENUM(NSInteger, UIWebElementActionType) {
	UIWebElementActionTypeCustom,
	UIWebElementActionTypeLink,
	UIWebElementActionTypeCopy,
	UIWebElementActionTypeSaveImage
};

@interface UIWebElementAction : NSObject
@property(readonly, assign, nonatomic) UIWebElementActionType type;
- (id)initWithTitle:(NSString *)title actionHandler:(UIWebElementActionHandler)handler type:(UIWebElementActionType)type;
@end

static BOOL PassItEnabled = YES;

CHDeclareClass(UIWebDocumentView)
CHDeclareClass(DOMHTMLAnchorElement)

CHOptimizedMethod2(self, void, UIWebDocumentView, _createSheetWithElementActions, NSArray *, actions, showLinkTitle, BOOL, showTitle)
{
	DOMNode *node = [self interactionElement];
	BOOL isAnchor = node && [(id)node isKindOfClass:CHClass(DOMHTMLAnchorElement)];
	
	if (isAnchor && PassItEnabled) {
		UIWebElementActionHandler handler = ^(DOMNode *node, NSURL *url, UIWebDocumentView *webDocumentView, UIWebElementActionInfo *actionInfo) {
			if (!url) return;
			
			NSString *onePassURLScheme = [@"op" stringByAppendingString:[url scheme]];
			NSURL *onePassURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@:%@", onePassURLScheme, [url resourceSpecifier]]];
			if ([[UIApplication sharedApplication] canOpenURL:onePassURL])
				[[UIApplication sharedApplication] openURL:onePassURL];
		};
		
		UIWebElementAction *passAction = [[[UIWebElementAction alloc] initWithTitle:@"Open in 1Password"
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
		CHLoadLateClass(UIWebDocumentView);
		CHLoadLateClass(DOMHTMLAnchorElement);
		
		CHHook2(UIWebDocumentView, _createSheetWithElementActions, showLinkTitle);
		
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
