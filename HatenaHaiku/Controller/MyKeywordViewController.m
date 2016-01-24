//
//  MyKeywordViewController.m
//  HatenaHaiku
//
//  Created by koogawa on 2013/03/18.
//  Copyright (c) 2013年 Kosuke Ogawa. All rights reserved.
//

#import "MyKeywordViewController.h"
#import "KeywordViewController.h"
#import "AppDelegate.h"
#import "AuthManager.h"
#import "OAConsumer.h"
#import "OADataFetcher.h"
#import "OAMutableURLRequest.h"

@interface MyKeywordViewController ()

@end

@implementation MyKeywordViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        self.title = @"お気に入りキーワード";
        self.moreLoadEnabled = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    _haikuManager = [[HaikuManager alloc] init];
    _haikuManager.delegate = self;

    [SVProgressHUD show];
    [self fetchKeywords];
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
    
    [self fetchKeywords];
}

// お気に入りキーワード一覧を取得
- (void)fetchKeywords
{
    LOG_CURRENT_METHOD;

    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;

    [_haikuManager fetchKeywordsWithPage:self.page
                  withoutRelatedKeywords:YES];
}


#pragma mark - Override method

- (void)loadMore
{
    LOG_CURRENT_METHOD;
    
    [self fetchKeywords];
}


#pragma mark - API Callback

// お気に入りキーワード一覧が取れた
- (void)haikuManager:(HaikuManager *)manager didFetchKeywordsWithData:(NSData *)data error:(NSError *)error
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
        UIAlertController *alertController =
        [UIAlertController alertControllerWithTitle:ERROR_TITLE
                                            message:NO_DATA_MESSAGE
                                     preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:OK_BUTTON_TITLE
                                                            style:UIAlertActionStyleCancel
                                                          handler:nil]];
        [self presentViewController:alertController
                           animated:YES
                         completion:nil];
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
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }
    
    NSDictionary *statusDic = (self.statuses)[indexPath.row];
    
    // detailTextLabel に被らないように文字数調整
    NSString *keyword = statusDic[@"title"];
    NSInteger length = [keyword length];
    NSInteger minLength = 12;
    NSRange stringRange = {0, MIN(length, minLength)};
    stringRange = [keyword rangeOfComposedCharacterSequencesForRange:stringRange];
    keyword = [keyword substringWithRange:stringRange];
    if (length > minLength) keyword = [keyword stringByAppendingString:@"…"];
    
    cell.textLabel.text = keyword;
    cell.detailTextLabel.text = statusDic[@"entry_count"];
    
    return cell;
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    KeywordViewController *viewController = [[KeywordViewController alloc] initWithStyle:UITableViewStylePlain];
    viewController.keyword = [(self.statuses)[indexPath.row][@"word"] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet alphanumericCharacterSet]];
    [self.navigationController pushViewController:viewController animated:YES];
}

@end
