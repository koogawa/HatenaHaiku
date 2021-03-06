//
//  MyPageViewController.m
//  HatenaHaiku
//
//  Created by koogawa on 2012/12/09.
//  Copyright (c) 2012年 Kosuke Ogawa. All rights reserved.
//

#import "MyPageViewController.h"
#import "AntennaViewController.h"
#import "MyViewController.h"
#import "MyFriendViewController.h"
#import "MyKeywordViewController.h"
#import "MyFollowerViewController.h"
#import "SettingsViewController.h"
#import "KeywordViewController.h"
#import "PostViewController.h"
#import "AppDelegate.h"
#import "AuthManager.h"
#import "User.h"
#import "OAConsumer.h"
#import "OADataFetcher.h"
#import "OAMutableURLRequest.h"

@interface MyPageViewController ()

@end

@implementation MyPageViewController
{
    User *_user;
    HaikuManager *_haikuManager;
}

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super initWithCoder:decoder];
    if (self) {
        // Custom initialization
    }

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBar.tintColor = THEME_COLOR;
    
    // 設定ボタン配置
    UIBarButtonItem *settingsButton =
    [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"gear.png"]
                                     style:UIBarButtonItemStylePlain
                                    target:self
                                    action:@selector(settingsButtonAction)];
    self.navigationItem.leftBarButtonItem = settingsButton;
    
	// 投稿ボタン配置
	UIBarButtonItem *postButton =
	[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose
												  target:self
												  action:@selector(postButtonAction)];
    self.navigationItem.rightBarButtonItem = postButton;
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refreshOccured:) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;

    _haikuManager = [[HaikuManager alloc] init];
    _haikuManager.delegate = self;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // ログインしてたらヘッダー作成
    if ([[AuthManager sharedManager] isAuthenticated])
    {
        if (self.tableView.tableHeaderView == nil) {
            [self fetchProfile];
        }
    }
    else {
        self.tableView.tableHeaderView = nil;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private method

- (void)makeHeaderView
{
    LOG_CURRENT_METHOD;

    CGFloat width = self.view.frame.size.width;
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, 84)];
    
    // プロフィール画像
    AsyncImageView *profileView = [[AsyncImageView alloc] initWithFrame:CGRectMake(20, 20, 64, 64)];
    [headerView addSubview:profileView];
    [profileView loadImageUrl:_user.profileImageURL];
    
    // 表示名
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(94, 20, width - 104, 28)];
    nameLabel.backgroundColor = [UIColor clearColor];
    nameLabel.font = [UIFont boldSystemFontOfSize:20];
    nameLabel.text = [NSString stringWithFormat:@"%@のはてなハイク", _user.name];
    nameLabel.adjustsFontSizeToFitWidth = YES;
    [headerView addSubview:nameLabel];
    
    // はてなID
    UILabel *idLabel = [[UILabel alloc] initWithFrame:CGRectMake(94, 48, width - 94, 18)];
    idLabel.backgroundColor = [UIColor clearColor];
    idLabel.font = [UIFont systemFontOfSize:14];
    idLabel.text = [NSString stringWithFormat:@"id:%@", _user.userId];
    [headerView addSubview:idLabel];
    
    // fans
    UILabel *fanLabel = [[UILabel alloc] initWithFrame:CGRectMake(94, 66, width - 94, 18)];
    fanLabel.backgroundColor = [UIColor clearColor];
    fanLabel.font = [UIFont systemFontOfSize:14];
    fanLabel.text = [NSString stringWithFormat:@"%@ fans", _user.followersCount];
    [headerView addSubview:fanLabel];
    
    self.tableView.tableHeaderView = headerView;
}

- (void)refreshOccured:(id)sender
{
    LOG_CURRENT_METHOD;
    
    // ログインしてたらヘッダー作成
    if ([[AuthManager sharedManager] isAuthenticated])
    {
        [self fetchProfile];
    }
    else {
        [self.refreshControl endRefreshing];
        self.tableView.tableHeaderView = nil;
    }
}

- (void)postButtonAction
{
    [self postButtonActionWithOption:nil];
}

- (void)settingsButtonAction
{
    SettingsViewController *viewController = [[SettingsViewController alloc] initWithStyle:UITableViewStyleGrouped];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
    navigationController.navigationBar.tintColor = THEME_COLOR;
//    navigationController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:navigationController animated:YES completion:nil];
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
    }
}

- (void)fetchProfile
{
    LOG_CURRENT_METHOD;

    [_haikuManager fetchFriendships];

    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [SVProgressHUD show];
}


#pragma mark - Haiku Manager delegate

- (void)haikuManager:(HaikuManager *)manager didFetchFriendshipsWithData:(NSData *)data error:(NSError *)error
{
    LOG_CURRENT_METHOD;
    LOG(@"data = %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [SVProgressHUD dismiss];
    [self.refreshControl endRefreshing];

    // トークン切れチェック
    NSString *response = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if ([response isEqualToString:@"oauth_problem=token_rejected"])
    {
        // 何もせぇへん
        return;
    }
    
    // 権限がない場合はライブラリの仕様で oauth_problem=nonce_used になる
    if ([response isEqualToString:@"oauth_problem=nonce_used"])
    {
        // 何もせぇへん
        return;
    }

    if (error != nil)
    {
        LOG(@"error = %@", error);

        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        [SVProgressHUD showErrorWithStatus:@"取得できませんでした"];
        [self.refreshControl endRefreshing];
        return;
    }

    NSDictionary *userInfo = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    _user = [[User alloc] initWithJSONDictionary:userInfo];

    [self makeHeaderView];
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
            return 2;
            break;
            
        default:
            return 3;
            break;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section)
    {
        case 0:
            return @"エントリー";
            break;
            
        case 1:
            return @"プロフィール";
            break;
            
        default:
            break;
    }
    
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }
    
    switch (indexPath.section)
    {
        case 0:
        {
            switch (indexPath.row)
            {
                case 0:
                {
                    cell.textLabel.text = @"アンテナ";
                    cell.detailTextLabel.text = @"お気に入りの新着投稿一覧";
                    break;
                }
                    
                case 1:
                {
                    cell.textLabel.text = @"エントリー";
                    cell.detailTextLabel.text = @"自分の最新投稿一覧";
                    break;
                }
                    
                default:
                    break;
            }
            
            break;
        }
            
        case 1:
        {
            switch (indexPath.row)
            {
                case 0:
                {
                    cell.textLabel.text = @"お気に入りユーザ";
                    break;
                }
                    
                case 1:
                {
                    cell.textLabel.text = @"お気に入りキーワード";
                    break;
                }
                    
                case 2:
                {
                    cell.textLabel.text = @"ファン";
                    break;
                }
                    
                default:
                    break;
            }
            
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

    switch (indexPath.section)
    {
        case 0:
        {
            switch (indexPath.row)
            {
                case 0:
                {
                    AntennaViewController *viewController = [[AntennaViewController alloc] initWithStyle:UITableViewStylePlain];
                    [self.navigationController pushViewController:viewController animated:YES];
                    break;
                }
                    
                case 1:
                {
                    MyViewController *viewController = [[MyViewController alloc] initWithStyle:UITableViewStylePlain];
                    [self.navigationController pushViewController:viewController animated:YES];
                    break;
                }
                    
                default:
                    break;
            }
            
            break;
        }
            
        case 1:
        {
            switch (indexPath.row)
            {
                case 0:
                {
                    MyFriendViewController *viewController = [[MyFriendViewController alloc] initWithStyle:UITableViewStylePlain];
                    [self.navigationController pushViewController:viewController animated:YES];
                    break;
                }
                    
                case 1:
                {
                    MyKeywordViewController *viewController = [[MyKeywordViewController alloc] initWithStyle:UITableViewStylePlain];
                    [self.navigationController pushViewController:viewController animated:YES];
                    break;
                }
                    
                case 2:
                {
                    MyFollowerViewController *viewController = [[MyFollowerViewController alloc] initWithStyle:UITableViewStylePlain];
                    [self.navigationController pushViewController:viewController animated:YES];
                    break;
                }
                    
                default:
                    break;
            }
            
            break;
        }
            
        default:
            break;
    }
}

@end
