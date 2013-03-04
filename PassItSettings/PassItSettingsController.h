//
//  PassItSettingsController.h
//  PassItSettings
//
//  Created by Andrew Richardson on 2013-03-03.
//  Copyright (c) 2013 Andrew Richardson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Preferences/Preferences.h>
#import <MessageUI/MessageUI.h>

#define STR_CONTACT_DEVELOPER NSLocalizedStringWithDefaultValue(@"Contact the Developer", nil, PISettingsBundle(), @"Contact the Developer", @"Label for emailing developer")
#define STR_1P_NOT_INSTALLED_TITLE NSLocalizedStringWithDefaultValue(@"1Password Not Installed", nil, PISettingsBundle(), @"1Password Not Installed", @"Title for alert when 1Password isn't installed")
#define STR_1P_NOT_INSTALLED_MSG NSLocalizedStringWithDefaultValue(@"1Password is required to be installed in order for PassIt to work.", nil, PISettingsBundle(), @"1Password is required to be installed in order for PassIt to work.", @"Message for alert when 1Password isn't installed")
#define STR_OK NSLocalizedStringWithDefaultValue(@"OK", nil, PISettingsBundle(), @"OK", @"OK button label")
#define STR_APP_STORE NSLocalizedStringWithDefaultValue(@"App Store", nil, PISettingsBundle(), @"App Store", @"App Store button label")

@interface PassItSettingsController : PSListController <MFMailComposeViewControllerDelegate, UIAlertViewDelegate>

@property (nonatomic, retain) UIAlertView *notInstalledAlertView;

@end