//
//  AppDelegate.h
//  HatenaHaiku
//
//  Created by koogawa on 2012/11/27.
//  Copyright (c) 2012年 Kosuke Ogawa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate, UITabBarControllerDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UITabBarController *tabBarController;

- (void)showLoginView;

@end
