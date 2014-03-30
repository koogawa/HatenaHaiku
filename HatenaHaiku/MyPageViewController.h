//
//  MyPageViewController.h
//  HatenaHaiku
//
//  Created by koogawa on 2012/12/09.
//  Copyright (c) 2012年 Kosuke Ogawa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HaikuManager.h"

@interface MyPageViewController : UITableViewController <HaikuManagerDelegate>
{
    NSDictionary *userInfo_;
    HaikuManager *_haikuManager;
}

@end
