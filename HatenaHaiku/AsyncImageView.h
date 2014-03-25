//
//  AsyncImageView.h
//  AsyncImage
//
//  Created by ntaku on 09/10/31.
//  Copyright 2009 http://d.hatena.ne.jp/ntaku/. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface AsyncImageView : UIImageView
{
	NSURLConnection         *conn_;
	NSMutableData           *data_;
    UIActivityIndicatorView *indicator_;
}

@property (nonatomic, assign) BOOL      indicatorVisible;
@property (nonatomic, strong) NSURL     *url;
@property (nonatomic, strong) UIImage   *defaultImage;

-(void)loadImageUrl:(NSURL *)url;
-(void)loadImageUrl:(NSURL *)url async:(BOOL)async;
-(void)abort;

@end
