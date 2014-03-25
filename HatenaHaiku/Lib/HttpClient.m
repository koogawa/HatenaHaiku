//
//  HttpClient.m
//  HatenaHaiku
//
//  Created by koogawa on 2012/12/06.
//  Copyright (c) 2012年 Kosuke Ogawa. All rights reserved.
//

#import "HttpClient.h"

@implementation HttpClient

#pragma mark - Public Method

- (void)sendRequestWithURL:(NSURL *)url method:(NSString *)method
{
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
    [req setHTTPMethod:method];
    self.connection = [NSURLConnection connectionWithRequest:req delegate:self];
}

- (void)sendRequestWithURL:(NSURL *)url method:(NSString *)method name:(NSString *)name
{
    self.error = nil;
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
    [req setHTTPMethod:method];
    self.name = name;
    self.connection = [NSURLConnection connectionWithRequest:req delegate:self];
}


#pragma mark - NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    self.data = [NSMutableData data];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)receiveData
{
    [self.data appendData:receiveData];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [[NSNotificationCenter defaultCenter] postNotificationName:self.name
                                                        object:self];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    self.error = error;
    [[NSNotificationCenter defaultCenter] postNotificationName:self.name
                                                        object:self];
}

@end
