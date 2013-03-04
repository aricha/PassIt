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

#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
	[self dismissViewControllerAnimated:YES completion:nil];
}

@end