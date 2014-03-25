//
//  RecentViewController.m
//  HatenaHaiku
//
//  Created by koogawa on 2012/11/27.
//  Copyright (c) 2012年 Kosuke Ogawa. All rights reserved.
//

#import "RecentViewController.h"
//#import "DetailViewController.h"

@interface RecentViewController ()

@end

@implementation RecentViewController

#define FETCH_TIMELINE_NOTIFICATION    @"fetchTimelineFromRecentTab"

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
    
    // みんなの最新エントリーを取得
    NSString *urlString = [NSString stringWithFormat:@"http://h.hatena.ne.jp/api/statuses/public_timeline.json?count=%d&page=%d&body_formats=html_mobile", [[NSUserDefaults standardUserDefaults] integerForKey:@"CONFIG_FETCH_COUNT"], self.page];
    
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

//- (void)fetchTimeLine
//{
//    // みんなの最新エントリーを取得
//    NSString *urlString = [NSString stringWithFormat:@"http://h.hatena.ne.jp/api/statuses/public_timeline.json?count=5&body_formats=html_mobile"];
//    
//    // キーワードある場合
//    if (self.keyword != nil) {
//        urlString = [NSString stringWithFormat:@"http://h.hatena.ne.jp/api/statuses/keyword_timeline.json?count=20&body_formats=html_mobile&word=%@", self.keyword];
//    }
//    
//    // キーワードある場合
//    if (self.userName != nil) {
//        urlString = [NSString stringWithFormat:@"http://h.hatena.ne.jp/api/statuses/user_timeline/%@.json?count=20&body_formats=html_mobile", self.userName];
//    }
//    
//	LOG(@"urlString = %@", urlString);
//    NSURL *url = [NSURL URLWithString:urlString];
//    
//    [self.refreshControl endRefreshing];
//    [self stopMoreLoading];
//    
//	NSString *response = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
//	NSData *jsonData = [response dataUsingEncoding:NSUTF32BigEndianStringEncoding];
//    NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
//    NSLog(@"statuses %@", jsonArray);
//    
//	// 結果取得
//    //statuses_ = [jsonArray mutableCopy];
//    [statuses_ addObjectsFromArray:jsonArray];
//
//    // 高さ分析
////    for (int i = 0; i < [jsonArray count]; i++)
////    {
////        NSDictionary *jsonDic = [jsonArray objectAtIndex:i];
////        NSString *html = [jsonDic objectForKey:@"html_mobile"];
////        html = [NSString stringWithFormat:@"<div id='contents'>%@</div>", html];
////
////        UIWebView *webView = [[UIWebView alloc] init];
////        webView.delegate = self;
////        webView.tag = i;
////        [webView loadHTMLString:html baseURL:nil];
////        [self.view addSubview:webView];
////        // TODO:
////    }
//    
//    [self.tableView reloadData];
//}

//- (void)linkDidTap:(NSString *)urlString
//{
//    LOG_CURRENT_METHOD;
//    
//}


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
        //LOG(@"jsonArray %@", jsonArray);
        
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


#pragma mark - Table view delegate

//- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    
//}

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    LOG_CURRENT_METHOD;
//    
//    CGFloat height = [[self.heightDic objectForKey:[NSString stringWithFormat:@"%d", indexPath.row]] floatValue];
//    NSLog(@"%f", height);
//    return height + 100;;
//}


//-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    LOG_CURRENT_METHOD;
//    
//    int row = [indexPath row];
//    
//    id cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
//    if(cell == nil){// はじめに呼ばれた場合
//        return 100.0;
//    }
//    // 二回目以降は必要な高さ
//    CGFloat height = ((StatusTableViewCell *)cell).bodyWebView.scrollView.contentSize.height;
//                       NSLog(@"heightt %f", height);
//
//    return height + 44;
//    
//}
//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    LOG_CURRENT_METHOD;
//    id cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
////    [cell setNeedsLayout];
////    [cell layoutIfNeeded];
//    
//    UIWebView *tmpWebView = [[UIWebView alloc] init];
//    NSString *html = [[statuses_ objectAtIndex:indexPath.row] objectForKey:@"html_mobile"];
//    html = [NSString stringWithFormat:@"<div id='contents'>%@</div>", html];
//    NSLog(@"html %@", html);
//    [tmpWebView loadHTMLString:html baseURL:nil];
//    //CGFloat height = [[tmpWebView stringByEvaluatingJavaScriptFromString:@"document.documentElement.scrollHeight"] floatValue];
//    //CGFloat height = [[((StatusTableViewCell *)cell).bodyWebView stringByEvaluatingJavaScriptFromString:@"document.getElementById(\"contents\").offsetHeight"] floatValue];
//    [tmpWebView sizeToFit];
//    CGFloat height = tmpWebView.scrollView.contentSize.height;
//    NSLog(@"heightt %f", height);
//    NSLog(@"rect = %@", NSStringFromCGRect(((StatusTableViewCell *)cell).bodyWebView.frame));
//    NSLog(@"contentHeithg %f", ((StatusTableViewCell *)cell).contentHeight);
//    return 500;
//}



#pragma mark - UIWebViewDelegate

// コンテンツに合わせてリサイズ
//- (void)webViewDidFinishLoad:(UIWebView *)webView
//{
//    LOG_CURRENT_METHOD;
//    
//    CGFloat contentHeight = [[webView stringByEvaluatingJavaScriptFromString:
//                              @"document.getElementById(\"contents\").offsetHeight"] floatValue];
//    NSString *output = [webView stringByEvaluatingJavaScriptFromString:@"document.body.offsetHeight;"];
//    NSLog(@"%d height: %f", webView.tag, contentHeight);
//    NSMutableDictionary *statusDic = [statuses_ objectAtIndex:webView.tag];
//    //[statusDic setObject:[NSNumber numberWithInteger:contentHeight] forKey:@"contentHeight"];
//    [self.heightDic setObject:[NSNumber numberWithFloat:contentHeight] forKey:[NSString stringWithFormat:@"%d", webView.tag]];
//    NSLog(@"self.heightDic %@", self.heightDic);
//    
//    webView.delegate = nil;
//    [webView removeFromSuperview];
//    
//    //if (webView.tag == 99) [self.tableView reloadData];
//}


@end
