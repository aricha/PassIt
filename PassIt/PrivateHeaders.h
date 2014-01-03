//
//  PrivateHeaders.h
//  PassIt
//
//  Created by Andrew Richardson on 2013-03-03.
//
//

#ifndef PassIt_PrivateHeaders_h
#define PassIt_PrivateHeaders_h

extern UIApplication *UIApp;

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

@interface NSURL (UIKitAdditions)
- (NSURL *)itmsURL;
@end

@interface UIApplication ()
- (NSString *)displayIDForURLScheme:(NSString *)urlScheme isPublic:(BOOL)public;
@end

typedef NS_ENUM(NSInteger, UIIconImageFormat) {
    UIIconImageFormatSettings = 0,
    UIIconImageFormatActivity = 2 // probably not accurate but whatever it fits
};

@class LSResourceProxy;
@interface UIImage ()
+ (UIImage *)_iconForResourceProxy:(LSResourceProxy *)proxy format:(UIIconImageFormat)format;
@end

@interface LSResourceProxy : NSObject
@end

@interface LSApplicationProxy : LSResourceProxy
+ (instancetype)applicationProxyForIdentifier:(NSString *)identifier;
@property (nonatomic, readonly) BOOL isInstalled;
@end

/* Settings */

@interface PSListController : UIViewController <UIAlertViewDelegate> {
    NSMutableArray *_specifiers;
}
- (NSMutableArray *)loadSpecifiersFromPlistName:(NSString *)plist target:(id)target;
@end

@interface PSTableCell : UITableViewCell
+ (int)cellTypeFromString:(NSString *)string;
@end

#endif
