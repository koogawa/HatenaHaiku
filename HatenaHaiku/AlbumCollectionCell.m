//
//  AlbumCollectionCell.m
//  HatenaHaiku
//
//  Created by koogawa on 2013/02/12.
//  Copyright (c) 2013年 Kosuke Ogawa. All rights reserved.
//

#import "AlbumCollectionCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation AlbumCollectionCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor whiteColor];
        
		self.albumImageView = [[AsyncImageView alloc] initWithFrame:CGRectMake(2, 2, frame.size.width - 4, frame.size.height - 4)];
        self.albumImageView.indicatorVisible = YES;
        self.albumImageView.defaultImage = [UIImage new]; // dummy
        self.albumImageView.contentScaleFactor = [UIScreen mainScreen].scale;
		[self.contentView addSubview:self.albumImageView];
        
        CALayer *layer = [self.albumImageView layer];
        [layer setMasksToBounds:YES];
        [layer setBorderWidth: 1.0f];
        [layer setBorderColor:[[UIColor colorWithWhite:0.9 alpha:1.0] CGColor]];
    }
    return self;
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 }
 */

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    
    if (selected) {
        self.backgroundColor = [UIColor colorWithWhite:0.6 alpha:1.0];
    } else {
        self.backgroundColor = [UIColor whiteColor];
    }
}

@end
