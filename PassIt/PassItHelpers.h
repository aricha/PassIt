//
//  PassItHelpers.h
//  PassIt
//
//  Created by Andrew Richardson on 2013-03-03.
//
//

#import <Foundation/Foundation.h>

// constants
extern NSString *const PassItBundleID;
extern const char *PassItSettingChangedNotification;
extern NSString *const PIOnePassHTTPUrlScheme;

// strings
#define STR_OPEN_IN_1P NSLocalizedStringWithDefaultValue(@"Open in 1Password", nil, PIBundle(), @"Open in 1Password", @"Title for action to open in 1Password")

// helper functions
NSBundle *PIBundle(void);
NSBundle *PISettingsBundle(void);
NSURL *PIOnePassFormattedURL(NSURL *url);
BOOL PIOnePassIsInstalled(void);