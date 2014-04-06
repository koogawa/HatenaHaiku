//
//  HotKeywordViewController.m
//  HatenaHaiku
//
//  Created by koogawa on 2012/12/09.
//  Copyright (c) 2012年 Kosuke Ogawa. All rights reserved.
//

#import "HotKeywordViewController.h"
#import "AppDelegate.h"
#import "KeywordViewController.h"
#import "PostViewController.h"
#import "AuthManager.h"

@interface HotKeywordViewController ()

@end

@implementation HotKeywordViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        self.title = @"キーワード";
        self.tabBarItem.image = [UIImage imageNamed:@"keyword.png"];
        self.keywords = [[NSMutableArray alloc] init];
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
    NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
    attributes[NSBackgroundColorAttributeName] = [UIColor blueColor];
    attributes[NSForegroundColorAttributeName] = [UIColor whiteColor];
    [refreshControl addTarget:self action:@selector(refreshOccured:) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
    
    UISearchBar *searchBar = [[UISearchBar alloc] init];
    searchBar.delegate = self;
    searchBar.frame = CGRectMake(0, 0, self.tableView.bounds.size.width, 0);
    searchBar.tintColor = THEME_COLOR;
    [searchBar sizeToFit];
    self.tableView.tableHeaderView = searchBar;

    self.searchDisplay = [[UISearchDisplayController alloc] initWithSearchBar:searchBar contentsController:self];
    self.searchDisplay.delegate = self;
    self.searchDisplay.searchResultsDataSource = self;
    self.searchDisplay.searchResultsDelegate = self;

    _haikuManager = [[HaikuManager alloc] init];
    _haikuManager.delegate = self;

    [self fetchHotKeywords];
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

- (void)refreshOccured:(id)sender
{
    LOG_CURRENT_METHOD;
    
    [self fetchHotKeywords];
}

// ホットキーワード一覧を取得
- (void)fetchHotKeywords
{
    LOG_CURRENT_METHOD;

    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [SVProgressHUD show];

    [_haikuManager fetchHotKeywords];
}

// キーワード検索
- (void)searchKeywordsWithKeyword:(NSString *)keyword
{
    LOG_CURRENT_METHOD;
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [SVProgressHUD show];
    
    [_haikuManager searchKeywordsWithKeyword:keyword];
}


#pragma mark - HaikuManager delegate

// ホットキーワードが取得できた
- (void)haikuManager:(HaikuManager *)manager didFetchHotKeywordsWithData:(NSData *)data error:(NSError *)error
{
    LOG_CURRENT_METHOD;
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [SVProgressHUD dismiss];
    
    [self.refreshControl endRefreshing];

    if (error == nil)
    {
        NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        
        // 結果取得
        [self.keywords removeAllObjects];
        self.keywords = [NSMutableArray arrayWithArray:jsonArray];
        
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

// 検索したキーワードが取得できた
- (void)haikuManager:(HaikuManager *)manager didSearchKeywordsWithData:(NSData *)data error:(NSError *)error
{
    LOG_CURRENT_METHOD;
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [SVProgressHUD dismiss];
    
    [self.refreshControl endRefreshing];
	
    if (error == nil)
    {
        NSData *jsonData = data;
        
        NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
        
        // 結果取得
        [self.keywords removeAllObjects];
        self.keywords = [NSMutableArray arrayWithArray:jsonArray];
        
        [self.searchDisplayController.searchResultsTableView reloadData];
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


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.keywords count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }

    // detailTextLabel に被らないように文字数調整
    NSString *keyword = (self.keywords)[indexPath.row][@"title"];
    NSInteger length = [keyword length];
    NSInteger minLength = 12;
    NSRange stringRange = {0, MIN(length, minLength)};
    stringRange = [keyword rangeOfComposedCharacterSequencesForRange:stringRange];
    keyword = [keyword substringWithRange:stringRange];
    if (length > minLength) keyword = [keyword stringByAppendingString:@"…"];
    
    cell.textLabel.text = keyword;
    cell.detailTextLabel.text = (self.keywords)[indexPath.row][@"entry_count"];
    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    KeywordViewController *viewController = [[KeywordViewController alloc] initWithStyle:UITableViewStylePlain];
    viewController.keyword = [(self.keywords)[indexPath.row][@"word"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
;
    [self.navigationController pushViewController:viewController animated:YES];
}


#pragma mark - UISearchBar delegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    LOG_CURRENT_METHOD;
    LOG(@"searchString = %@", searchBar.text);
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    if (![searchBar.text length]) {
        return;
    }
    
    // 検索
    [self searchKeywordsWithKeyword:searchBar.text];
}

#pragma mark - UISearchDisplayController Delegate

// 検索モード開始時（検索バーがタップされたとき）に呼ばれる
- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller
{
    LOG_CURRENT_METHOD;
    
    // 非検索モードのリストを退避
    self.tmpKeywords = [NSMutableArray arrayWithArray:self.keywords];
}

// 検索モード完了時（キャンセルボタンが押されたとき）に呼ばれる
- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller
{
    LOG_CURRENT_METHOD;
    
    // 非検索モードのリストを復帰
    self.keywords = [NSMutableArray arrayWithArray:self.tmpKeywords];
}

// 何か入力される度に呼ばれる
/*
- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    LOG(@"searchString = %@", searchString);
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    if (![searchString length]) {
        return NO;
    }
    
    // 2秒後に検索
    [self performSelector:@selector(searchKeywordsWithKeyword:) withObject:searchString afterDelay:2.0];
    
    return NO;
}
*/

#pragma mark - UIAlertView delegate

- (void)alertView:(UIAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	LOG(@"buttonIndex = %d", buttonIndex);
    
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

@end
