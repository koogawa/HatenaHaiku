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

    self.navigationItem.rightBarButtonItems = @[replyButton, starButton];

    _haikuManager = [[HaikuManager alloc] init];
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
    NSDictionary *option = @{@"in_reply_to_status_id": self.statusId,
                            @"in_reply_to": self.userName};
    [self postButtonActionWithOption:option];
}

- (void)replyButtonAction
{
    LOG_CURRENT_METHOD;
    
    if (![[AuthManager sharedManager] isAuthenticated])
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil
                                                                                 message:NO_LOGIN_MESSAGE
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:CANCEL_BUTTON_TITLE
                                                            style:UIAlertActionStyleCancel
                                                          handler:nil]];
        [alertController addAction:[UIAlertAction actionWithTitle:LOGIN_BUTTON_TITLE
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction *action)
                                    {
                                        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                                        [appDelegate showLoginView];
                                    }]];
        [self presentViewController:alertController
                           animated:YES
                         completion:nil];
        return;
    }
    
    NSDictionary *status = (self.statuses)[0];
    NSString *statusId = status[@"id"];
    NSString *userName = status[@"user"][@"name"];
    NSString *html = [self generateHtmlFromStatus:status];
    NSString *profileImageUrl = status[@"user"][@"profile_image_url"];
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

- (void)starButtonAction
{
    LOG_CURRENT_METHOD;

    // ログインされてない
    if (![[AuthManager sharedManager] isAuthenticated])
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil
                                                                                 message:NO_LOGIN_MESSAGE
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:CANCEL_BUTTON_TITLE
                                                            style:UIAlertActionStyleCancel
                                                          handler:nil]];
        [alertController addAction:[UIAlertAction actionWithTitle:LOGIN_BUTTON_TITLE
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction *action)
                                    {
                                        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                                        [appDelegate showLoginView];
                                    }]];
        [self presentViewController:alertController
                           animated:YES
                         completion:nil];
        return;
    }

    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [SVProgressHUD show];

    [_haikuManager createFavoritesWithStatusId:self.statusId];
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

    [_haikuManager fetchStatusDetailWithEid:self.statusId];
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
        self.replies = statusDic[@"replies"];
        
        self.title = statusDic[@"keyword"];
        self.userId = statusDic[@"user"][@"id"];
        self.userName = statusDic[@"user"][@"name"];
        
        [self.tableView reloadData];
    }
    else {
        UIAlertController *alertController =
        [UIAlertController alertControllerWithTitle:ERROR_TITLE
                                            message:FETCH_ERROR_MESSAGE
                                     preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:OK_BUTTON_TITLE
                                                            style:UIAlertActionStyleCancel
                                                          handler:nil]];
        [self presentViewController:alertController
                           animated:YES
                         completion:nil];
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
