//
//  WebViewController.m
//
//  Created by koogawa on 10/11/17.
//  Copyright 2010 Kosuke Ogawa All rights reserved.
//

#import "WebViewController.h"

@implementation WebViewController

#pragma mark -
#pragma mark initialize

- (id)initWithURL:(NSURL *)url
{
	if (self = [super init]) {
		self.url = url;
        self.navigationBarHidden = YES;
        self.toolbarHidden = NO;
	}
	return self;
}

- (id)initWithPath:(NSString *)path
{
	if (self = [super init]) {
		self.path = path;
        self.navigationBarHidden = YES;
        self.toolbarHidden = NO;
	}
	return self;
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad
{
	[super viewDidLoad];
    
    self.navigationController.navigationBarHidden = self.navigationBarHidden;
    self.navigationController.toolbarHidden = self.toolbarHidden;
	
    // UIWebViewの設定
	self.webView = [[UIWebView alloc] init];
	self.webView.delegate = self;
	self.webView.frame = self.view.bounds;
	self.webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	self.webView.scalesPageToFit = YES;
	[self.view addSubview:self.webView];

	// ナビゲーションバーにボタンを追加
	UIBarButtonItem *closeButton =
    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                  target:self
                                                  action:@selector(closeButtonAction)];
	// ツールバーの設定
	self.backButton =
    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:101
                                                  target:self
                                                  action:@selector(backDidPush)];
	self.forwardButton =
    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:102
                                                  target:self
                                                  action:@selector(forwardDidPush)];
	self.reloadButton =
    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                  target:self
                                                  action:@selector(reloadDidPush)];
	self.reloadButton.tag = 101;
	self.stopButton =
    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop
                                                  target:self
                                                  action:@selector(stopDidPush)];
	self.stopButton.tag = 102;
	UIBarButtonItem* adjustment =
    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                  target:nil
                                                  action:nil];
	UIBarButtonItem *actionButton =
    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                                  target:self
                                                  action:@selector(actionButtonAction)];
	NSArray *buttons =
    @[self.reloadButton, adjustment, self.backButton, adjustment, self.forwardButton, adjustment, actionButton, adjustment, closeButton];
	[self setToolbarItems:buttons animated:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	if (self.url != nil)
    {
		NSURLRequest *request = [NSURLRequest requestWithURL:self.url];
		[self.webView loadRequest:request];
        [SVProgressHUD showProgress:0.33];
	}
    else if (self.path) {
		NSString *path = [[NSBundle mainBundle] pathForResource:self.path ofType:nil];
		if (path) {
			NSData *data = [NSData dataWithContentsOfFile:path];
			[self.webView loadData:data MIMEType:@"text/html" textEncodingName:@"UTF-8" baseURL:[NSURL new]];
		} else {
			LOG(@"file not found.");
		}
	}
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
    
	// 画面を閉じるときにステータスバーのインジケータを確実にOFFにしておく
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [SVProgressHUD dismiss];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}


#pragma mark -
#pragma mark Private Methods

// ページの再読み込み
- (void)reloadDidPush
{
	[self.webView reload];
}

// 読み込み中止
- (void)stopDidPush
{
	if (self.webView.loading) {
		[self.webView stopLoading];
	} 
}

// 前のページに戻る
- (void)backDidPush
{
	if (self.webView.canGoBack) {
		[self.webView goBack];
	} 
}

// 次のページに進む
- (void)forwardDidPush
{
	if (self.webView.canGoForward) {
		[self.webView goForward];
	} 
}

- (void)replaceButtonWithTag:(NSInteger)tag withItem:(UIBarButtonItem *)item
{
	NSInteger index = 0;
    
	for (UIBarButtonItem *button in self.navigationController.toolbar.items)
    {
		if (button.tag == tag)
        {
			NSMutableArray *newItems = [NSMutableArray arrayWithArray:self.navigationController.toolbar.items];
			newItems[index] = item;
			self.navigationController.toolbar.items = newItems;
			break;
		}
		++index;
	}
}

// インジケータやボタンの状態を一括で更新する
- (void)updateControlEnabled
{
	[UIApplication sharedApplication].networkActivityIndicatorVisible = self.webView.loading;
	
	if (self.webView.loading)
    {
		[self replaceButtonWithTag:101 withItem:self.stopButton];
        [SVProgressHUD showProgress:0.66];
	}
    else {
		[self replaceButtonWithTag:102 withItem:self.reloadButton];
        [SVProgressHUD showProgress:1.0];
        [SVProgressHUD dismiss];
	}

	self.stopButton.enabled = self.webView.loading;
	self.backButton.enabled = self.webView.canGoBack;
	self.forwardButton.enabled = self.webView.canGoForward;
}

- (void)closeButtonAction
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)actionButtonAction
{
	UIActionSheet* sheet = [[UIActionSheet alloc] init];
	sheet.delegate = self;
	[sheet addButtonWithTitle:@"Safari で開く"];
	[sheet addButtonWithTitle:@"キャンセル"];
	sheet.cancelButtonIndex = 1;
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
		// for iPhone
		[sheet showInView:[self.view window]];
	} else {
		// for iPad
		[sheet showInView:self.view];
	}
}


#pragma mark -
#pragma mark UIWebView delegate

- (void)webViewDidStartLoad:(UIWebView*)webView {
	[self updateControlEnabled];
}

- (void)webViewDidFinishLoad:(UIWebView*)webView {
	[self updateControlEnabled];
}

- (void)webView:(UIWebView*)webView didFailLoadWithError:(NSError*)error {
	[self updateControlEnabled];
}


#pragma mark -
#pragma mark UIActionSheet delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == actionSheet.cancelButtonIndex)
    {
		LOG(@"pushed Cancel button.");
	}
    else {
		[[UIApplication sharedApplication] openURL:self.url];
	}
}

@end
