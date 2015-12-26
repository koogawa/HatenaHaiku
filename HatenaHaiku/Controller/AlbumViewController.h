//
//  AlbumViewController.h
//  HatenaHaiku
//
//  Created by koogawa on 2013/02/12.
//  Copyright (c) 2013年 Kosuke Ogawa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MoreLoadCollectionViewController.h"
#import "HaikuManager.h"

@interface AlbumViewController : MoreLoadCollectionViewController <HaikuManagerDelegate>
{
    HaikuManager *_haikuManager;
}

@property (nonatomic, assign) NSInteger         page;
@property (nonatomic, strong) NSMutableArray    *statuses;
@property (nonatomic, strong) UIRefreshControl  *refreshControl;

@end
