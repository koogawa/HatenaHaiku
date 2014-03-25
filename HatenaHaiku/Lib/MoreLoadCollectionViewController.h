//
//  MoreLoadCollectionViewController.h
//  HatenaHaiku
//
//  Created by koogawa on 2013/02/17.
//  Copyright (c) 2013年 Kosuke Ogawa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MoreLoadCollectionViewController : UICollectionViewController

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
