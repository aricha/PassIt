//
//  PassItSettingsController.m
//  PassItSettings
//
//  Created by Andrew Richardson on 2013-03-03.
//  Copyright (c) 2013 Andrew Richardson. All rights reserved.
//

#import "PassItSettingsController.h"
#import "PassItSettings.h"
#import <Preferences/PSSpecifier.h>

static NSString *const PITwitterScreenName = @"nosdrew";
static NSString *const PIEmailSubject = @"PassIt";
static NSString *const PIEmailAddress = @"contact@andrewr.me";

#define USE_BETA_VERSION_GROUP_ID @"useBetaVersionGroup"
#define CONTACT_SPEC_ID @"contactButton"
#define TWITTER_SPEC_ID @"twitterButton"

extern NSString *const PSIconImageKey;

static inline NSUInteger IndexOfSpecifierWithID(NSArray *specifiers, NSString *ID) {
    return [specifiers indexOfObjectPassingTest:^BOOL(PSSpecifier *specifier, NSUInteger idx, BOOL *stop) {
        return [[specifier identifier] isEqualToString:ID];
    }];
}

static inline PSSpecifier *SpecifierWithID(NSArray *specifiers, NSString *ID) {
    NSUInteger idx = IndexOfSpecifierWithID(specifiers, ID);
    return (idx != NSNotFound ? specifiers[idx] : nil);
}

@implementation PassItSettingsController

- (void)openTwitterPage:(PSSpecifier*)specifier
{
    NSURL *tweetbotURL = [NSURL URLWithString:[NSString stringWithFormat:@"tweetbot:///user_profile/%@", PITwitterScreenName]];
    if ([UIApp openURL:tweetbotURL]) return;
	
	NSURL *twitterAppURL = [NSURL URLWithString:[NSString stringWithFormat:@"twitter://user?screen_name=%@", PITwitterScreenName]];
	if ([UIApp openURL:twitterAppURL]) return;
	
	NSURL *twitterWebURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://twitter.com/%@", PITwitterScreenName]];
	[UIApp openURL:twitterWebURL];
}

- (void)composeMail:(PSSpecifier *)specifier
{
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *composer = [[[MFMailComposeViewController alloc] init] autorelease];
        [composer setMailComposeDelegate:self];
        [composer setSubject:PIEmailSubject];
        [composer setToRecipients:@[PIEmailAddress]];
        
        [self presentViewController:composer animated:YES completion:nil];
    }
    else {
        NSString *mailURL = [NSString stringWithFormat:@"mailto:%@?subject=%@", PIEmailAddress, PIEmailSubject];
        [UIApp openURL:[NSURL URLWithString:mailURL]];
    }
}

- (id)specifiers
{
	if (!_specifiers) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"PassItSettings" target:self] retain];
        
        if (![[PassItSettings sharedInstance] isBetaVersionInstalled]) {
            NSUInteger idx = IndexOfSpecifierWithID(_specifiers, USE_BETA_VERSION_GROUP_ID);
            if (idx != NSNotFound) {
                NSMutableIndexSet *indexesToRemove = [NSMutableIndexSet indexSetWithIndex:idx];
                [_specifiers enumerateObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(idx + 1, _specifiers.count - idx - 1)]
                                               options:0
                                            usingBlock:^(PSSpecifier *specifier, NSUInteger idx, BOOL *stop) {
                                                if ([specifier cellType] == [PSTableCell cellTypeFromString:@"PSGroupCell"]) {
                                                    *stop = YES;
                                                } else {
                                                    [indexesToRemove addIndex:idx];
                                                }
                                            }];
                [_specifiers removeObjectsAtIndexes:indexesToRemove];
            }
        }
        
        [self _setIconUsingAppIDIfAvailable:@"com.apple.mobilemail" forSpecifierWithID:CONTACT_SPEC_ID];
        [self _setIconUsingAppIDIfAvailable:@"com.atebits.Tweetie2" forSpecifierWithID:TWITTER_SPEC_ID];
    }
	return _specifiers;
}

- (void)_setIconUsingAppIDIfAvailable:(NSString *)appID forSpecifierWithID:(NSString *)specID
{
    PSSpecifier *spec = SpecifierWithID(_specifiers, specID);
    LSApplicationProxy *proxy = [LSApplicationProxy applicationProxyForIdentifier:appID];
    if ([proxy isInstalled]) {
        UIImage *image = [UIImage _iconForResourceProxy:proxy
                                                 format:UIIconImageFormatSettings];
        if (image)
            [spec setProperty:image forKey:PSIconImageKey];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	if (![[PassItSettings sharedInstance] isInstalled]) {
		UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:STR_1P_NOT_INSTALLED_TITLE
														 message:STR_1P_NOT_INSTALLED_MSG
														delegate:self
											   cancelButtonTitle:STR_OK
											   otherButtonTitles:STR_APP_STORE, nil] autorelease];
		self.notInstalledAlertView = alert;
		[alert show];
	}
}

- (id)isBetaVersionEnabled:(PSSpecifier *)specifier
{
    return @([[PassItSettings sharedInstance] useBeta]);
}

- (void)dealloc
{
	[_notInstalledAlertView dismissWithClickedButtonIndex:_notInstalledAlertView.cancelButtonIndex animated:NO];
	[_notInstalledAlertView release];
	
	[super dealloc];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)index
{
	if (alertView == self.notInstalledAlertView && index != alertView.cancelButtonIndex) {
		NSURL *onePassURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://itunes.apple.com/app/1password/id568903335?mt=8"] ];
		if ([onePassURL respondsToSelector:@selector(itmsURL)]) {
			NSURL *formattedURL = [onePassURL itmsURL];
			onePassURL = (formattedURL ?: onePassURL);
		}
		[UIApp openURL:onePassURL];
	}
	else
		[super alertView:alertView clickedButtonAtIndex:index];
	
	if (alertView == self.notInstalledAlertView) self.notInstalledAlertView = nil;
}

#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
	[self dismissViewControllerAnimated:YES completion:nil];
}

@end