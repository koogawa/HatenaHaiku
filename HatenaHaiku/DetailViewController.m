//
//  DetailViewController.m
//  HatenaHaiku
//
//  Created by koogawa on 2012/12/08.
//  Copyright (c) 2012年 Kosuke Ogawa. All rights reserved.
//

#import "DetailViewController.h"
#import "ReplyViewController.h"
#import "AppDelegate.h"
#import "AuthManager.h"
#import "OAConsumer.h"
#import "OADataFetcher.h"
#import "OAMutableURLRequest.h"

@interface DetailViewController ()

@end

@implementation DetailViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        self.moreLoadEnabled = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // 返信ボタン配置
	UIBarButtonItem *replyButton =
	[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemReply
												  target:self
												  action:@selector(replyButtonAction)];
    
    // スターボタン配置
	UIBarButtonItem *starButton =
    [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"star.png"]
                                     style:UIBarButtonItemStylePlain
                                    target:self
                                    action:@selector(starButtonAction)];

    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:replyButton, starButton, nil];

    _haikuManager = [HaikuManager sharedManager];
    _haikuManager.delegate = self;

    [self fetchStatusDetail];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private method

- (void)postButtonAction
{
    NSDictionary *option = [[NSDictionary alloc] initWithObjectsAndKeys:
                            self.statusId, @"in_reply_to_status_id",
                            self.userName, @"in_reply_to",
                            nil];
    [self postButtonActionWithOption:option];
}

- (void)replyButtonAction
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
    
    NSDictionary *status = [self.statuses objectAtIndex:0];
    NSString *statusId = [status objectForKey:@"id"];
    NSString *userName = [[status objectForKey:@"user"] objectForKey:@"name"];
    NSString *html = [self generateHtmlFromStatus:status];
    NSString *profileImageUrl = [[status objectForKey:@"user"] objectForKey:@"profile_image_url"];
    NSDictionary *option = [[NSDictionary alloc] initWithObjectsAndKeys:
                            statusId,           @"in_reply_to_status_id",
                            userName,           @"in_reply_to",
                            html,               @"html",
                            profileImageUrl,    @"profile_image_url",
                            nil];
    
    ReplyViewController *viewController = [[ReplyViewController alloc] initWithStyle:UITableViewStylePlain];
    viewController.option = option;
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
    navigationController.toolbar.tintColor = THEME_COLOR;
    [self presentViewController:navigationController animated:YES completion:nil];
}

- (void)starButtonAction
{
    LOG_CURRENT_METHOD;

    // ログインされてない
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

    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [SVProgressHUD show];

    [_haikuManager createFavoritesWithStatusId:self.statusId];
    return;
    OAConsumer *consumer = [[OAConsumer alloc] initWithKey:OAUTH_CONSUMER_KEY
                                                    secret:OAUTH_CONSUMER_SECRET];
    
    OAToken *accessToken = [[OAToken alloc] initWithKey:[[AuthManager sharedManager] accessToken]
                                                 secret:[[AuthManager sharedManager] accessTokenSecret]];
    
    NSString *urlString = [NSString stringWithFormat:@"http://h.hatena.ne.jp/api/favorites/create/%@.json", self.statusId];
    NSURL *url = [NSURL URLWithString:urlString];
    LOG(@"urlString = %@", urlString);
    
    OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:url
                                                                   consumer:consumer
                                                                      token:accessToken
                                                                      realm:nil
                                                          signatureProvider:nil];
    [request setHTTPMethod:@"POST"];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [SVProgressHUD show];
    
    OADataFetcher *fetcher = [[OADataFetcher alloc] init];
    [fetcher fetchDataWithRequest:request
                         delegate:self
                didFinishSelector:@selector(ticket:didFinishWithData:)
                  didFailSelector:@selector(ticket:didFailWithError:)];
}

- (void)refreshOccured:(id)sender
{
    LOG_CURRENT_METHOD;
    
    [self fetchStatusDetail];
}

// 投稿詳細を取得
- (void)fetchStatusDetail
{
    LOG_CURRENT_METHOD;
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [SVProgressHUD show];

    [[HaikuManager sharedManager] fetchStatusDetailWithEid:self.statusId];
}

#pragma mark - HaikuManager delegate

- (void)haikuManager:(HaikuManager *)manager didFetchStatusDetailWithData:(NSData *)data error:(NSError *)error
{
    LOG_CURRENT_METHOD;
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [SVProgressHUD dismiss];
    
    [self.refreshControl endRefreshing];
	
    if (error == nil)
    {
        NSData *jsonData = data;
        
        // 結果取得
        NSDictionary *statusDic = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
        [self.statuses removeAllObjects];
        [self.statuses addObject:statusDic];
        self.replies = [statusDic objectForKey:@"replies"];
        
        self.title = [statusDic objectForKey:@"keyword"];
        self.userId = [[statusDic objectForKey:@"user"] objectForKey:@"id"];
        self.userName = [[statusDic objectForKey:@"user"] objectForKey:@"name"];
        
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

        // ちょっと時間開けないとサクセスメッセージが出ない
        [self performSelector:@selector(fetchStatusDetail) withObject:nil afterDelay:1.0];
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
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    switch (section)
    {
        case 0:
            return [self.statuses count];
            break;

        case 1:
            return [self.replies count];
            break;
            
        default:
            break;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    
    switch (indexPath.section)
    {
        case 0:
        {
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            break;
        }
            
        // 返信一覧
        case 1:
        {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
            break;
        }
            
        default:
            break;
    }
    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section)
    {
        case 0:
        {
            // なにもしない
            break;
        }
            
            // 返信一覧
        case 1:
        {
            [super tableView:tableView didSelectRowAtIndexPath:indexPath];
            break;
        }
            
        default:
            break;
    }
}

@end
