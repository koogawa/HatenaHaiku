//
//  StatusTableViewCell.m
//  HatenaHaiku
//
//  Created by koogawa on 2012/11/27.
//  Copyright (c) 2012年 Kosuke Ogawa. All rights reserved.
//

#import "StatusTableViewCell.h"

@implementation StatusTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
		// プロフィールアイコン
		CGRect profileRect = CGRectMake(10, 10, 44, 44);
		self.profileImageView = [[AsyncImageView alloc] initWithFrame:profileRect];
        //self.profileImageView.backgroundColor = [UIColor clearColor];
        self.profileImageView.contentScaleFactor = [UIScreen mainScreen].scale;
		[self.contentView addSubview:self.profileImageView];
		
        // キーワード
        self.textLabel.font = [UIFont boldSystemFontOfSize:16];
        self.textLabel.textColor = [UIColor colorWithRed:0 green:0.4 blue:0 alpha:1.0];
        self.textLabel.numberOfLines = 1;
        
        // 本文
        self.detailTextLabel.font = [UIFont systemFontOfSize:16];
        self.detailTextLabel.textColor = [UIColor colorWithWhite:0.1 alpha:1.0];
        self.detailTextLabel.numberOfLines = 0;
        
        self.bodyWebView = [[UIWebView alloc] initWithFrame:self.detailTextLabel.frame];
        self.bodyWebView.delegate = self;
        self.bodyWebView.scalesPageToFit = NO;
        self.bodyWebView.scrollView.scrollsToTop = NO;
        [self.contentView addSubview:self.bodyWebView];
        
        // スクロール禁止
        UIScrollView *webScrollView = [[self.bodyWebView subviews] lastObject];
        if ([webScrollView respondsToSelector:@selector(setScrollEnabled:)]){
            [webScrollView setScrollEnabled:NO];
        }
        
		// 投稿日時
		self.dateTextLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		self.dateTextLabel.font = [UIFont systemFontOfSize:13];
		self.dateTextLabel.textColor = [UIColor colorWithRed:0.5 green:0 blue:0 alpha:1.0];
		//[self.contentView addSubview:self.dateTextLabel];
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
	
	// キーワード
	self.textLabel.frame = CGRectMake(64, 8, self.frame.size.width - 64 - 10, self.textLabel.frame.size.height);
    
	// 本文
	self.detailTextLabel.frame = CGRectMake(self.textLabel.frame.origin.x, CGRectGetMaxY(self.textLabel.frame), self.textLabel.frame.size.width, self.detailTextLabel.frame.size.height);
    CGFloat contentHeight = [[self.bodyWebView stringByEvaluatingJavaScriptFromString:
                              @"document.getElementById(\"contents\").offsetHeight"] floatValue];
    
    self.bodyWebView.frame = CGRectMake(self.textLabel.frame.origin.x - 5.0, CGRectGetMinY(self.textLabel.frame) - 5.0, self.textLabel.frame.size.width, contentHeight + 5.0);

    // 投稿日時
//    NSLog(@"self.contentView.frame %@", NSStringFromCGRect(self.contentView.frame));
//	CGRect rect = self.detailTextLabel.frame;
//	CGRect dateTextRect = self.dateTextLabel.frame;
//	dateTextRect.origin.x = self.textLabel.frame.origin.x + 1;
//	dateTextRect.origin.y = self.contentView.frame.size.height - 20;
//	dateTextRect.size.width = self.textLabel.frame.size.width;
//	dateTextRect.size.height = 12;
//    self.dateTextLabel.frame = dateTextRect;
}

//- (void)drawRect:(CGRect)rect
//{
//    LOG_CURRENT_METHOD;
//    
//    [self.bodyWebView loadHTMLString:self.html baseURL:nil ];
//}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


#pragma mark - UIWebViewDelegate

// コンテンツに合わせてリサイズ
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    LOG_CURRENT_METHOD;
    
	CGFloat contentHeight = [[webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.scrollHeight"] floatValue];
	webView.frame = CGRectMake(webView.frame.origin.x, webView.frame.origin.y, webView.frame.size.width, contentHeight + 5);
    self.contentHeight = contentHeight;
    
    //[(UITableView *)self.superview reloadData];
}

//- (void)webViewDidFinishLoad:(UIWebView *)webView
//{
//    CGFloat webViewHeight = 0.0f;
//    if (self.subviews.count > 0) {
//        UIView *scrollerView = [self.subviews objectAtIndex:0];
//        if (scrollerView.subviews.count > 0) {
//            UIView *webDocView = scrollerView.subviews.lastObject;
//            if ([webDocView isKindOfClass:[NSClassFromString(@"UIWebDocumentView") class]])
//                webViewHeight = webDocView.frame.size.height;
//        }
//    }
//    NSLog(@"webViewHeight %f", webViewHeight);
//    
//    	CGFloat contentHeight = [[webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.scrollHeight"] floatValue];
//    NSLog(@"contentHeight %f", contentHeight);
//    
//    NSString *output = [webView stringByEvaluatingJavaScriptFromString:@"document.getElementById(\"contents\").offsetHeight;"];
//    NSLog(@"height: %@", output);
//}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    LOG_CURRENT_METHOD;
    
    if (navigationType == UIWebViewNavigationTypeLinkClicked)
	{
        if ([self.delegate respondsToSelector:@selector(statusViewCell:linkDidTap:)]) {
            [self.delegate statusViewCell:self linkDidTap:[request URL]];
        }
        
		return NO;
	}

    return YES;
}

@end
