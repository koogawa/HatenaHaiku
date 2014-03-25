//
//  AlbumCollectionCell.h
//  HatenaHaiku
//
//  Created by koogawa on 2013/02/12.
//  Copyright (c) 2013年 Kosuke Ogawa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AsyncImageView.h"

@interface AlbumCollectionCell : UICollectionViewCell

@property (nonatomic, strong) AsyncImageView    *imageView;
@property (nonatomic, retain) AsyncImageView    *albumImageView;

@end
