//
//  KOUtil.m
//  HatenaHaiku
//
//  Created by koogawa on 2013/09/08.
//  Copyright (c) 2013年 Kosuke Ogawa. All rights reserved.
//

#import "KOUtil.h"

@implementation KOUtil

+ (BOOL)isOverThisVersion:(NSString *)version
{
	NSString *currentVersion = [[UIDevice currentDevice] systemVersion];
	return ([currentVersion compare:version options:NSNumericSearch] != NSOrderedAscending);
}

@end
