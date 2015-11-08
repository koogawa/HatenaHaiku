//
//  StatusTableViewCell.h
//  HatenaHaiku
//
//  Created by koogawa on 2012/11/27.
//  Copyright (c) 2012年 Kosuke Ogawa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AsyncImageView.h"

@class StatusTableViewCell;

@protocol StatusTableViewCellDelegate <NSObject>
-(void)statusViewCell:(StatusTableViewCell *)cell linkDidTap:(NSURL *)url;
@end

@interface StatusTableViewCell : UITableViewCell <UIWebViewDelegate>

@property (nonatomic, assign) id<StatusTableViewCellDelegate>    delegate;

@property (nonatomic, retain) AsyncImageView	*profileImageView;
@property (nonatomic, retain) UIWebView         *bodyWebView;
@property (nonatomic, retain) UILabel			*dateTextLabel;

@property (nonatomic, retain) NSString          *html;

@property (nonatomic, assign) CGFloat           contentHeight;

@end
