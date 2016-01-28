//
//  BaseViewController.h
//  HatenaHaiku
//
//  Created by koogawa on 2012/12/05.
//  Copyright (c) 2012年 Kosuke Ogawa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MoreLoadTableViewController.h"
#import "StatusTableViewCell.h"
#import "HaikuManager.h"
@import SafariServices;

// TODO:BaseViewControllerとMoreLoadTableViewControllerを統合して BaseTableViewController
@interface BaseViewController : MoreLoadTableViewController <StatusTableViewCellDelegate, HaikuManagerDelegate>
{
    HaikuManager *_haikuManager;
}

@property (nonatomic, assign) NSInteger         page;
@property (nonatomic, retain) NSMutableArray    *statuses;
@property (nonatomic, retain) NSMutableArray    *replies;

// 長押しされた投稿を覚えておく
@property (nonatomic, retain) NSDictionary      *selectedStatusDic;

- (void)postButtonActionWithOption:(NSDictionary *)option;
- (NSString *)generateHtmlFromStatus:(NSDictionary *)statusDic;

@end
