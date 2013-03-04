//
//  PassItHelpers.m
//  PassIt
//
//  Created by Andrew Richardson on 2013-03-03.
//
//

#import "PassItHelpers.h"
#import "PrivateHeaders.h"

NSString *const PassItBundleID = @"com.arichardson.PassIt";
const char *PassItSettingChangedNotification = "com.arichardson.PassIt.settingsChanged";
NSString *const PIOnePassHTTPUrlScheme = @"ophttp";

NSBundle *PIBundle(void)
{
	static NSBundle *PIBundle;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		PIBundle = [NSBundle bundleWithPath:@"/Library/Application Support/PassIt.bundle"];
	});
	return PIBundle;
}

NSURL *PIOnePassFormattedURL(NSURL *url)
{
	NSString *onePassURLScheme = [@"op" stringByAppendingString:[url scheme]];
	NSURL *onePassURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@:%@", onePassURLScheme, [url resourceSpecifier]]];
	return onePassURL;
}

BOOL PIOnePassIsInstalled(void)
{
	return [UIApp canOpenURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@://", PIOnePassHTTPUrlScheme]]];
}