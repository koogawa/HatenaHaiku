//
//  LoginViewController.h
//
//  Created by koogawa on 11/12/26.
//  Copyright (c) 2011年 Kosuke Ogawa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OAConsumer.h"
#import "OADataFetcher.h"
#import "OAMutableURLRequest.h"

@interface LoginViewController : UIViewController <UIWebViewDelegate>

@property (nonatomic, retain) UIWebView     *webView;
@property (nonatomic, retain) OAConsumer    *consumer;
@property (nonatomic, retain) OAToken       *accessToken;

@end
