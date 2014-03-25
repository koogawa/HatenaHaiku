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

#define INDICATOR_TAG 101

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        self.contentMode = UIViewContentModeScaleAspectFill;
        self.clipsToBounds = YES;
        
        // インジケータ追加
        UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        indicator.frame = self.bounds;
        indicator.tag = INDICATOR_TAG;
        indicator.hidesWhenStopped = YES;
        //        indicator.contentMode = UIViewContentModeCenter;
        //        [indicator startAnimating];
        [self addSubview:indicator];
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
//        self.contentMode = UIViewContentModeScaleAspectFill;
//        self.clipsToBounds = YES;
		self.image = [UIImage imageWithData:data];
		return;
	}
	
//	self.contentMode = UIViewContentModeScaleAspectFill;
//    self.clipsToBounds = YES;
	self.image = (self.defaultImage != nil) ? self.defaultImage : [UIImage imageNamed:@"none.gif"];
//	self.backgroundColor = [UIColor clearColor];
    
    if (self.indicatorVisible)
    {
        UIActivityIndicatorView *indicator = (UIActivityIndicatorView *)[self viewWithTag:INDICATOR_TAG];
        [indicator startAnimating];
    }
    
	data_ = [[NSMutableData alloc] initWithCapacity:0];

	NSURLRequest *req = [NSURLRequest requestWithURL:url
                                         cachePolicy:NSURLRequestUseProtocolCachePolicy
                                     timeoutInterval:30.0];
	conn_ = [[NSURLConnection alloc] initWithRequest:req delegate:self];
}

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

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
//	NSLog(@"connection didRecieveResponse");
	[data_ setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)nsdata
{
//	NSLog(@"connection didReceiveData len=%d", [nsdata length]);
	[data_ appendData:nsdata];	
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	NSLog(@"connection didFailWithError - %@ %@", [error localizedDescription], [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);

    if (self.indicatorVisible)
    {
        UIActivityIndicatorView *indicator = (UIActivityIndicatorView *)[self viewWithTag:INDICATOR_TAG];
        [indicator stopAnimating];
    }

	[self abort];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
//	self.contentMode = UIViewContentModeScaleAspectFill;
//    self.clipsToBounds = YES;
	self.image = [UIImage imageWithData:data_];
	
    if (self.indicatorVisible)
    {
        UIActivityIndicatorView *indicator = (UIActivityIndicatorView *)[self viewWithTag:INDICATOR_TAG];
        [indicator stopAnimating];
    }
    
	// キャッシュに書き込む
	NSData *pngData = [[NSData alloc] initWithData:UIImagePNGRepresentation(self.image)];
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
