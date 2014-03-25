//
//  HttpClient.h
//  HatenaHaiku
//
//  Created by koogawa on 2012/12/06.
//  Copyright (c) 2012年 Kosuke Ogawa. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HttpClient : NSObject

@property(retain, nonatomic) NSURLConnection    *connection;
@property(retain, nonatomic) NSMutableData      *data;
@property(retain, nonatomic) NSString           *urlString;
@property(strong, nonatomic) NSString           *name;
@property(strong, nonatomic) NSError            *error;
@property(assign, nonatomic) NSUInteger         requestId;

- (void)sendRequestWithURL:(NSURL *)url method:(NSString *)method;
- (void)sendRequestWithURL:(NSURL *)url method:(NSString *)method name:(NSString *)name;

@end
