//
//  WebViewController.h
//
//  Created by koogawa on 10/11/17.
//  Copyright 2010 Kosuke Ogawa All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebViewController : UIViewController <UIWebViewDelegate>

@property (nonatomic, retain) UIWebView			*webView;
@property (nonatomic, retain) UIBarButtonItem	*reloadButton;
@property (nonatomic, retain) UIBarButtonItem	*stopButton;
@property (nonatomic, retain) UIBarButtonItem	*backButton;
@property (nonatomic, retain) UIBarButtonItem	*forwardButton;

@property (nonatomic, retain) NSURL             *url;
@property (nonatomic, retain) NSString          *path;

@property (nonatomic, assign) BOOL              navigationBarHidden;
@property (nonatomic, assign) BOOL              toolbarHidden;

- (id)initWithURL:(NSURL *)url;
- (id)initWithPath:(NSString *)path; 

@end
