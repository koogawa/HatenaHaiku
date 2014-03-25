//
//  HotKeywordViewController.h
//  HatenaHaiku
//
//  Created by koogawa on 2012/12/09.
//  Copyright (c) 2012年 Kosuke Ogawa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HotKeywordViewController : UITableViewController <UISearchBarDelegate, UISearchDisplayDelegate>

@property (nonatomic, retain) UISearchDisplayController *searchDisplay;
@property (nonatomic, retain) NSMutableArray            *keywords;
@property (nonatomic, retain) NSMutableArray            *tmpKeywords;

@end
