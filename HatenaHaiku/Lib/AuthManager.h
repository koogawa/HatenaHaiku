//
//  AuthManager.h
//
//  Created by koogawa on 12/01/08.
//  Copyright (c) 2012年 Kosuke Ogawa. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AuthManager : NSObject

+ (AuthManager *)sharedManager;

- (BOOL)isAuthenticated;
- (NSString *)accessToken;
- (NSString *)accessTokenSecret;
- (NSString *)urlName;
- (NSString *)displayName;
- (void)setAccessToken:(NSString *)accessToken;
- (void)setAccessTokenSecret:(NSString *)accessTokenSecret;
- (void)setUrlName:(NSString *)urlName;
- (void)setDisplayName:(NSString *)displayName;
- (void)clearAccessToken;

@end
