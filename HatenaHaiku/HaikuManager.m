//
//  HaikuManager.m
//  HatenaHaiku
//
//  Created by koogawa.
//  Copyright (c) 2013年 Kosuke Ogawa. All rights reserved.
//

#import "HaikuManager.h"
#import "OAConsumer.h"
#import "OADataFetcher.h"
#import "OAMutableURLRequest.h"

@implementation HaikuManager

+ (HaikuManager *)sharedManager
{
    static HaikuManager *_instance = nil;

    @synchronized (self) {
        if (_instance == nil) {
            _instance = [[self alloc] init];
        }
    }

    return _instance;
}

- (id)init
{
    self = [super init];
    if (self) {
    }

    return self;
}


#pragma mark - Public method

// みんなの最新エントリーを取得
- (void)fetchPublicTimelineWithPage:(NSInteger)page
{
    LOG_CURRENT_METHOD;

    NSString *urlString = [NSString stringWithFormat:@"http://h.hatena.ne.jp/api/statuses/public_timeline.json?count=%d&page=%d&body_formats=html_mobile", [[NSUserDefaults standardUserDefaults] integerForKey:@"CONFIG_FETCH_COUNT"], page];
	LOG(@"urlString = %@", urlString);

    OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]
                                                                   consumer:nil
                                                                      token:nil
                                                                      realm:nil
                                                          signatureProvider:nil];
    [request setHTTPMethod:@"GET"];

    OADataFetcher *fetcher = [[OADataFetcher alloc] init];
    [fetcher fetchDataWithRequest:request
                         delegate:self
                didFinishSelector:@selector(ticket:didFetchPublicTimelineWithData:)
                  didFailSelector:@selector(ticket:didFailToFetchPublicTimelineWithError:)];
}

// アルバムページを取得
- (void)fetchAlbumWithPage:(NSInteger)page
{
    LOG_CURRENT_METHOD;

    NSString *urlString = [NSString stringWithFormat:@"http://h.hatena.ne.jp/api/statuses/album.json?count=40&page=%d&body_formats=api", page];
	LOG(@"urlString = %@", urlString);

    OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]
                                                                   consumer:nil
                                                                      token:nil
                                                                      realm:nil
                                                          signatureProvider:nil];
    [request setHTTPMethod:@"GET"];

    OADataFetcher *fetcher = [[OADataFetcher alloc] init];
    [fetcher fetchDataWithRequest:request
                         delegate:self
                didFinishSelector:@selector(ticket:didFetchAlbumWithData:)
                  didFailSelector:@selector(ticket:didFailToFetchAlbumWithError:)];
}

// ホットキーワードリストを取得
- (void)fetchHotKeywords
{
    LOG_CURRENT_METHOD;

    NSString *urlString = @"http://h.hatena.ne.jp/api/keywords/hot.json?without_related_keywords=1";
	LOG(@"urlString = %@", urlString);

    OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]
                                                                   consumer:nil
                                                                      token:nil
                                                                      realm:nil
                                                          signatureProvider:nil];
    [request setHTTPMethod:@"GET"];

    OADataFetcher *fetcher = [[OADataFetcher alloc] init];
    [fetcher fetchDataWithRequest:request
                         delegate:self
                didFinishSelector:@selector(ticket:didFetchHotKeywordsWithData:)
                  didFailSelector:@selector(ticket:didFailToFetchHotkeywordsWithError:)];
}

// キーワードを検索
- (void)searchKeywordsWithKeyword:(NSString *)keyword;
{
    LOG_CURRENT_METHOD;

    NSString *urlString = [NSString stringWithFormat:@"http://h.hatena.ne.jp/api/keywords/list.json?word=%@&without_related_keywords=1", [keyword encodedURLParameterString]];
	LOG(@"urlString = %@", urlString);

    OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]
                                                                   consumer:nil
                                                                      token:nil
                                                                      realm:nil
                                                          signatureProvider:nil];
    [request setHTTPMethod:@"GET"];

    OADataFetcher *fetcher = [[OADataFetcher alloc] init];
    [fetcher fetchDataWithRequest:request
                         delegate:self
                didFinishSelector:@selector(ticket:didSearchKeywordsWithData:)
                  didFailSelector:@selector(ticket:didFailToSearchKeywordsWithError:)];
}

// 投稿詳細を取得
- (void)fetchStatusDetailWithEid:(NSString *)eid;
{
    LOG_CURRENT_METHOD;

    NSString *urlString = [NSString stringWithFormat:@"http://h.hatena.ne.jp/api/statuses/show/%@.json?body_formats=html_mobile", eid];
	LOG(@"urlString = %@", urlString);

    OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]
                                                                   consumer:nil
                                                                      token:nil
                                                                      realm:nil
                                                          signatureProvider:nil];
    [request setHTTPMethod:@"GET"];

    OADataFetcher *fetcher = [[OADataFetcher alloc] init];
    [fetcher fetchDataWithRequest:request
                         delegate:self
                didFinishSelector:@selector(ticket:didFetchStatusDetailWithData:)
                  didFailSelector:@selector(ticket:didFailToFetchStatusDetailWithError:)];
}

// キーワードのエントリーを取得
- (void)fetchKeywordTimelineWithKeyword:(NSString *)keyword page:(NSInteger)page;
{
    LOG_CURRENT_METHOD;

    NSString *urlString = [NSString stringWithFormat:@"http://h.hatena.ne.jp/api/statuses/keyword_timeline.json?count=%d&page=%d&body_formats=html_mobile&word=%@", [[NSUserDefaults standardUserDefaults] integerForKey:@"CONFIG_FETCH_COUNT"], page, keyword];
	LOG(@"urlString = %@", urlString);

    OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]
                                                                   consumer:nil
                                                                      token:nil
                                                                      realm:nil
                                                          signatureProvider:nil];
    [request setHTTPMethod:@"GET"];

    OADataFetcher *fetcher = [[OADataFetcher alloc] init];
    [fetcher fetchDataWithRequest:request
                         delegate:self
                didFinishSelector:@selector(ticket:didFetchKeywordTimelineWithData:)
                  didFailSelector:@selector(ticket:didFailToFetchKeywordTimelineWithError:)];
}

// ユーザのエントリーを取得
- (void)fetchUserTimelineWithUrlName:(NSString *)urlName page:(NSInteger)page;
{
    LOG_CURRENT_METHOD;

    NSString *urlString = [NSString stringWithFormat:@"http://h.hatena.ne.jp/api/statuses/user_timeline/%@.json?count=%d&page=%d&body_formats=html_mobile", urlName, [[NSUserDefaults standardUserDefaults] integerForKey:@"CONFIG_FETCH_COUNT"], page];
	LOG(@"urlString = %@", urlString);

    OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]
                                                                   consumer:nil
                                                                      token:nil
                                                                      realm:nil
                                                          signatureProvider:nil];
    [request setHTTPMethod:@"GET"];

    OADataFetcher *fetcher = [[OADataFetcher alloc] init];
    [fetcher fetchDataWithRequest:request
                         delegate:self
                didFinishSelector:@selector(ticket:didFetchUserTimelineWithData:)
                  didFailSelector:@selector(ticket:didFailToFetchUserTimelineWithError:)];
}


#pragma mark - API Callback

// みんなの最新エントリーが取得できた
- (void)ticket:(OAServiceTicket *)ticket didFetchPublicTimelineWithData:(NSData *)data
{
    LOG_CURRENT_METHOD;
    LOG(@"data = %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);

    if ([self.delegate respondsToSelector:@selector(haikuManager:didFetchPublicTimelineWithData:error:)]) {
        [self.delegate haikuManager:self didFetchPublicTimelineWithData:data error:nil];
    }
}
- (void)ticket:(OAServiceTicket *)ticket didFailToFetchPublicTimelineWithError:(NSError *)error
{
    LOG_CURRENT_METHOD;
    LOG(@"error = %@", error);

    if ([self.delegate respondsToSelector:@selector(haikuManager:didFetchPublicTimelineWithData:error:)]) {
        [self.delegate haikuManager:self didFetchPublicTimelineWithData:nil error:error];
    }
}

// アルバムページが取得できた
- (void)ticket:(OAServiceTicket *)ticket didFetchAlbumWithData:(NSData *)data
{
    LOG_CURRENT_METHOD;
    LOG(@"data = %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);

    if ([self.delegate respondsToSelector:@selector(haikuManager:didFetchAlbumWithData:error:)]) {
        [self.delegate haikuManager:self didFetchAlbumWithData:data error:nil];
    }
}
- (void)ticket:(OAServiceTicket *)ticket didFailToFetchAlbumWithError:(NSError *)error
{
    LOG_CURRENT_METHOD;
    LOG(@"error = %@", error);

    if ([self.delegate respondsToSelector:@selector(haikuManager:didFetchAlbumWithData:error:)]) {
        [self.delegate haikuManager:self didFetchAlbumWithData:nil error:error];
    }
}

// ホットキーワードが取得できた
- (void)ticket:(OAServiceTicket *)ticket didFetchHotKeywordsWithData:(NSData *)data
{
    LOG_CURRENT_METHOD;
    LOG(@"data = %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);

    if ([self.delegate respondsToSelector:@selector(haikuManager:didFetchHotKeywordsWithData:error:)]) {
        [self.delegate haikuManager:self didFetchHotKeywordsWithData:data error:nil];
    }
}
- (void)ticket:(OAServiceTicket *)ticket didFailToFetchHotKeywordsWithError:(NSError *)error
{
    LOG_CURRENT_METHOD;
    LOG(@"error = %@", error);

    if ([self.delegate respondsToSelector:@selector(haikuManager:didFetchHotKeywordsWithData:error:)]) {
        [self.delegate haikuManager:self didFetchHotKeywordsWithData:nil error:error];
    }
}

// キーワードが検索できた
- (void)ticket:(OAServiceTicket *)ticket didSearchKeywordsWithData:(NSData *)data
{
    LOG_CURRENT_METHOD;
    LOG(@"data = %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);

    if ([self.delegate respondsToSelector:@selector(haikuManager:didSearchKeywordsWithData:error:)]) {
        [self.delegate haikuManager:self didSearchKeywordsWithData:data error:nil];
    }
}
- (void)ticket:(OAServiceTicket *)ticket didFailToSearchKeywordsWithError:(NSError *)error
{
    LOG_CURRENT_METHOD;
    LOG(@"error = %@", error);

    if ([self.delegate respondsToSelector:@selector(haikuManager:didSearchKeywordsWithData:error:)]) {
        [self.delegate haikuManager:self didSearchKeywordsWithData:nil error:error];
    }
}

// 投稿詳細が取得できた
- (void)ticket:(OAServiceTicket *)ticket didFetchStatusDetailWithData:(NSData *)data
{
    LOG_CURRENT_METHOD;
    LOG(@"data = %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);

    if ([self.delegate respondsToSelector:@selector(haikuManager:didFetchStatusDetailWithData:error:)]) {
        [self.delegate haikuManager:self didFetchStatusDetailWithData:data error:nil];
    }
}
- (void)ticket:(OAServiceTicket *)ticket didFailToFetchStatusDetailWithError:(NSError *)error
{
    LOG_CURRENT_METHOD;
    LOG(@"error = %@", error);

    if ([self.delegate respondsToSelector:@selector(haikuManager:didFetchStatusDetailWithData:error:)]) {
        [self.delegate haikuManager:self didFetchStatusDetailWithData:nil error:error];
    }
}

// キーワードのエントリーを取得できた
- (void)ticket:(OAServiceTicket *)ticket didFetchKeywordTimelineWithData:(NSData *)data
{
    LOG_CURRENT_METHOD;
    LOG(@"data = %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);

    if ([self.delegate respondsToSelector:@selector(haikuManager:didFetchKeywordTimelineWithData:error:)]) {
        [self.delegate haikuManager:self didFetchKeywordTimelineWithData:data error:nil];
    }
}
- (void)ticket:(OAServiceTicket *)ticket didFailToFetchKeywordTimelineWithError:(NSError *)error
{
    LOG_CURRENT_METHOD;
    LOG(@"error = %@", error);

    if ([self.delegate respondsToSelector:@selector(haikuManager:didFetchKeywordTimelineWithData:error:)]) {
        [self.delegate haikuManager:self didFetchKeywordTimelineWithData:nil error:error];
    }
}

// ユーザのエントリーを取得できた
- (void)ticket:(OAServiceTicket *)ticket didFetchUserTimelineWithData:(NSData *)data
{
    LOG_CURRENT_METHOD;
    LOG(@"data = %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);

    if ([self.delegate respondsToSelector:@selector(haikuManager:didFetchUserTimelineWithData:error:)]) {
        [self.delegate haikuManager:self didFetchUserTimelineWithData:data error:nil];
    }
}
- (void)ticket:(OAServiceTicket *)ticket didFailToFetchUserTimelineWithError:(NSError *)error
{
    LOG_CURRENT_METHOD;
    LOG(@"error = %@", error);

    if ([self.delegate respondsToSelector:@selector(haikuManager:didFetchUserTimelineWithData:error:)]) {
        [self.delegate haikuManager:self didFetchUserTimelineWithData:nil error:error];
    }
}

@end
