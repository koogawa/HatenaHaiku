//
//  RecentViewController.m
//  HatenaHaiku
//
//  Created by koogawa on 2012/11/27.
//  Copyright (c) 2012年 Kosuke Ogawa. All rights reserved.
//

#import "RecentViewController.h"

@interface RecentViewController ()

@end

@implementation RecentViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        self.heightDic = [[NSMutableDictionary alloc] init];
        self.tabBarItem.image = [UIImage imageNamed:@"recent.png"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"最新エントリー";
    
    _haikuManager = [[HaikuManager alloc] init];
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

// みんなの最新エントリーを取得
- (void)fetchTimeline
{
    LOG_CURRENT_METHOD;

    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [SVProgressHUD show];

    [_haikuManager fetchPublicTimelineWithPage:self.page];
}


#pragma mark - Override method

- (void)loadMore
{
    LOG_CURRENT_METHOD;
    
    [self fetchTimeline];
}


#pragma mark - HaikuManager delegate

- (void)haikuManager:(HaikuManager *)manager didFetchPublicTimelineWithData:(NSData *)data error:(NSError *)error
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

    if (error == nil)
    {
        NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        LOG(@"jsonArray %@", jsonArray);

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
