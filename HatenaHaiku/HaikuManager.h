//
//  HaikuManager.h
//  HatenaHaiku
//
//  Created by koogawa.
//  Copyright (c) 2013年 Kosuke Ogawa. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HaikuManager;

@protocol HaikuManagerDelegate <NSObject>
@optional
- (void)haikuManager:(HaikuManager *)manager didFetchPublicTimelineWithData:(NSData *)data error:(NSError *)error;
- (void)haikuManager:(HaikuManager *)manager didFetchAlbumWithData:(NSData *)data error:(NSError *)error;
- (void)haikuManager:(HaikuManager *)manager didFetchHotKeywordsWithData:(NSData *)data error:(NSError *)error;
- (void)haikuManager:(HaikuManager *)manager didSearchKeywordsWithData:(NSData *)data error:(NSError *)error;
- (void)haikuManager:(HaikuManager *)manager didFetchStatusDetailWithData:(NSData *)data error:(NSError *)error;
- (void)haikuManager:(HaikuManager *)manager didFetchKeywordTimelineWithData:(NSData *)data error:(NSError *)error;
- (void)haikuManager:(HaikuManager *)manager didFetchUserTimelineWithData:(NSData *)data error:(NSError *)error;
@end

@interface HaikuManager : NSObject

@property (nonatomic, assign) id<HaikuManagerDelegate> delegate;

+ (HaikuManager *)sharedManager;

// みんなの最新エントリーを取得
- (void)fetchPublicTimelineWithPage:(NSInteger)page;

// アルバムページを取得
- (void)fetchAlbumWithPage:(NSInteger)page;

// ホットキーワードリストを取得
- (void)fetchHotKeywords;

// キーワードを検索
- (void)searchKeywordsWithKeyword:(NSString *)keyword;

// 投稿詳細を取得
- (void)fetchStatusDetailWithEid:(NSString *)eid;

// キーワードのエントリーを取得
- (void)fetchKeywordTimelineWithKeyword:(NSString *)keyword
                                   page:(NSInteger)page;

// ユーザのエントリーを取得
- (void)fetchUserTimelineWithUrlName:(NSString *)urlName
                                page:(NSInteger)page;

// 新たに投稿する
- (void)updateStatusWithKeyword:(NSString *)keyword
                         status:(NSString *)status
                      inReplyTo:(NSString *)statusId
                           file:(NSData *)file;

@end
