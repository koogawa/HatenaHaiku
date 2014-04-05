//
//  KeywordViewController.m
//  HatenaHaiku
//
//  Created by koogawa on 2012/12/08.
//  Copyright (c) 2012年 Kosuke Ogawa. All rights reserved.
//

#import "KeywordViewController.h"

@interface KeywordViewController ()

@end

@implementation KeywordViewController

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
    
    self.title = [self.keyword stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

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

- (void)postButtonAction
{
    NSDictionary *option = @{@"keyword": self.title};
    [self postButtonActionWithOption:option];
}

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
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [SVProgressHUD show];
    
    [_haikuManager fetchKeywordTimelineWithKeyword:self.keyword page:self.page];
}


#pragma mark - Override method

- (void)loadMore
{
    LOG_CURRENT_METHOD;
    
    [self fetchTimeline];
}


#pragma mark - HaikuManager delegate

// キーワードのエントリーが取れた
- (void)haikuManager:(HaikuManager *)manager didFetchKeywordTimelineWithData:(NSData *)data error:(NSError *)error
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
