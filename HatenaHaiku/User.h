//
//  User.h
//  HatenaHaiku
//
//  Created by koogawa on 2014/04/06.
//  Copyright (c) 2014年 Kosuke Ogawa. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject

@property (nonatomic, readonly) NSNumber    *userId;            // はてなID
@property (nonatomic, readonly) NSString    *name;              // ニックネーム
@property (nonatomic, readonly) NSURL       *profileImageURL;   // プロフィール画像のURL
@property (nonatomic, readonly) NSNumber    *followersCount;    // ファンの数

- (instancetype)initWithJSONDictionary:(NSDictionary *)json;

- (instancetype)initWithUserId:(NSNumber *)userId
                          name:(NSString *)name
               profileImageURL:(NSURL *)profileImageURL
                followersCount:(NSNumber *)followersCount;

@end
