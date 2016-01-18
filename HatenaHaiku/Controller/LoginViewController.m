//
//  LoginViewController.m
//
//  Created by koogawa on 11/12/26.
//  Copyright (c) 2011年 Kosuke Ogawa. All rights reserved.
//

#import "LoginViewController.h"
#import "AuthManager.h"
//#import "URLRequest.h"

@implementation LoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
	CGRect frame = [[UIScreen mainScreen] bounds];
	UIView *view = [[UIView alloc] initWithFrame:frame];
	self.view = view;
    
//	webView_ = [[UIWebView alloc] init];
//	webView_.delegate = self;
//	webView_.frame = self.view.frame;
//	webView_.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//	webView_.scalesPageToFit = YES;
//	[self.view addSubview:webView_];
    
	// ナビゲーションバーにキャンセルボタンを追加
    /*
	UIBarButtonItem *cancelButton =
    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                  target:self
                                                  action:@selector(cancelButtonAction)];
    self.navigationItem.leftBarButtonItem = cancelButton;
     */
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"ログイン";
    self.navigationController.navigationBar.tintColor = THEME_COLOR;
    
    // ナビゲーションバーにキャンセルボタンを追加
    UIBarButtonItem *cancelButton =
    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                  target:self
                                                  action:@selector(cancelButtonAction)];
    self.navigationItem.leftBarButtonItem = cancelButton;

    self.webView = [[UIWebView alloc] init];
	self.webView.delegate = self;
	self.webView.frame = self.view.frame;
	self.webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	self.webView.scalesPageToFit = YES;
	[self.view addSubview:self.webView];

//    NSString *authenticateURLString = [NSString stringWithFormat:AUTH_URI_FORMAT, CLIENT_ID, CALLBACK_URL];
//    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:authenticateURLString]];
//    [webView_ loadRequest:request];
    [self startRequestToken];
}

- (void)viewWillDisappear:(BOOL)animated
{
	// 画面を閉じるときにステータスバーのインジケータを確実にOFFにしておく
	[super viewWillDisappear:animated];
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark - Private Method

- (void)cancelButtonAction
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)startRequestToken
{
    LOG_CURRENT_METHOD;
    
    self.consumer = [[OAConsumer alloc] initWithKey:OAUTH_CONSUMER_KEY
                                             secret:OAUTH_CONSUMER_SECRET];
    
    OADataFetcher *fetcher = [[OADataFetcher alloc] init];
    
    NSURL *url = [NSURL URLWithString:@"https://www.hatena.com/oauth/initiate"];
    OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:url
                                                                   consumer:self.consumer
                                                                      token:nil
                                                                      realm:nil
                                                          signatureProvider:nil];
    [request setHTTPMethod:@"POST"];
    NSString *postString = @"scope=read_public,write_public&oauth_callback=http://koogawa.sakura.ne.jp/haiku/index.html";
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [SVProgressHUD show];
    
    [fetcher fetchDataWithRequest:request
                         delegate:self
                didFinishSelector:@selector(requestTokenTicket:didFinishGetRequestToken:)
                  didFailSelector:@selector(requestTokenTicket:didFailWithError:)];
}

- (void)callbackFromBrowser:(NSURL *)responseURL
{
    LOG_CURRENT_METHOD;
    LOG(@"responseURL = %@", responseURL);
    
    NSString *query = [responseURL query];
    NSString *verifier = @"";
    
    // レスポンス文字列を解析して oauth_verifier を取り出す
    NSArray *components = [query componentsSeparatedByString:@"&"];
    
    for (NSString *component in components)
    {
        NSArray *pair = [component componentsSeparatedByString:@"="];
        NSString *key = pair[0];
        NSString *val = pair[1];
        
        if ([key isEqualToString:@"oauth_verifier"])
        {
            LOG(@"oauth_verifier = %@", val);
            
            if ([val length] > 0)
            {
                verifier = val;
            }
        }
    }
    
    self.accessToken.verifier = [verifier decodedURLString];
    
    OADataFetcher *fetcher = [[OADataFetcher alloc] init];
    
    NSURL *url = [NSURL URLWithString:@"https://www.hatena.com/oauth/token"];
    
    OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:url
                                                                    consumer:self.consumer
                                                                       token:self.accessToken
                                                                       realm:nil
                                                           signatureProvider:nil];
    [request setHTTPMethod:@"POST"];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    [fetcher fetchDataWithRequest:request
                         delegate:self
                didFinishSelector:@selector(requestTokenTicket:didFinishfetchAccessToken:)
                  didFailSelector:@selector(requestTokenTicket:didFailWithError:)];
}

#pragma mark - API Callback

- (void)requestTokenTicket:(OAServiceTicket *)ticket didFinishGetRequestToken:(NSData *)data
{
    LOG_CURRENT_METHOD;
    LOG(@"data = %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [SVProgressHUD dismiss];
    
    if (ticket.didSucceed)
    {
        NSString *responseBody = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        self.accessToken = [[OAToken alloc] initWithHTTPResponseBody:responseBody];
        
        NSString *address = [NSString stringWithFormat:@"https://www.hatena.ne.jp/touch/oauth/authorize?oauth_token=%@", self.accessToken.key];
        NSURL *url = [NSURL URLWithString:address];
        
        // ブラウザ表示
        [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
    }
    else {
        [self requestTokenTicket:nil didFailWithError:nil];
    }
}

- (void)requestTokenTicket:(OAServiceTicket *)ticket didFinishfetchAccessToken:(NSData *)data
{
    LOG_CURRENT_METHOD;
    LOG(@"data = %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [SVProgressHUD dismiss];
    
    if (ticket.didSucceed)
    {
        NSString *responseBody = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        self.accessToken = [self.accessToken initWithHTTPResponseBody:responseBody];
        LOG(@"access_token %@, secret %@, url_name %@, display_name %@", self.accessToken.key, self.accessToken.secret, self.accessToken.urlName, [self.accessToken.displayName stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]);
        
        // 取得できた値を保存
        [[AuthManager sharedManager] setAccessToken:self.accessToken.key];
        [[AuthManager sharedManager] setAccessTokenSecret:self.accessToken.secret];
        [[AuthManager sharedManager] setUrlName:self.accessToken.urlName];
        [[AuthManager sharedManager] setDisplayName:[self.accessToken.displayName stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else {
        [self requestTokenTicket:nil didFailWithError:nil];
    }
}

- (void)requestTokenTicket:(OAServiceTicket *)ticket didFailWithError:(NSError *)error
{
    LOG_CURRENT_METHOD;
    LOG(@"error = %@", error);
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [SVProgressHUD showErrorWithStatus:@"認証の途中でエラーが発生しました"];
}

#pragma mark - UIWebView delegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
	LOG_CURRENT_METHOD;
    
    NSURL *url = [request URL];
	LOG(@"url = %@", url);
    
    NSString *query = [url query];
    
    if ([query length] > 0 && [query rangeOfString:@"oauth_verifier="].location != NSNotFound)
    {
        [self performSelector:@selector(callbackFromBrowser:) withObject:url];
        return NO;
    }
    
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
	LOG_CURRENT_METHOD;
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	[SVProgressHUD show];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
	LOG_CURRENT_METHOD;
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	[SVProgressHUD dismiss];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
	LOG_CURRENT_METHOD;
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	[SVProgressHUD dismiss];
}

@end
