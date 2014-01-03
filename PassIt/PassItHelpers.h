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

// strings
#define STR_OPEN_IN_1P NSLocalizedStringWithDefaultValue(@"Open in 1Password", nil, PIBundle(), @"Open in 1Password", @"Title for action to open in 1Password")

// helper functions
extern NSBundle *PIBundle(void);
extern NSBundle *PISettingsBundle(void);

extern inline BOOL PICanOpenURLWithScheme(NSString *scheme);
extern NSURL *PIOnePassFormattedURL(NSURL *url);