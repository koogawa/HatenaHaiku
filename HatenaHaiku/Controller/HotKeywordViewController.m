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
@property (strong, nonatomic) UISearchController *searchController;
@end

@implementation HotKeywordViewController

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super initWithCoder:decoder];
    if (self) {
        // Custom initialization
        self.keywords = [[NSMutableArray alloc] init];
    }

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // YESにしないと検索結果から遷移しても検索バーが残ってしまう
    self.definesPresentationContext = YES;
    
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

    UISearchController *searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    searchController.delegate = self;
    searchController.searchResultsUpdater = self;
    searchController.hidesNavigationBarDuringPresentation = NO;
    searchController.dimsBackgroundDuringPresentation = NO;
    searchController.searchBar.searchBarStyle = UISearchBarStyleProminent;
    searchController.searchBar.delegate = self;
    searchController.searchBar.tintColor = THEME_COLOR;
    [searchController.searchBar sizeToFit];
    self.tableView.tableHeaderView = searchController.searchBar;
    self.searchController = searchController;

    _haikuManager = [[HaikuManager alloc] init];
    _haikuManager.delegate = self;

    [self performSelector:@selector(fetchHotKeywordsAtFirst) withObject:nil afterDelay:0.1];
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

- (void)refreshOccured:(id)sender
{
    LOG_CURRENT_METHOD;

    if (self.searchController.active) {
        [self searchKeywordsWithKeyword:self.searchController.searchBar.text];
    }
    else {
        [self fetchHotKeywords];
    }
}

- (void)fetchHotKeywordsAtFirst
{
    LOG_CURRENT_METHOD;

    [SVProgressHUD show];
    [self fetchHotKeywords];
}

// ホットキーワード一覧を取得
- (void)fetchHotKeywords
{
    LOG_CURRENT_METHOD;

    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;

    [_haikuManager fetchHotKeywords];
}

// キーワード検索
- (void)searchKeywordsWithKeyword:(NSString *)keyword
{
    LOG_CURRENT_METHOD;

    if (!keyword.length) {
        return;
    }

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
    viewController.keyword = [(self.keywords)[indexPath.row][@"word"] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet alphanumericCharacterSet]];
    [self.navigationController pushViewController:viewController animated:YES];
}


#pragma mark - UISearchResultsUpdating

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    // UISearchController に何かするたびに呼ばれるっぽい
}

#pragma mark - UISearchBar delegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    LOG_CURRENT_METHOD;
    LOG(@"searchString = %@", searchBar.text);

    if (![searchBar.text length]) {
        return;
    }
    
    // 検索
    [self searchKeywordsWithKeyword:searchBar.text];
}

#pragma mark - UISearchController Delegate

// 検索モード開始時（検索バーにフォーカスが当たった時）に呼ばれる
- (void)willPresentSearchController:(UISearchController *)searchController
{
    LOG_CURRENT_METHOD;
    
    // 非検索モードのリストを退避
    self.tmpKeywords = [NSMutableArray arrayWithArray:self.keywords];
}

// 検索モード完了時（キャンセルボタンが押されたとき）に呼ばれる
- (void)willDismissSearchController:(UISearchController *)searchController
{
    LOG_CURRENT_METHOD;
    
    // 非検索モードのリストを復帰
    self.keywords = [NSMutableArray arrayWithArray:self.tmpKeywords];

    [self.tableView reloadData];
}

@end
