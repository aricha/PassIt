//
//  PIOpenInPasswordActivity.m
//  PassIt
//
//  Created by Andrew Richardson on 2013-03-03.
//
//

#import "PIOpenInPasswordActivity.h"

static NSURL *PIFindURLFromActivityItems(NSArray *activityItems)
{
	NSUInteger idx = [activityItems indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
		return [obj isKindOfClass:[NSURL class]];
	}];
	return (idx != NSNotFound ? activityItems[idx] : nil);
}

@interface PIOpenInPasswordActivity () {
	LSApplicationProxy *_appProxy;
	NSURL *_url;
}

@end

@implementation PIOpenInPasswordActivity

- (id)init
{
    if (self = [super init]) {
		NSString *appID = [UIApp displayIDForURLScheme:PIOnePassHTTPUrlScheme isPublic:YES];
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
	return (PIOnePassIsInstalled() && PIFindURLFromActivityItems(activityItems));
}

// don't use official activityImage method, doesn't work for app icons
- (UIImage *)_activityImage
{
	return [UIImage _iconForResourceProxy:_appProxy format:2];
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
	if ([UIApp canOpenURL:_url])
		[UIApp openURL:_url];
}

@end
