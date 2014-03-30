//
//  MyViewController.m
//  HatenaHaiku
//
//  Created by koogawa on 2013/01/30.
//  Copyright (c) 2013年 Kosuke Ogawa. All rights reserved.
//

#import "MyViewController.h"
#import "AppDelegate.h"
#import "AuthManager.h"
#import "OAConsumer.h"
#import "OADataFetcher.h"
#import "OAMutableURLRequest.h"

@interface MyViewController ()

@end

@implementation MyViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        self.title = [[AuthManager sharedManager] displayName];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _haikuManager = [HaikuManager sharedManager];
    _haikuManager.delegate = self;

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

// 自分のエントリーを取得
- (void)fetchTimeline
{
    LOG_CURRENT_METHOD;

    [_haikuManager fetchUserTimelineWithUrlName:nil
                                           page:self.page];
}


#pragma mark - Override method

- (void)loadMore
{
    LOG_CURRENT_METHOD;
    
    [self fetchTimeline];
}


#pragma mark - Haiku Manager delegate

// 自分のエントリーが取れた
- (void)haikuManager:(HaikuManager *)manager didFetchUserTimelineWithData:(NSData *)data error:(NSError *)error
{
    LOG_CURRENT_METHOD;
    LOG(@"data = %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    
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

    if (error != nil)
    {
        LOG(@"error = %@", error);

        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        [SVProgressHUD showErrorWithStatus:@"取得できませんでした"];
        [self.refreshControl endRefreshing];
        return;
    }

    NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    
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
