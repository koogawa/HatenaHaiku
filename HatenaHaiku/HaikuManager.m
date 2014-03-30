//
//  HaikuManager.m
//  HatenaHaiku
//
//  Created by koogawa.
//  Copyright (c) 2013年 Kosuke Ogawa. All rights reserved.
//

#import "HaikuManager.h"
#import "AuthManager.h"
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

    OAMutableURLRequest *request = nil;

    // ユーザが指定されていない場合は自分のエントリを取得
    if (urlName == nil)
    {
        OAConsumer *consumer = [[OAConsumer alloc] initWithKey:OAUTH_CONSUMER_KEY
                                                        secret:OAUTH_CONSUMER_SECRET];

        OAToken *accessToken = [[OAToken alloc] initWithKey:[[AuthManager sharedManager] accessToken]
                                                     secret:[[AuthManager sharedManager] accessTokenSecret]];
        NSString *urlStr = [NSString stringWithFormat:@"http://h.hatena.ne.jp/api/statuses/user_timeline.json"];
        NSURL *url = [NSURL URLWithString:urlStr];

        request = [[OAMutableURLRequest alloc] initWithURL:url
                                                  consumer:consumer
                                                     token:accessToken
                                                     realm:nil
                                         signatureProvider:nil];
        [request setHTTPMethod:@"GET"];

        OARequestParameter *p1 = [[OARequestParameter alloc] initWithName:@"count" value:[NSString stringWithFormat:@"%d", [[NSUserDefaults standardUserDefaults] integerForKey:@"CONFIG_FETCH_COUNT"]]];
        OARequestParameter *p2 = [[OARequestParameter alloc] initWithName:@"page" value:[NSString stringWithFormat:@"%d", page]];
        OARequestParameter *p3 = [[OARequestParameter alloc] initWithName:@"body_formats" value:@"html_mobile"];

        NSMutableArray *params = [NSMutableArray arrayWithObjects:p1, p2, p3, nil];
        
        [request setParameters:params];
    }
    else {
        NSString *urlString = [NSString stringWithFormat:@"http://h.hatena.ne.jp/api/statuses/user_timeline/%@.json?count=%d&page=%d&body_formats=html_mobile", urlName, [[NSUserDefaults standardUserDefaults] integerForKey:@"CONFIG_FETCH_COUNT"], page];
        LOG(@"urlString = %@", urlString);

        request = [[OAMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]
                                                  consumer:nil
                                                     token:nil
                                                     realm:nil
                                         signatureProvider:nil];
        [request setHTTPMethod:@"GET"];
    }

    OADataFetcher *fetcher = [[OADataFetcher alloc] init];
    [fetcher fetchDataWithRequest:request
                         delegate:self
                didFinishSelector:@selector(ticket:didFetchUserTimelineWithData:)
                  didFailSelector:@selector(ticket:didFailToFetchUserTimelineWithError:)];
}

// 自分のアンテナを取得
- (void)fetchFriendsTimelineWithUrlName:(NSString *)urlName
                                  count:(NSInteger)count
                                   page:(NSInteger)page
{
    LOG_CURRENT_METHOD;

    OAConsumer *consumer = [[OAConsumer alloc] initWithKey:OAUTH_CONSUMER_KEY
                                                    secret:OAUTH_CONSUMER_SECRET];

    OAToken *accessToken = [[OAToken alloc] initWithKey:[[AuthManager sharedManager] accessToken]
                                                 secret:[[AuthManager sharedManager] accessTokenSecret]];
    NSString *urlStr = [NSString stringWithFormat:@"http://h.hatena.ne.jp/api/statuses/friends_timeline.json"];
    NSURL *url = [NSURL URLWithString:urlStr];

    OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:url
                                                                   consumer:consumer
                                                                      token:accessToken
                                                                      realm:nil
                                                          signatureProvider:nil];
    [request setHTTPMethod:@"GET"];

    OARequestParameter *p1 = [[OARequestParameter alloc] initWithName:@"count" value:[NSString stringWithFormat:@"%d", count]];
    OARequestParameter *p2 = [[OARequestParameter alloc] initWithName:@"page" value:[NSString stringWithFormat:@"%d", page]];
    OARequestParameter *p3 = [[OARequestParameter alloc] initWithName:@"body_formats" value:@"html_mobile"];

    NSMutableArray *params = [NSMutableArray arrayWithObjects:p1, p2, p3, nil];

    [request setParameters:params];

    OADataFetcher *fetcher = [[OADataFetcher alloc] init];
    [fetcher fetchDataWithRequest:request
                         delegate:self
                didFinishSelector:@selector(ticket:didFetchFriendsTimelineWithData:)
                  didFailSelector:@selector(ticket:didFailToFetchFriendsTimelineWithError:)];
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

// お気に入りユーザ一覧を取得
- (void)fetchFriendsWithPage:(NSInteger)page
{
    LOG_CURRENT_METHOD;

    OAConsumer *consumer = [[OAConsumer alloc] initWithKey:OAUTH_CONSUMER_KEY
                                                    secret:OAUTH_CONSUMER_SECRET];

    OAToken *accessToken = [[OAToken alloc] initWithKey:[[AuthManager sharedManager] accessToken]
                                                 secret:[[AuthManager sharedManager] accessTokenSecret]];
    NSString *urlStr = [NSString stringWithFormat:@"http://h.hatena.ne.jp/api/statuses/friends.json"];
    NSURL *url = [NSURL URLWithString:urlStr];

    OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:url
                                                                   consumer:consumer
                                                                      token:accessToken
                                                                      realm:nil
                                                          signatureProvider:nil];
    [request setHTTPMethod:@"GET"];

    OARequestParameter *p1 = [[OARequestParameter alloc] initWithName:@"page" value:[NSString stringWithFormat:@"%d", page]];

    NSMutableArray *params = [NSMutableArray arrayWithObjects:p1, nil];

    [request setParameters:params];

    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [SVProgressHUD show];

    OADataFetcher *fetcher = [[OADataFetcher alloc] init];
    [fetcher fetchDataWithRequest:request
                         delegate:self
                didFinishSelector:@selector(ticket:didFetchFriendsWithData:)
                  didFailSelector:@selector(ticket:didFailToFetchFriendsWithError:)];
}

// ファン一覧を取得
- (void)fetchFollowersWithPage:(NSInteger)page
{
    LOG_CURRENT_METHOD;

    OAConsumer *consumer = [[OAConsumer alloc] initWithKey:OAUTH_CONSUMER_KEY
                                                    secret:OAUTH_CONSUMER_SECRET];

    OAToken *accessToken = [[OAToken alloc] initWithKey:[[AuthManager sharedManager] accessToken]
                                                 secret:[[AuthManager sharedManager] accessTokenSecret]];
    NSString *urlStr = [NSString stringWithFormat:@"http://h.hatena.ne.jp/api/statuses/followers.json"];
    NSURL *url = [NSURL URLWithString:urlStr];

    OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:url
                                                                   consumer:consumer
                                                                      token:accessToken
                                                                      realm:nil
                                                          signatureProvider:nil];
    [request setHTTPMethod:@"GET"];

    OARequestParameter *p1 = [[OARequestParameter alloc] initWithName:@"page"
                                                                value:[NSString stringWithFormat:@"%d", page]];

    NSMutableArray *params = [NSMutableArray arrayWithObjects:p1, nil];

    [request setParameters:params];

    OADataFetcher *fetcher = [[OADataFetcher alloc] init];
    [fetcher fetchDataWithRequest:request
                         delegate:self
                didFinishSelector:@selector(ticket:didFetchFollowersWithData:)
                  didFailSelector:@selector(ticket:didFailToFetchFollowersWithError:)];
}

// お気に入りキーワード一覧を取得
- (void)fetchKeywordsWithPage:(NSInteger)page
       withoutRelatedKeywords:(BOOL)withoutRelatedKeywords
{
    LOG_CURRENT_METHOD;

    OAConsumer *consumer = [[OAConsumer alloc] initWithKey:OAUTH_CONSUMER_KEY
                                                    secret:OAUTH_CONSUMER_SECRET];

    OAToken *accessToken = [[OAToken alloc] initWithKey:[[AuthManager sharedManager] accessToken]
                                                 secret:[[AuthManager sharedManager] accessTokenSecret]];
    NSString *urlStr = [NSString stringWithFormat:@"http://h.hatena.ne.jp/api/statuses/keywords.json"];
    NSURL *url = [NSURL URLWithString:urlStr];

    OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:url
                                                                   consumer:consumer
                                                                      token:accessToken
                                                                      realm:nil
                                                          signatureProvider:nil];
    [request setHTTPMethod:@"GET"];

    OARequestParameter *p1 = [[OARequestParameter alloc] initWithName:@"page"
                                                                value:[NSString stringWithFormat:@"%d", page]];

    NSMutableArray *params = [NSMutableArray arrayWithObjects:p1, nil];

    // キーワードあれば追加
    if (withoutRelatedKeywords == YES)
    {
        OARequestParameter *p2 = [[OARequestParameter alloc] initWithName:@"without_related_keywords"
                                                                    value:@"1"];
        [params addObject:p2];
    }

    [request setParameters:params];

    OADataFetcher *fetcher = [[OADataFetcher alloc] init];
    [fetcher fetchDataWithRequest:request
                         delegate:self
                didFinishSelector:@selector(ticket:didFetchKeywordsWithData:)
                  didFailSelector:@selector(ticket:didFailToFetchKeywordsWithError:)];
}

// ユーザ情報を取得
- (void)fetchFriendships
{
    LOG_CURRENT_METHOD;

    OAConsumer *consumer = [[OAConsumer alloc] initWithKey:OAUTH_CONSUMER_KEY
                                                    secret:OAUTH_CONSUMER_SECRET];

    OAToken *accessToken = [[OAToken alloc] initWithKey:[[AuthManager sharedManager] accessToken]
                                                 secret:[[AuthManager sharedManager] accessTokenSecret]];
    NSString *urlStr = [NSString stringWithFormat:@"http://h.hatena.ne.jp/api/friendships/show.json"];
    NSURL *url = [NSURL URLWithString:urlStr];

    OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:url
                                                                   consumer:consumer
                                                                      token:accessToken
                                                                      realm:nil
                                                          signatureProvider:nil];
    [request setHTTPMethod:@"GET"];

    OADataFetcher *fetcher = [[OADataFetcher alloc] init];
    [fetcher fetchDataWithRequest:request
                         delegate:self
                didFinishSelector:@selector(ticket:didFetchFriendshipsWithData:)
                  didFailSelector:@selector(ticket:didFailToFetchFriendshipsWithError:)];
}

// 新たに投稿する
- (void)updateStatusWithKeyword:(NSString *)keyword
                         status:(NSString *)status
                      inReplyTo:(NSString *)statusId
                          image:(UIImage *)image
{
    LOG_CURRENT_METHOD;

    OAConsumer *consumer = [[OAConsumer alloc] initWithKey:OAUTH_CONSUMER_KEY
                                                    secret:OAUTH_CONSUMER_SECRET];

    OAToken *accessToken = [[OAToken alloc] initWithKey:[[AuthManager sharedManager] accessToken]
                                                 secret:[[AuthManager sharedManager] accessTokenSecret]];

    NSURL *url = [NSURL URLWithString:@"http://h.hatena.ne.jp/api/statuses/update.json"];

    OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:url
                                                                   consumer:consumer
                                                                      token:accessToken
                                                                      realm:nil
                                                          signatureProvider:nil];
    [request setHTTPMethod:@"POST"];

    OARequestParameter *p1 = [[OARequestParameter alloc] initWithName:@"status" value:status];
    OARequestParameter *p2 = [[OARequestParameter alloc] initWithName:@"source" value:APP_SOURCE];

    NSMutableArray *params = [NSMutableArray arrayWithObjects:p1, p2, nil];

    // キーワードあれば追加
    if ([keyword length] > 0)
    {
        OARequestParameter *p3 = [[OARequestParameter alloc] initWithName:@"keyword" value:keyword];
        [params addObject:p3];
    }

    // 返信先あれば追加
    if ([statusId length] > 0)
    {
        OARequestParameter *p4 = [[OARequestParameter alloc] initWithName:@"in_reply_to_status_id" value:statusId];
        [params addObject:p4];
    }

    [request setParameters:params];

    // 画像あれば追加
    if (image != nil)
    {
        NSData *imageData = UIImageJPEGRepresentation(image, 0.5);
        [request attachFileWithName:@"file" filename:@"image.jpg" contentType:@"image/jpeg" data:imageData];
    }

    OADataFetcher *fetcher = [[OADataFetcher alloc] init];
    [fetcher fetchDataWithRequest:request
                         delegate:self
                didFinishSelector:@selector(ticket:didUpdateStatusWithData:)
                  didFailSelector:@selector(ticket:didFailToUpdateStatusWithError:)];
}

// スターを付ける
- (void)createFavoritesWithStatusId:(NSString *)statusId
{
    LOG_CURRENT_METHOD;

    OAConsumer *consumer = [[OAConsumer alloc] initWithKey:OAUTH_CONSUMER_KEY
                                                    secret:OAUTH_CONSUMER_SECRET];

    OAToken *accessToken = [[OAToken alloc] initWithKey:[[AuthManager sharedManager] accessToken]
                                                 secret:[[AuthManager sharedManager] accessTokenSecret]];

    NSString *urlString = [NSString stringWithFormat:@"http://h.hatena.ne.jp/api/favorites/create/%@.json", statusId];
    NSURL *url = [NSURL URLWithString:urlString];
    LOG(@"urlString = %@", urlString);

    OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:url
                                                                   consumer:consumer
                                                                      token:accessToken
                                                                      realm:nil
                                                          signatureProvider:nil];
    [request setHTTPMethod:@"POST"];

    OADataFetcher *fetcher = [[OADataFetcher alloc] init];
    [fetcher fetchDataWithRequest:request
                         delegate:self
                didFinishSelector:@selector(ticket:didCreateFavoritesWithData:)
                  didFailSelector:@selector(ticket:didFailToCreateFavoritesWithError:)];
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

// 自分のアンテナを取得できた
- (void)ticket:(OAServiceTicket *)ticket didFetchFriendsTimelineWithData:(NSData *)data
{
    LOG_CURRENT_METHOD;
    LOG(@"data = %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);

    if ([self.delegate respondsToSelector:@selector(haikuManager:didFetchFriendsTimelineWithData:error:)]) {
        [self.delegate haikuManager:self didFetchFriendsTimelineWithData:data error:nil];
    }
}
- (void)ticket:(OAServiceTicket *)ticket didFailToFetchFriendsTimelineWithError:(NSError *)error
{
    LOG_CURRENT_METHOD;
    LOG(@"error = %@", error);

    if ([self.delegate respondsToSelector:@selector(haikuManager:didFetchFetchFriendsTimelineWithData:error:)]) {
        [self.delegate haikuManager:self didFetchFriendsTimelineWithData:nil error:error];
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

// お気に入りユーザ一覧が取得できた
- (void)ticket:(OAServiceTicket *)ticket didFetchFriendsWithData:(NSData *)data
{
    LOG_CURRENT_METHOD;
    LOG(@"data = %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);

    if ([self.delegate respondsToSelector:@selector(haikuManager:didFetchFriendsWithData:error:)]) {
        [self.delegate haikuManager:self didFetchFriendsWithData:data error:nil];
    }
}
- (void)ticket:(OAServiceTicket *)ticket didFailToFetchFriendsWithError:(NSError *)error
{
    LOG_CURRENT_METHOD;
    LOG(@"error = %@", error);

    if ([self.delegate respondsToSelector:@selector(haikuManager:didFetchFriendsWithData:error:)]) {
        [self.delegate haikuManager:self didFetchFriendsWithData:nil error:error];
    }
}

// ファン一覧が取得できた
- (void)ticket:(OAServiceTicket *)ticket didFetchFollowersWithData:(NSData *)data
{
    LOG_CURRENT_METHOD;
    LOG(@"data = %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);

    if ([self.delegate respondsToSelector:@selector(haikuManager:didFetchFollowersWithData:error:)]) {
        [self.delegate haikuManager:self didFetchFollowersWithData:data error:nil];
    }
}
- (void)ticket:(OAServiceTicket *)ticket didFailToFetchFollowersWithError:(NSError *)error
{
    LOG_CURRENT_METHOD;
    LOG(@"error = %@", error);

    if ([self.delegate respondsToSelector:@selector(haikuManager:didFetchFollowersWithData:error:)]) {
        [self.delegate haikuManager:self didFetchFollowersWithData:nil error:error];
    }
}

// お気に入りキーワード一覧が取得できた
- (void)ticket:(OAServiceTicket *)ticket didFetchKeywordsWithData:(NSData *)data
{
    LOG_CURRENT_METHOD;
    LOG(@"data = %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);

    if ([self.delegate respondsToSelector:@selector(haikuManager:didFetchKeywordsWithData:error:)]) {
        [self.delegate haikuManager:self didFetchKeywordsWithData:data error:nil];
    }
}
- (void)ticket:(OAServiceTicket *)ticket didFailToFetchKeywordsWithError:(NSError *)error
{
    LOG_CURRENT_METHOD;
    LOG(@"error = %@", error);

    if ([self.delegate respondsToSelector:@selector(haikuManager:didFetchKeywordsWithData:error:)]) {
        [self.delegate haikuManager:self didFetchKeywordsWithData:nil error:error];
    }
}

// ユーザ情報が取得できた
- (void)ticket:(OAServiceTicket *)ticket didFetchFriendshipsWithData:(NSData *)data
{
    LOG_CURRENT_METHOD;
    LOG(@"data = %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);

    if ([self.delegate respondsToSelector:@selector(haikuManager:didFetchFriendshipsWithData:error:)]) {
        [self.delegate haikuManager:self didFetchFriendshipsWithData:data error:nil];
    }
}
- (void)ticket:(OAServiceTicket *)ticket didFailToFetchFriendshipsWithError:(NSError *)error
{
    LOG_CURRENT_METHOD;
    LOG(@"error = %@", error);

    if ([self.delegate respondsToSelector:@selector(haikuManager:didFetchFriendshipsWithData:error:)]) {
        [self.delegate haikuManager:self didFetchFriendshipsWithData:nil error:error];
    }
}

// 新たに投稿できた
- (void)ticket:(OAServiceTicket *)ticket didUpdateStatusWithData:(NSData *)data
{
    LOG_CURRENT_METHOD;
    LOG(@"data = %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);

    if ([self.delegate respondsToSelector:@selector(haikuManager:didUpdateStatusWithData:error:)]) {
        [self.delegate haikuManager:self didUpdateStatusWithData:data error:nil];
    }
}
- (void)ticket:(OAServiceTicket *)ticket didFailToUpdateStatusWithError:(NSError *)error
{
    LOG_CURRENT_METHOD;
    LOG(@"error = %@", error);

    if ([self.delegate respondsToSelector:@selector(haikuManager:didUpdateStatusWithData:error:)]) {
        [self.delegate haikuManager:self didUpdateStatusWithData:nil error:error];
    }
}

// スターを付けた
- (void)ticket:(OAServiceTicket *)ticket didCreateFavoritesWithData:(NSData *)data
{
    LOG_CURRENT_METHOD;
    LOG(@"data = %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);

    if ([self.delegate respondsToSelector:@selector(haikuManager:didCreateFavoritesWithData:error:)]) {
        [self.delegate haikuManager:self didCreateFavoritesWithData:data error:nil];
    }
}
- (void)ticket:(OAServiceTicket *)ticket didFailToCreateFavoritesWithError:(NSError *)error
{
    LOG_CURRENT_METHOD;
    LOG(@"error = %@", error);

    if ([self.delegate respondsToSelector:@selector(haikuManager:didCreateFavoritesWithData:error:)]) {
        [self.delegate haikuManager:self didCreateFavoritesWithData:nil error:error];
    }
}

@end
