//
//  User.m
//  HatenaHaiku
//
//  Created by koogawa on 2014/04/06.
//  Copyright (c) 2014年 Kosuke Ogawa. All rights reserved.
//

#import "User.h"

@implementation User

- (instancetype)initWithJSONDictionary:(NSDictionary *)json
{
    // はてなID
    NSNumber *userId;
    NSNumber *userId_ = json[@"id"];
    if ([userId_ isKindOfClass:[NSNumber class]]) {
        userId = userId_;
    }

    // ニックネーム
    NSString *name;
    NSString *name_ = json[@"name"];
    if ([name_ isKindOfClass:[NSString class]]) {
        name = name_;
    }

    // プロフィール画像のURL
    NSURL *profileImageURL;
    NSURL *profileImageURL_ = json[@"profile_image_url"];
    if ([profileImageURL_ isKindOfClass:[NSURL class]]) {
        profileImageURL = profileImageURL_;
    }

    // ファンの数
    NSNumber *followersCount;
    NSNumber *followersCount_ = json[@"followers_count"];
    if ([followersCount_ isKindOfClass:[NSNumber class]]) {
        followersCount = followersCount_;
    }

    return [self initWithUserId:userId
                           name:name
                profileImageURL:profileImageURL
                 followersCount:followersCount];
}

- (instancetype)initWithUserId:(NSNumber *)userId
                          name:(NSString *)name
               profileImageURL:(NSURL *)profileImageURL
                followersCount:(NSNumber *)followersCount
{
    self = [super init];
    if (self) {
        _userId = userId;
        _name = name;
        _profileImageURL = profileImageURL;
        _followersCount = followersCount;
    }

    return self;
}

@end
