//
//  BaseViewController.m
//  HatenaHaiku
//
//  Created by koogawa on 2012/12/05.
//  Copyright (c) 2012年 Kosuke Ogawa. All rights reserved.
//

#import "BaseViewController.h"
#import "RecentViewController.h"
#import "KeywordViewController.h"
#import "UserViewController.h"
#import "DetailViewController.h"
#import "AppDelegate.h"
#import "PostViewController.h"
#import "ReplyViewController.h"
#import "AuthManager.h"
#import "OAConsumer.h"
#import "OADataFetcher.h"
#import "OAMutableURLRequest.h"

@interface BaseViewController ()

@end

@implementation BaseViewController

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super initWithCoder:decoder];
    if (self) {
        // Custom initialization
        self.page = 1;
        self.statuses = [[NSMutableArray alloc] init];
    }

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationController.navigationBar.tintColor = THEME_COLOR;
    
	// 投稿ボタン配置
	UIBarButtonItem *postButton =
	[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose
												  target:self
												  action:@selector(postButtonAction)];
    self.navigationItem.rightBarButtonItem = postButton;
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refreshOccured:) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
    
    UILongPressGestureRecognizer *longPressRecognizer =
    [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                  action:@selector(longPressAction:)];
    [self.tableView addGestureRecognizer:longPressRecognizer];
}

- (void)viewWillAppear:(BOOL)animated
{
    LOG_CURRENT_METHOD;
    
    [super viewWillAppear:animated];
    
    // 画面戻ってきた時にWebViewがハイライトされてしまうのを防ぐ
    [self.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    LOG_CURRENT_METHOD;
    
    [super viewWillDisappear:animated];
    
    [SVProgressHUD dismiss];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private method

- (void)postButtonAction
{
    [self postButtonActionWithOption:nil];
}

- (void)postButtonActionWithOption:(NSDictionary *)option
{
    if ([[AuthManager sharedManager] isAuthenticated])
    {
        PostViewController *viewController = [[PostViewController alloc] initWithStyle:UITableViewStylePlain];
        viewController.option = option;
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
        navigationController.toolbar.tintColor = THEME_COLOR;
        [self presentViewController:navigationController animated:YES completion:nil];
    }
    else {
        UIAlertView *alert =
        [[UIAlertView alloc] initWithTitle:nil
                                   message:NO_LOGIN_MESSAGE
                                  delegate:self
                         cancelButtonTitle:@"キャンセル"
                         otherButtonTitles:@"ログイン", nil];
        [alert show];
    }
}

- (void)longPressAction:(UILongPressGestureRecognizer *)gestureRecognizer
{
    CGPoint point = [gestureRecognizer locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:point];
    
    if (indexPath == nil)
    {
        return;
    }
    
    // セルが長押しされた場合の処理
    if (((UILongPressGestureRecognizer *)gestureRecognizer).state == UIGestureRecognizerStateBegan)
    {
        // タップされたセルの情報を記憶
        self.selectedStatusDic = (indexPath.section == 0) ? (self.statuses)[indexPath.row] : (self.replies)[indexPath.row];

        UIActionSheet *sheet = [[UIActionSheet alloc] init];
        sheet.delegate = self;
        
        [sheet addButtonWithTitle:@"スターをつける"];
        [sheet addButtonWithTitle:@"返信"];
        [sheet addButtonWithTitle:@"キャンセル"];
        
        sheet.cancelButtonIndex = 2;
        
        [sheet showInView:[self.view window]];
    }
}

- (void)addStarToStatusId:(NSString *)statusId
{
    LOG_CURRENT_METHOD;
    LOG(@"statusId = %@", statusId);
    
    if (![[AuthManager sharedManager] isAuthenticated])
    {
        UIAlertView *alert =
        [[UIAlertView alloc] initWithTitle:nil
                                   message:NO_LOGIN_MESSAGE
                                  delegate:self
                         cancelButtonTitle:@"キャンセル"
                         otherButtonTitles:@"ログイン", nil];
        [alert show];
        return;
    }
    
    [_haikuManager createFavoritesWithStatusId:statusId];

    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [SVProgressHUD show];
}

- (void)reply
{
    LOG_CURRENT_METHOD;
    
    if (![[AuthManager sharedManager] isAuthenticated])
    {
        UIAlertView *alert =
        [[UIAlertView alloc] initWithTitle:nil
                                   message:NO_LOGIN_MESSAGE
                                  delegate:self
                         cancelButtonTitle:@"キャンセル"
                         otherButtonTitles:@"ログイン", nil];
        [alert show];
        return;
    }

    NSString *statusId = (self.selectedStatusDic)[@"id"];
    NSString *userName = (self.selectedStatusDic)[@"user"][@"name"];
    NSString *html = [self generateHtmlFromStatus:self.selectedStatusDic];
    NSString *profileImageUrl = (self.selectedStatusDic)[@"user"][@"profile_image_url"];
    NSDictionary *option = @{@"in_reply_to_status_id": statusId,
                            @"in_reply_to": userName,
                            @"html": html,
                            @"profile_image_url": profileImageUrl};
    
    ReplyViewController *viewController = [[ReplyViewController alloc] initWithStyle:UITableViewStylePlain];
    viewController.option = option;
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
    navigationController.toolbar.tintColor = THEME_COLOR;
    [self presentViewController:navigationController animated:YES completion:nil];
}

- (void)refreshOccured:(id)sender
{
    LOG_CURRENT_METHOD;
    
    self.page = 1;
}

// HTML生成
- (NSString *)generateHtmlFromStatus:(NSDictionary *)statusDic
{
    // キーワード（リプライのレスポンスにはキーワードがないのでこういう実装になってる）
    NSString *keyword = statusDic[@"keyword"];
    if (keyword == nil) {
        keyword = (self.statuses)[0][@"keyword"];
    }
    
    // スター
    NSString *link = statusDic[@"link"];
    NSString *starHtml = [NSString stringWithFormat:@"<img src='http://s.st-hatena.com/entry.count.image?uri=%@'>", link];

    
    // ヘッダー
    NSString *headerHtml = [NSString stringWithFormat:@"<p><a style='color:#467237;font-weight:bold;text-decoration:none' href='haiku://keyword?%@'>%@</a> %@</p>", keyword, keyword, starHtml];
    
    // 返信先
    NSString *replyToHtml = @"";
    NSString *replyToStatus = statusDic[@"in_reply_to_status_id"];
    NSString *replyToUser = statusDic[@"in_reply_to_user_id"];
    if ([replyToStatus length] > 0) {
        replyToHtml = [NSString stringWithFormat:@"<a style='color:#b36b85' href='haiku://reply?%@'><img src='reply_to.gif'>%@</a><br>", replyToStatus, replyToUser];
    }
    
    // 本文
    //cell.detailTextLabel.text = [statusDic objectForKey:@"html_mobile"];
    NSString *body = statusDic[@"html_mobile"];
    NSString *bodyHtml = [NSString stringWithFormat:@"%@%@", replyToHtml, body];
    
    // 投稿者
    NSString *userId = statusDic[@"user"][@"id"];
    NSString *userName = statusDic[@"user"][@"name"];
    
    // 投稿日時
    //cell.dateTextLabel.text = [statusDic objectForKey:@"created_at"];
    NSString *createdAt = statusDic[@"created_at"];
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"US"]];
	[dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];//2012-12-03T10:01:18Z
	NSDate *date = [dateFormatter dateFromString:createdAt];
	[dateFormatter setDateFormat:@"yyyy/MM/dd HH:mm:ss"];
	createdAt = [dateFormatter stringFromDate:date];
    
    // ソース
    NSString *source = statusDic[@"source"];
    
    // リプライ
    NSString *replies = @"";
    NSArray *replyArray = statusDic[@"replies"];
    for (NSDictionary *replyDic in replyArray) {
        NSString *profileImageUrl = replyDic[@"user"][@"profile_image_url"];
        replies = [replies stringByAppendingFormat:@"<img src='%@' width='16' height='16'>", profileImageUrl];
    }
    
    // フッター
    NSString *footerHtml = [NSString stringWithFormat:@"<p style='font-size:80%%'>by <a style='color:#b36b85' href='haiku://user?%@=%@'>%@</a> %@ from <a style='color:#b36b85' href='haiku://keyword?%@'>%@</a> %@ [<a style='color:#b36b85' href='http://www.hatena.ne.jp/faq/report/haiku?location=%@&target_url=%@&target_label=%@'>report</a>]</p>", userId, userName, userName, createdAt, source, source, replies, link, link, body];
    
    // HTML結合
    NSString *html = [NSString stringWithFormat:@"<div style='' id='contents'>%@%@%@</div>", headerHtml, bodyHtml, footerHtml];
    
    return html;
}

#pragma mark - API Callback

- (void)haikuManager:(HaikuManager *)manager didCreateFavoritesWithData:(NSData *)data error:(NSError *)error
{
    LOG_CURRENT_METHOD;
    LOG(@"data = %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    
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

    if (error == nil)
    {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        [SVProgressHUD showSuccessWithStatus:@"スターをつけました"];

        // スターを反映させるために再読み込み
        [self.tableView reloadData];
    }
    else {
        LOG(@"error = %@", error);
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        [SVProgressHUD showErrorWithStatus:@"スター追加に失敗しました"];
    }
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.statuses count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section)
    {
        case 0:
            return nil;
            break;
            
        case 1:
            return ([self.replies count] > 0) ? @"返信一覧" : nil;
            break;
            
        default:
            break;
    }
    
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    StatusTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    //UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[StatusTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.delegate = self;
    }
    
    // セクションごとに表示する内容が異なる
    NSDictionary *statusDic = (indexPath.section == 0) ? (self.statuses)[indexPath.row] : (self.replies)[indexPath.row];
    
    // プロフィールアイコン
    NSString *profileImageUrlString = statusDic[@"user"][@"profile_image_url"];
    [cell.profileImageView loadImageUrl:[NSURL URLWithString:profileImageUrlString]];
    
    // HTML生成
    NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
    NSURL *baseURL = [NSURL fileURLWithPath:bundlePath];
    NSString *html = [self generateHtmlFromStatus:statusDic];
    [cell.bodyWebView loadHTMLString:html baseURL:baseURL];
    
    return cell;
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *statusDic = (indexPath.section == 0) ? (self.statuses)[indexPath.row] : (self.replies)[indexPath.row];

    NSString *html = [self generateHtmlFromStatus:statusDic];
    //NSString *html = [statusDic objectForKey:@"html_mobile"];
    
    // <a> タグ除去 ※開始タグのみ
    NSRange r;
    while ((r = [html rangeOfString:@"<a [^>]+>" options:NSRegularExpressionSearch]).location != NSNotFound)
        html = [html stringByReplacingCharactersInRange:r withString:@""];
    //LOG(@"stripped html = %@", html);
    
    UIFont *font = [UIFont systemFontOfSize:DEFAULT_FONT_SIZE];
    CGSize size = CGSizeMake(self.view.frame.size.width - 69.0, CGFLOAT_MAX);
    CGRect textRect = [html boundingRectWithSize:size
                                         options:NSStringDrawingUsesLineFragmentOrigin
                                      attributes:@{NSFontAttributeName:font}
                                         context:nil];

    // <br> の数
    NSArray *portions = [html componentsSeparatedByString:@"<br>"];
    NSUInteger brCount = [portions count] - 1;
    
    // <p> の数
    portions = [html componentsSeparatedByString:@"<p>"];
    NSUInteger pCount = [portions count] - 1;
    
    CGFloat textHeight = textRect.size.height + brCount*20 + pCount*20;
    
    return textHeight * 0.8;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DetailViewController *detailViewController = [[DetailViewController alloc] initWithStyle:UITableViewStylePlain];
    
    // セクションごとに動きが異なる
    detailViewController.statusId = (indexPath.section == 0) ? (self.statuses)[indexPath.row][@"id"] : (self.replies)[indexPath.row][@"id"];
    
    [self.navigationController pushViewController:detailViewController animated:YES];
}

#pragma mark - UIScrollViewDelegate

// スクロールが止まったとき
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    LOG_CURRENT_METHOD;
    
    // WebView がおかしくなることがあるので再描画
    [self.tableView reloadData];
}

#pragma mark - UIAlertView delegate

- (void)alertView:(UIAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
//	LOG(@"buttonIndex = %d", buttonIndex);
    
    switch (alertView.tag)
    {
        case 0:
        {
            if (buttonIndex == 1)
            {
                AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                [appDelegate showLoginView];
            }
            break;
        }
    }
}

#pragma mark - UIActionSheet delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
//    LOG(@"buttonIndex %d", buttonIndex);

	if (buttonIndex == actionSheet.cancelButtonIndex)
    {
		LOG(@"pushed Cancel button.");
	}
    
    switch (buttonIndex)
    {
        case 0: // Add star
        {
            [self addStarToStatusId:(self.selectedStatusDic)[@"id"]];
            break;
        }
            
        case 1: // Reply
        {
            [self reply];
            break;
        }
            
        default:
            break;
    }
    
    // WebViewが選択されたままなので再読み込み
    [self.tableView reloadData];
}

#pragma mark - StatusTableViewCellDelegate

-(void)statusViewCell:(StatusTableViewCell *)cell linkDidTap:(NSURL *)url
{
    LOG_CURRENT_METHOD;
    
    LOG(@"url = %@", url);
    LOG(@"scheme = %@", [url scheme]);
    LOG(@"host = %@", [url host]);
    LOG(@"query = %@", [url query]);
    
    if ([url.host isEqualToString:@"keyword"])
    {
        KeywordViewController *viewController = [[KeywordViewController alloc] initWithStyle:UITableViewStylePlain];
        viewController.keyword = url.query;
        [self.navigationController pushViewController:viewController animated:YES];
    }
    else if ([url.host isEqualToString:@"reply"]) {
        DetailViewController *detailViewController = [[DetailViewController alloc] initWithStyle:UITableViewStylePlain];
        detailViewController.statusId = url.query;
        [self.navigationController pushViewController:detailViewController animated:YES];
    }
    else if ([url.host isEqualToString:@"user"]) {
        UserViewController *viewController = [[UserViewController alloc] initWithStyle:UITableViewStylePlain];
        viewController.userId = [url.query componentsSeparatedByString:@"="][0];
        viewController.userName = [[url.query componentsSeparatedByString:@"="] lastObject];
        [self.navigationController pushViewController:viewController animated:YES];
    }
    else {
        // アプリ内ブラウザで開く
        SFSafariViewController *safariViewController = [[SFSafariViewController alloc] initWithURL:url];
        [self presentViewController:safariViewController animated:YES completion:nil];
    }
}

@end
