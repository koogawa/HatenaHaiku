//
//  AuthManager.m
//
//  Created by koogawa on 12/01/08.
//  Copyright (c) 2012年 Kosuke Ogawa. All rights reserved.
//

#import "AuthManager.h"

@implementation AuthManager

#define ACCESS_TOKEN_KEY    @"ACCESS_TOKEN"
#define ACCESS_TOKEN_SECRET @"ACCESS_TOKEN_SECRET"
#define URL_NAME            @"URL_NAME"
#define DISPLAY_NAME        @"DISPLAY_NAME"

static AuthManager *_sharedInstance = nil;

+ (AuthManager *)sharedManager
{
    // インスタンスを作成する
    if (!_sharedInstance) {
        _sharedInstance = [[AuthManager alloc] init];
    }
    
    return _sharedInstance;
}

- (BOOL)isAuthenticated
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return ([[defaults objectForKey:ACCESS_TOKEN_KEY] length] > 0) ? YES : NO;
}

- (NSString *)accessToken
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:ACCESS_TOKEN_KEY];
}

- (void)setAccessToken:(NSString *)accessToken
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:accessToken forKey:ACCESS_TOKEN_KEY];
    [defaults synchronize];
}

- (NSString *)accessTokenSecret
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:ACCESS_TOKEN_SECRET];
}

- (void)setAccessTokenSecret:(NSString *)accessTokenSecret
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:accessTokenSecret forKey:ACCESS_TOKEN_SECRET];
    [defaults synchronize];
}

- (NSString *)urlName
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:URL_NAME];
}

- (void)setUrlName:(NSString *)urlName
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:urlName forKey:URL_NAME];
    [defaults synchronize];
}

- (NSString *)displayName
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:DISPLAY_NAME];
}

- (void)setDisplayName:(NSString *)displayName
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:displayName forKey:DISPLAY_NAME];
    [defaults synchronize];
}

- (void)clearAccessToken
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:@"" forKey:ACCESS_TOKEN_KEY];
    [defaults setObject:@"" forKey:ACCESS_TOKEN_SECRET];
    [defaults setObject:@"" forKey:URL_NAME];
    [defaults setObject:@"" forKey:DISPLAY_NAME];
    [defaults synchronize];
}

@end
