//
//  DetailViewController.h
//  HatenaHaiku
//
//  Created by koogawa on 2012/12/08.
//  Copyright (c) 2012年 Kosuke Ogawa. All rights reserved.
//

#import "BaseViewController.h"

@interface DetailViewController : BaseViewController

@property (nonatomic, retain) NSString  *statusId;
@property (nonatomic, retain) NSString  *userId;
@property (nonatomic, retain) NSString  *userName;

@end
