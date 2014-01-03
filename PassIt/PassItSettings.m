//
//  PassItSettings.m
//  PassIt
//
//  Created by Andrew Richardson on 1/2/2014.
//
//

#import "PassItSettings.h"
#import <notify.h>

static NSString *const PassItEnabledKey = @"enabled";
static NSString *const PassItUseBetaKey = @"useBetaVersion";

static NSString *const PIOnePassDefaultURLPrefix = @"op";
static NSString *const PIOnePassBetaURLPrefix = @"opb";

@implementation PassItSettings {
    BOOL _enabled;
    BOOL _useBeta;
    BOOL _registeredForNotifications;
    int _notifyToken;
}

+ (instancetype)sharedInstance
{
	static id sharedInstance;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedInstance = [[PassItSettings alloc] init];
	});
	return sharedInstance;
}

- (id)init
{
    if ((self = [super init])) {
        [self _reloadSettings];
    }
    return self;
}

- (void)registerForNotifications
{
    if (_registeredForNotifications)
        return;
    
    _registeredForNotifications = YES;
    __block typeof(self) blockSelf = self;
    notify_register_dispatch(PassItSettingChangedNotification, &_notifyToken, dispatch_get_main_queue(), ^(int token) {
        [blockSelf _reloadSettings];
    });
}

- (BOOL)isInstalled
{
    return [self isAppStoreVersionInstalled] || [self isBetaVersionInstalled];
}

- (BOOL)isAppStoreVersionInstalled
{
    return [self _canOpenURLWithPrefix:PIOnePassDefaultURLPrefix];
}

- (BOOL)isBetaVersionInstalled
{
    return [self _canOpenURLWithPrefix:PIOnePassBetaURLPrefix];
}

- (BOOL)useBeta
{
    return ((_useBeta || ![self isAppStoreVersionInstalled]) && [self isBetaVersionInstalled]);
}

- (BOOL)isEnabled
{
    return (_enabled && [self isInstalled]);
}

- (NSString *)URLSchemePrefix
{
    return ([self useBeta] ? PIOnePassBetaURLPrefix : PIOnePassDefaultURLPrefix);
}

- (NSString *)HTTPURLScheme
{
    return [[self URLSchemePrefix] stringByAppendingString:@"http"];
}

- (BOOL)_canOpenURLWithPrefix:(NSString *)prefix
{
    return PICanOpenURLWithScheme([prefix stringByAppendingString:@"http"]);
}

- (void)_reloadSettings
{
	NSDictionary *userDefaults = [[NSUserDefaults standardUserDefaults] persistentDomainForName:PassItBundleID];
	
    NSNumber *enabled = [userDefaults objectForKey:PassItEnabledKey];
	_enabled = (!enabled || [enabled boolValue]); // defaults to YES
    
    NSNumber *useBeta = [userDefaults objectForKey:PassItUseBetaKey];
    _useBeta = [useBeta boolValue]; // defaults to NO
}

@end
