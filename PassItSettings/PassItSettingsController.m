//
//  PassItSettingsController.m
//  PassItSettings
//
//  Created by Andrew Richardson on 2013-03-03.
//  Copyright (c) 2013 Andrew Richardson. All rights reserved.
//

#import "PassItSettingsController.h"
#import <Preferences/PSSpecifier.h>

static NSString *const PITwitterScreenName = @"nosdrew";
static NSString *const PIEmailSubject = @"PassIt";
static NSString *const PIEmailAddress = @"contact@andrewr.me";

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
	if (!_specifiers)
		_specifiers = [[self loadSpecifiersFromPlistName:@"PassItSettings" target:self] retain];
	
	return _specifiers;
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	if (!PIOnePassIsInstalled()) {
		UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"1Password Not Installed"
														 message:@"1Password is required to be installed in order for PassIt to work."
														delegate:self
											   cancelButtonTitle:@"OK"
											   otherButtonTitles:@"App Store", nil] autorelease];
		self.notInstalledAlertView = alert;
		[alert show];
	}
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