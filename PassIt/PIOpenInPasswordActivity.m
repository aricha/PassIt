//
//  PIOpenInPasswordActivity.m
//  PassIt
//
//  Created by Andrew Richardson on 2013-03-03.
//
//

#import "PIOpenInPasswordActivity.h"
#import "PassItSettings.h"

static BOOL PIURLIsValid(NSURL *url)
{
	NSString *scheme = [url scheme];
	return [scheme isEqualToString:@"http"] || [scheme isEqualToString:@"https"];
}

static NSURL *PIFindURLFromActivityItems(NSArray *activityItems)
{
	NSUInteger idx = [activityItems indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
		return [obj isKindOfClass:[NSURL class]] && PIURLIsValid((NSURL *)obj);
	}];
	return (idx != NSNotFound ? activityItems[idx] : nil);
}

@interface PIOpenInPasswordActivity () {
	LSApplicationProxy *_appProxy;
	NSURL *_url;
}

@end

@implementation PIOpenInPasswordActivity

+ (UIActivityCategory)activityCategory
{
    return UIActivityCategoryShare;
}

- (id)init
{
    if (self = [super init]) {
		NSString *appID = [UIApp displayIDForURLScheme:[[PassItSettings sharedInstance] HTTPURLScheme] isPublic:YES];
        _appProxy = [[LSApplicationProxy applicationProxyForIdentifier:appID] retain];
    }
    return self;
}

- (void)dealloc
{
	[_appProxy release];
	[_url release];
	
	[super dealloc];
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems
{
	return ([[PassItSettings sharedInstance] isEnabled] && PIFindURLFromActivityItems(activityItems));
}

// don't use official activityImage method, doesn't work for app icons
- (UIImage *)_activityImage
{
	return [UIImage _iconForResourceProxy:_appProxy format:UIIconImageFormatActivity];
}

- (NSString *)activityType
{
	return [PassItBundleID stringByAppendingString:@".openIn1PasswordActivity"];
}

- (NSString *)activityTitle
{
	return STR_OPEN_IN_1P;
}

- (void)prepareWithActivityItems:(NSArray *)activityItems
{
	_url = [PIOnePassFormattedURL(PIFindURLFromActivityItems(activityItems)) retain];
}

- (void)performActivity
{
	[UIApp openURL:_url];
}

@end
