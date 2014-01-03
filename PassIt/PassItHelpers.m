//
//  PassItHelpers.m
//  PassIt
//
//  Created by Andrew Richardson on 2013-03-03.
//
//

#import "PassItHelpers.h"
#import "PrivateHeaders.h"
#import "PassItSettings.h"

NSString *const PassItBundleID = @"com.arichardson.PassIt";
const char *PassItSettingChangedNotification = "com.arichardson.PassIt.settingsChanged";

NSBundle *PIBundle(void)
{
	static NSBundle *PIBundle;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		PIBundle = [NSBundle bundleWithPath:@"/Library/Application Support/PassIt.bundle"];
	});
	return PIBundle;
}

NSBundle *PISettingsBundle(void)
{
	static NSBundle *PISettingsBundle;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		PISettingsBundle = [NSBundle bundleWithPath:@"/Library/PreferenceBundles/PassItSettings.bundle"];
	});
	return PISettingsBundle;
}

inline BOOL PICanOpenURLWithScheme(NSString *scheme)
{
    return [UIApp canOpenURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@://", scheme]]];
}

NSURL *PIOnePassFormattedURL(NSURL *url)
{
	NSString *onePassURLScheme = [[[PassItSettings sharedInstance] URLSchemePrefix] stringByAppendingString:[url scheme]];
	NSURL *onePassURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@:%@", onePassURLScheme, [url resourceSpecifier]]];
	return onePassURL;
}