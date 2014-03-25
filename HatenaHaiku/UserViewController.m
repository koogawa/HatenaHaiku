//
//  UserViewController.m
//  HatenaHaiku
//
//  Created by koogawa on 2012/12/09.
//  Copyright (c) 2012年 Kosuke Ogawa. All rights reserved.
//

#import "UserViewController.h"

@interface UserViewController ()

@end

@implementation UserViewController

#define FETCH_TIMELINE_NOTIFICATION    @"fetchTimelineWithUserName"

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
    
    self.title = [self.userName stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
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
    
    NSString *urlString = [NSString stringWithFormat:@"http://h.hatena.ne.jp/api/statuses/user_timeline/%@.json?count=%d&page=%d&body_formats=html_mobile", self.userId, [[NSUserDefaults standardUserDefaults] integerForKey:@"CONFIG_FETCH_COUNT"], self.page];
    
	LOG(@"urlString = %@", urlString);
    NSURL *url = [NSURL URLWithString:urlString];
    
    HttpClient *client = [[HttpClient alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(fetchTimelineDidFinish:)
                                                 name:FETCH_TIMELINE_NOTIFICATION
                                               object:client];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [SVProgressHUD show];
    
    [client sendRequestWithURL:url method:@"GET" name:FETCH_TIMELINE_NOTIFICATION];
}


#pragma mark - Override method

- (void)loadMore
{
    LOG_CURRENT_METHOD;
    
    [self fetchTimeline];
}


#pragma mark - API Callback

// エントリーが取れた
- (void)fetchTimelineDidFinish:(NSNotification *)notification
{
    LOG_CURRENT_METHOD;
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [SVProgressHUD dismiss];
    
    // リロード中か？更に読込中か？
    if (self.page == 1) {
        [self.refreshControl endRefreshing];
    }
    else {
        [self stopMoreLoading];
    }
	
    HttpClient *client = (HttpClient *)[notification object];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:FETCH_TIMELINE_NOTIFICATION
                                                  object:client];
    
    if (client.error == nil)
    {
        NSData *jsonData = client.data;
        
        NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
        
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
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"エラー"
                                                        message:@"取得できませんでした"
                                                       delegate:nil
                                              cancelButtonTitle:@"Close"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
}

@end
