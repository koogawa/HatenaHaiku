//
//  MoreLoadTableViewController.h
//  HatenaHaiku
//
//  Created by koogawa on 2012/12/05.
//  Copyright (c) 2012年 Kosuke Ogawa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MoreLoadTableViewController : UITableViewController

@property (nonatomic, assign) BOOL      moreLoadEnabled;
@property (nonatomic, assign) BOOL      isLoading;

@property (nonatomic, retain) UIView    *moreFooterView;
@property (nonatomic, retain) UILabel   *moreLabel;

@property (nonatomic, retain) UIActivityIndicatorView *moreSpinner;

- (void)addMoreLoadFooter;
- (void)startMoreLoading;
- (void)stopMoreLoading;
- (void)loadMore;

@end
