//
//  AsyncImageView.m
//  AsyncImage
//
//  Created by ntaku on 09/10/31.
//  Copyright 2009 http://d.hatena.ne.jp/ntaku/. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "AsyncImageView.h"

@implementation AsyncImageView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        self.contentMode = UIViewContentModeScaleAspectFill;
        self.clipsToBounds = YES;
        
        // インジケータ追加
        indicator_ = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        indicator_.frame = self.bounds;
        indicator_.hidesWhenStopped = YES;
        [self addSubview:indicator_];
    }
    return self;
}

- (NSString *)getTempPath
{
	NSString *fileName = [[self.url path] stringByReplacingOccurrencesOfString:@"/" withString:@"~"];
	NSString *tempPath = [NSHomeDirectory() stringByAppendingPathComponent:@"tmp/icon"];
	tempPath = [tempPath stringByAppendingPathComponent:fileName];
	return tempPath;
}

- (void)loadImageUrl:(NSURL *)url
{
	self.url = url;
	
	[self abort];
	
	// キャッシュされてるならそれ使う
	NSString *tempPath = [self getTempPath];
	if ([[NSFileManager defaultManager] fileExistsAtPath:tempPath])
    {
		NSData *data = [NSData dataWithContentsOfFile:tempPath];
        [self showImageWithAnimation:[UIImage imageWithData:data]];
		return;
	}
	
	UIImage *image = (self.defaultImage != nil) ? self.defaultImage : [UIImage imageNamed:@"none.gif"];
    [self showImageWithAnimation:image];

    if (self.indicatorVisible)
    {
        [indicator_ startAnimating];
    }
    
	data_ = [[NSMutableData alloc] initWithCapacity:0];

	NSURLRequest *req = [NSURLRequest requestWithURL:url
                                         cachePolicy:NSURLRequestUseProtocolCachePolicy
                                     timeoutInterval:30.0];
	conn_ = [[NSURLConnection alloc] initWithRequest:req delegate:self];
}
/* 使ってない？
-(void)loadImageUrl:(NSURL *)url async:(BOOL)async
{
	self.url = url;
    
    if (async)
    {
        [self loadImageUrl:url];
        return;
    }
    
	// キャッシュされてるならそれ使う
	NSString *tempPath = [self getTempPath];
	if ([[NSFileManager defaultManager] fileExistsAtPath:tempPath]) {
		NSData *data = [NSData dataWithContentsOfFile:tempPath];
//        self.contentMode = UIViewContentModeScaleAspectFill;
//        self.clipsToBounds = YES;
		self.image = [UIImage imageWithData:data];
		return;
	}
	
    NSData *data = [NSData dataWithContentsOfURL:url];
//	self.contentMode = UIViewContentModeScaleAspectFill;
//    self.clipsToBounds = YES;
    self.image = [UIImage imageWithData:data];
	
	// キャッシュに書き込む
	NSData *pngData = [[NSData alloc] initWithData:UIImagePNGRepresentation(self.image)];
	[pngData writeToFile:[self getTempPath] atomically:YES];
}
*/
- (void)showImageWithAnimation:(UIImage *)image
{
//    self.contentMode = UIViewContentModeScaleAspectFit;
    self.alpha = 0.0;
    self.image = image;

    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    self.alpha = 1.0;
    [UIView commitAnimations];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	[data_ setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)nsdata
{
	[data_ appendData:nsdata];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    if (self.indicatorVisible)
    {
        [indicator_ stopAnimating];
    }

	[self abort];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	UIImage *image = [UIImage imageWithData:data_];
    [self showImageWithAnimation:image];
	
    if (self.indicatorVisible)
    {
        [indicator_ stopAnimating];
    }
    
	// キャッシュに書き込む
	NSData *pngData = [[NSData alloc] initWithData:UIImagePNGRepresentation(image)];
	[pngData writeToFile:[self getTempPath] atomically:YES];
	
	[self abort];
}

-(void)abort
{
	if (conn_ != nil)
    {
		[conn_ cancel];
		conn_ = nil;
	}
	if (data_ != nil)
    {
		data_ = nil;
	}
}

@end
