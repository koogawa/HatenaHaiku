//
//  Status.h
//  HatenaHaiku
//
//  Created by koogawa on 2014/03/31.
//  Copyright (c) 2014年 Kosuke Ogawa. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Status : NSObject

@property (nonatomic, readonly) NSNumber    *statusId;          // 投稿ID
@property (nonatomic, readonly) NSNumber    *inReplyToStatusId; // 返信先の投稿ID
@property (nonatomic, readonly) NSString    *keyword;           // キーワード
@property (nonatomic, readonly) NSString    *text;              // 本文
@property (nonatomic, readonly) NSString    *userId;            // 投稿者のID
@property (nonatomic, readonly) NSDate      *createdDate;       // 投稿日時

@end
