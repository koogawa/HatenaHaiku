//
//  MyFriendViewController.m
//  HatenaHaiku
//
//  Created by koogawa on 2013/03/17.
//  Copyright (c) 2013年 Kosuke Ogawa. All rights reserved.
//

#import "MyFriendViewController.h"
#import "UserViewController.h"
#import "AppDelegate.h"
#import "AuthManager.h"
#import "OAConsumer.h"
#import "OADataFetcher.h"
#import "OAMutableURLRequest.h"

@interface MyFriendViewController ()

@end

@implementation MyFriendViewController

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
    
    self.title = @"お気に入りユーザ";

    _haikuManager = [HaikuManager sharedManager];
    _haikuManager.delegate = self;

    [self fetchFriends];
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
    
    [self fetchFriends];
}

// キーワードのエントリーを取得
- (void)fetchFriends
{
    LOG_CURRENT_METHOD;

    [_haikuManager fetchFriendsWithPage:self.page];
}


#pragma mark - Override method

- (void)loadMore
{
    LOG_CURRENT_METHOD;
    
    [self fetchFriends];
}


#pragma mark - HaikuManager delegate

// エントリーが取れた
- (void)haikuManager:(HaikuManager *)manager didFetchFriendsWithData:(NSData *)data error:(NSError *)error
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
        return;
    }

    NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    //LOG(@"statuses %@", jsonArray);
    
    if ([jsonArray count] == 0)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                        message:@"これ以上データがありません"
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


#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        
        // プロフィールアイコン
        cell.imageView.image = [UIImage imageNamed:@"none.gif"]; // dummy
        AsyncImageView *profileImageView = [[AsyncImageView alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
        profileImageView.backgroundColor = [UIColor whiteColor];
        profileImageView.tag = 101;
        [cell.contentView addSubview:profileImageView];
    }
    
    // プロフィールアイコン
    AsyncImageView *profileImageView = (AsyncImageView *)[cell.contentView viewWithTag:101];
    NSDictionary *statusDic = (self.statuses)[indexPath.row];
    NSURL *profileImageURL = [NSURL URLWithString:statusDic[@"profile_image_url"]];
    [profileImageView loadImageUrl:profileImageURL];
    
    // 名前
    cell.textLabel.text = statusDic[@"name"];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"id:%@", statusDic[@"id"]];
    
    return cell;
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UserViewController *viewController = [[UserViewController alloc] initWithStyle:UITableViewStylePlain];
    NSDictionary *statusDic = (self.statuses)[indexPath.row];
    viewController.userId = statusDic[@"id"];
    viewController.userName = statusDic[@"name"];
    [self.navigationController pushViewController:viewController animated:YES];
}

@end
