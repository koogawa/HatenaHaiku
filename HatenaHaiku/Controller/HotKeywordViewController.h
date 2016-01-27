//
//  HotKeywordViewController.h
//  HatenaHaiku
//
//  Created by koogawa on 2012/12/09.
//  Copyright (c) 2012年 Kosuke Ogawa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HaikuManager.h"

@interface HotKeywordViewController : UITableViewController <UISearchResultsUpdating, UISearchControllerDelegate, UISearchBarDelegate, HaikuManagerDelegate>
{
    HaikuManager *_haikuManager;
}

@property (nonatomic, retain) NSMutableArray    *keywords;
@property (nonatomic, retain) NSMutableArray    *tmpKeywords;

@end
