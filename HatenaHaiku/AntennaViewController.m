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
    
    _haikuManager = [[HaikuManager alloc] init];
    _haikuManager.delegate = self;

    [SVProgressHUD show];
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

// アンテナのエントリーを取得
- (void)fetchTimeline
{
    LOG_CURRENT_METHOD;

    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;

    NSInteger count = [[NSUserDefaults standardUserDefaults] integerForKey:@"CONFIG_FETCH_COUNT"];

    [_haikuManager fetchFriendsTimelineWithUrlName:nil
                                             count:count
                                              page:self.page];
}


#pragma mark - Override method

- (void)loadMore
{
    LOG_CURRENT_METHOD;
    
    [self fetchTimeline];
}


#pragma mark - Haiku Manager Delegate

// エントリーが取れた
- (void)haikuManager:(HaikuManager *)manager didFetchFriendsTimelineWithData:(NSData *)data error:(NSError *)error
{
    LOG_CURRENT_METHOD;
    //LOG(@"data = %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    // トークン切れチェック
    NSString *response = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if ([response isEqualToString:@"oauth_problem=token_rejected"])
    {
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate showLoginView];
        
        [SVProgressHUD showSuccessWithStatus:@"ログイン期限が切れました"];
        
        return;
    }
    
    // 権限がない場合はライブラリの仕様で oauth_problem=nonce_used になる
    if ([response isEqualToString:@"oauth_problem=nonce_used"])
    {
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate showLoginView];
        
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

    if (error != nil)
    {
        [SVProgressHUD showErrorWithStatus:@"取得できませんでした"];
        return;
    }

    [SVProgressHUD dismiss];

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

@end
