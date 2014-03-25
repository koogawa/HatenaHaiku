//
//  AntennaViewController.m
//  HatenaHaiku
//
//  Created by koogawa on 2012/12/09.
//  Copyright (c) 2012年 Kosuke Ogawa. All rights reserved.
//

#import "AntennaViewController.h"
#import "AppDelegate.h"
#import "AuthManager.h"
#import "OAConsumer.h"
#import "OADataFetcher.h"
#import "OAMutableURLRequest.h"

@interface AntennaViewController ()

@end

@implementation AntennaViewController

#define FETCH_TIMELINE_NOTIFICATION    @"fetchTimelineFromAntenna"

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"アンテナ";
    
    [self fetchTimeline];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private method

- (void)refreshOccured:(id)sender
{
    LOG_CURRENT_METHOD;
    
    self.page = 1;
    
    [self fetchTimeline];
}

// キーワードのエントリーを取得
- (void)fetchTimeline
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
    
    OARequestParameter *p1 = [[OARequestParameter alloc] initWithName:@"count" value:[NSString stringWithFormat:@"%d", [[NSUserDefaults standardUserDefaults] integerForKey:@"CONFIG_FETCH_COUNT"]]];
    OARequestParameter *p2 = [[OARequestParameter alloc] initWithName:@"page" value:[NSString stringWithFormat:@"%d", self.page]];
    OARequestParameter *p3 = [[OARequestParameter alloc] initWithName:@"body_formats" value:@"html_mobile"];
    
    NSMutableArray *params = [NSMutableArray arrayWithObjects:p1, p2, p3, nil];
    
    [request setParameters:params];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [SVProgressHUD show];
    
    OADataFetcher *fetcher = [[OADataFetcher alloc] init];
    [fetcher fetchDataWithRequest:request
                         delegate:self
                didFinishSelector:@selector(ticket:didFinishWithData:)
                  didFailSelector:@selector(ticket:didFailWithError:)];
}


#pragma mark - Override method

- (void)loadMore
{
    LOG_CURRENT_METHOD;
    
    [self fetchTimeline];
}


#pragma mark - API Callback

// エントリーが取れた
- (void)ticket:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data
{
    LOG_CURRENT_METHOD;
    //LOG(@"data = %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [SVProgressHUD dismiss];
    
    // トークン切れチェック
    NSString *response = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if ([response isEqualToString:@"oauth_problem=token_rejected"])
    {
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate showLoginView];
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        [SVProgressHUD showSuccessWithStatus:@"ログイン期限が切れました"];
        
        return;
    }
    
    // 権限がない場合はライブラリの仕様で oauth_problem=nonce_used になる
    if ([response isEqualToString:@"oauth_problem=nonce_used"])
    {
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate showLoginView];
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        [SVProgressHUD showSuccessWithStatus:@"再ログインが必要です"];
        
        return;
    }
    
    // リロード中か？更に読込中か？
    if (self.page == 1) {
        [self.refreshControl endRefreshing];
    }
    else {
        [self stopMoreLoading];
    }
	
    NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    //LOG(@"statuses %@", jsonArray);
    
    if ([jsonArray count] == 0)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                        message:@"データがありません"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
    
    // 結果取得
    if (self.page == 1)
    {
        // 最初から読み込む場合は一度配列を空にする
        [self.statuses removeAllObjects];
        self.statuses = [NSMutableArray arrayWithArray:jsonArray];
    }
    else {
        [self.statuses addObjectsFromArray:jsonArray];
    }
    
    // 読み込み位置更新
    self.page++;
    
    [self.tableView reloadData];
}

- (void)ticket:(OAServiceTicket *)ticket didFailWithError:(NSError *)error
{
    LOG_CURRENT_METHOD;
    LOG(@"error = %@", error);
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [SVProgressHUD showErrorWithStatus:@"取得できませんでした"];
}

@end
