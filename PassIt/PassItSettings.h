//
//  PassItSettings.h
//  PassIt
//
//  Created by Andrew Richardson on 1/2/2014.
//
//

#import <Foundation/Foundation.h>

@interface PassItSettings : NSObject

+ (instancetype)sharedInstance;

@property (nonatomic, readonly, getter = isEnabled) BOOL enabled;
@property (nonatomic, readonly) BOOL useBeta;
@property (nonatomic, readonly, getter = isInstalled) BOOL installed;
@property (nonatomic, readonly, getter = isBetaVersionInstalled) BOOL betaVersionInstalled;
@property (nonatomic, readonly, getter = isAppStoreVersionInstalled) BOOL appStoreVersionInstalled;

@property (nonatomic, copy, readonly) NSString *URLSchemePrefix;
@property (nonatomic, copy, readonly) NSString *HTTPURLScheme;

- (void)registerForNotifications;

@end
