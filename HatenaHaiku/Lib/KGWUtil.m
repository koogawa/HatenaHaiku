//
//  KGWUtil.m
//  HatenaHaiku
//
//  Created by koogawa on 2014/03/30.
//  Copyright (c) 2014年 Kosuke Ogawa. All rights reserved.
//

#import "KGWUtil.h"

@implementation KGWUtil

+ (BOOL)isOverThisVersion:(NSString *)version
{
	NSString *currentVersion = [[UIDevice currentDevice] systemVersion];
	return ([currentVersion compare:version options:NSNumericSearch] != NSOrderedAscending);
}

@end
