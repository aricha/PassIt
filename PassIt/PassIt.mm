//
//  PassIt.mm
//  PassIt
//
//  Created by Andrew Richardson on 2013-03-03.
//  Copyright (c) 2013 Andrew Richardson. All rights reserved.
//

#ifdef DEBUG
#define CHDebug
#endif

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "CaptainHook/CaptainHook.h"

@interface PIInteractionDelegateProxy : NSObject
@property (nonatomic, assign) id interactionDelegate;
@end

@implementation PIInteractionDelegateProxy

- (BOOL)respondsToSelector:(SEL)aSelector
{
	return ([super respondsToSelector:aSelector] || [self.interactionDelegate respondsToSelector:aSelector]);
}

- (id)forwardingTargetForSelector:(SEL)aSelector
{
	return (_interactionDelegate ?: [super forwardingTargetForSelector:aSelector]);
}

- (NSArray *)webView:(id)webView actionsForLinkElement:(id)element withTargetURL:(NSURL *)targetURL suggestedActions:(id)suggestedActions
{
	// TODO: add 1Password action
	NSArray *actions = [_interactionDelegate webView:webView actionsForLinkElement:element withTargetURL:targetURL suggestedActions:suggestedActions];
	CHDebugLog(@"actions: %@", actions);
	return actions;
}

@end

@class DOMNode;

@interface UIWebTiledView : UIView
@end

@interface UIWebDocumentView : UIWebTiledView
@property (nonatomic, assign) id interactionDelegate;
- (id)initWithWebView:(id)webView frame:(CGRect)frame; // designated initializer (iOS 6), but not used in some subclasses (ie. Safari)
@end

@interface UIWebElementActionInfo : NSObject
@property(readonly, assign, nonatomic) CGPoint interactionLocation;
@end

typedef void(^UIWebElementActionHandler)(DOMNode *node, NSURL *url, UIWebDocumentView *webDocumentView, UIWebElementActionInfo *actionInfo);

typedef enum {
	UIWebElementActionTypeLink = 1
	// ???
} UIWebElementActionType;

@interface UIWebElementAction : NSObject
- (id)initWithTitle:(NSString *)title actionHandler:(UIWebElementActionHandler)handler type:(UIWebElementActionType)type;
@end

CHDeclareClass(UIWebDocumentView)
CHDeclareProperty(UIWebDocumentView, interactionDelegateProxy)

static inline PIInteractionDelegateProxy *PIInitializeDelegateProxy(UIWebDocumentView *self)
{
	CHDebugLog(@"%s", __FUNCTION__);
	PIInteractionDelegateProxy *proxy = [[PIInteractionDelegateProxy new] autorelease];
	CHPropertySetValue(UIWebDocumentView, interactionDelegateProxy, proxy, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	self.interactionDelegate = proxy;
	return proxy;
}

CHOptimizedMethod0(self, void, UIWebDocumentView, _showLinkSheet)
{
	CHDebugLog(@"[%@ %s] interactionDelegate: %@", self, sel_getName(_cmd), [self interactionDelegate]);
	CHSuper0(UIWebDocumentView, _showLinkSheet);
}

CHOptimizedMethod2(self, id, UIWebDocumentView, initWithWebView, id, webView, frame, CGRect, frame)
{
	if ((self = CHSuper2(UIWebDocumentView, initWithWebView, webView, frame, frame))) {
		PIInitializeDelegateProxy(self);
	}
	return self;
}

CHOptimizedMethod1(self, void, UIWebDocumentView, setInteractionDelegate, id, delegate)
{
	if (![delegate isKindOfClass:[PIInteractionDelegateProxy class]]) {
		CHDebugLog(@"setting interactionDelegate to %@", delegate);
		id currentDelegate = self.interactionDelegate;
		if (!currentDelegate || ![currentDelegate isKindOfClass:[PIInteractionDelegateProxy class]])
			currentDelegate = PIInitializeDelegateProxy(self);
		[(PIInteractionDelegateProxy *)currentDelegate setInteractionDelegate:delegate];
	}
	else
		CHSuper1(UIWebDocumentView, setInteractionDelegate, delegate);
}

CHOptimizedMethod2(self, void, UIWebDocumentView, _createSheetWithElementActions, NSArray *, actions, showLinkTitle, BOOL, showTitle)
{
	CHDebugLog(@"%s with actions %@", sel_getName(_cmd), actions);
	
	UIWebElementActionHandler handler = ^(DOMNode *node, NSURL *url, UIWebDocumentView *webDocumentView, UIWebElementActionInfo *actionInfo) {
		CHDebugLog(@"called actionHandler; url: %@", url);
	};
	
	UIWebElementAction *passAction = [[UIWebElementAction alloc] initWithTitle:@"Open in 1Password" actionHandler:handler type:UIWebElementActionTypeLink];
	
	actions = [actions arrayByAddingObject:passAction];
	
	CHSuper2(UIWebDocumentView, _createSheetWithElementActions, actions, showLinkTitle, showTitle);
}

CHConstructor
{
	@autoreleasepool {
		CHLoadLateClass(UIWebDocumentView);
		CHHook0(UIWebDocumentView, _showLinkSheet);
		CHHook2(UIWebDocumentView, initWithWebView, frame);
		CHHook1(UIWebDocumentView, setInteractionDelegate);
		CHHook2(UIWebDocumentView, _createSheetWithElementActions, showLinkTitle);
	}
}
