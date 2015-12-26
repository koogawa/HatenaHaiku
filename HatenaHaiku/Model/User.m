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
    NSString *userId;
    NSString *userId_ = json[@"id"];
    if ([userId_ isKindOfClass:[NSString class]]) {
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
    NSString *profileImageUrlString = json[@"profile_image_url"];
    if ([profileImageUrlString isKindOfClass:[NSString class]]) {
        profileImageURL = [NSURL URLWithString:profileImageUrlString];
    }

    // ファンの数
    NSNumber *followersCount;
    NSString *followersCountString = json[@"followers_count"];
    if ([followersCountString isKindOfClass:[NSString class]]) {
        followersCount = [NSNumber numberWithInt:[followersCountString intValue]];
    }

    return [self initWithUserId:userId
                           name:name
                profileImageURL:profileImageURL
                 followersCount:followersCount];
}

- (instancetype)initWithUserId:(NSString *)userId
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

- (NSString *)description
{
    NSMutableString *description = [NSMutableString stringWithFormat:@"<%@: ", NSStringFromClass([self class])];
    [description appendFormat:@"self.userId=%@", self.userId];
    [description appendFormat:@", self.name=%@", self.name];
    [description appendFormat:@", self.profileImageURL=%@", self.profileImageURL];
    [description appendFormat:@", self.followersCount=%@", self.followersCount];
    [description appendString:@">"];
    return description;
}

@end
