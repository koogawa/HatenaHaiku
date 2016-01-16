//
//  AppDelegate.m
//  HatenaHaiku
//
//  Created by koogawa on 2012/11/27.
//  Copyright (c) 2012年 Kosuke Ogawa. All rights reserved.
//

#import "AppDelegate.h"
#import "RecentViewController.h"
#import "AlbumViewController.h"
#import "HotKeywordViewController.h"
#import "MyPageViewController.h"
#import "LoginViewController.h"
#import "PostViewController.h"
#import "AuthManager.h"

@implementation AppDelegate

#define ALERT_LOGIN_TAG      101

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // 初期値を設定
    NSUserDefaults *defaults  = [NSUserDefaults standardUserDefaults];
    NSDictionary *appDefaults = @{@"CONFIG_FETCH_COUNT": @"10"};
    [defaults registerDefaults:appDefaults];
    
    // 最新エントリー
    RecentViewController *viewController1 = [[RecentViewController alloc] initWithStyle:UITableViewStylePlain];
    UINavigationController *navigationController1 = [[UINavigationController alloc] initWithRootViewController:viewController1];
    navigationController1.view.tag = UITabNameEntry;

    // アルバム
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    AlbumViewController *viewController2 = [[AlbumViewController alloc] initWithCollectionViewLayout:flowLayout];
    UINavigationController *navigationController2 = [[UINavigationController alloc] initWithRootViewController:viewController2];
    navigationController2.view.tag = UITabNameAlbum;

    // 投稿
    PostViewController *postViewController = [PostViewController new];
    UINavigationController *navigationController5 = [[UINavigationController alloc] initWithRootViewController:postViewController];
    navigationController5.view.tag = UITabNamePost;

    // キーワード
    HotKeywordViewController *viewController3 = [[HotKeywordViewController alloc] initWithStyle:UITableViewStylePlain];
    UINavigationController *navigationController3 = [[UINavigationController alloc] initWithRootViewController:viewController3];
    navigationController3.view.tag = UITabNameKeyword;

    // マイページ
    MyPageViewController *viewController4 = [[MyPageViewController alloc] initWithStyle:UITableViewStyleGrouped];
    UINavigationController *navigationController4 = [[UINavigationController alloc] initWithRootViewController:viewController4];
    navigationController4.view.tag = UITabNameMyPage;
    
//    self.tabBarController = [[UITabBarController alloc] init];
//    self.tabBarController.delegate = self;
//    self.tabBarController.viewControllers = @[navigationController1, navigationController2, navigationController5, navigationController3, navigationController4];

    // キャッシュディレクトリ削除（SDWebImageとか使ったほうが良さそう）
    [self clearCacheDirectory];

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


#pragma mark - Private method

- (void)clearCacheDirectory
{
    // キャッシュディレクトリ（注意：~/tmp以下はバックアップされないのでたまに消える）
    NSInteger now = time(nil);
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSInteger removed = [defaults integerForKey:CACHE_REMOVED_KEY];
    NSString *tmpDir = [NSHomeDirectory() stringByAppendingPathComponent:@"tmp/icon"];

    // 初回時の処理
    if (![[NSFileManager defaultManager] fileExistsAtPath:tmpDir])
    {
        NSError *error = nil;
        removed = now;
        [defaults setInteger:removed forKey:CACHE_REMOVED_KEY];

        // キャッシュディレクトリ作成
        if (![[NSFileManager defaultManager] fileExistsAtPath:tmpDir]) {
            [[NSFileManager defaultManager] createDirectoryAtPath:tmpDir
                                      withIntermediateDirectories:YES
                                                       attributes:nil
                                                            error:&error];
        }
        LOG(@"Cache Directory created! error = %@", error);
    }

    LOG(@"diff:%f", (now - removed) / 86400.0f);

    // 前回のキャッシュ削除から30日経過していたら再作成
    if ((now - removed) / 86400.0f > CACHE_RETENTION_DAY )
    {
        NSError *error = nil;

        if ([[NSFileManager defaultManager] fileExistsAtPath:tmpDir])
        {
            [[NSFileManager defaultManager] removeItemAtPath:tmpDir
                                                       error:&error];
            LOG(@"Cache deleted! error = %@", error);

            if (!error)
            {
                // 最終削除日の保存
                removed = time(nil);
                [defaults setInteger:removed forKey:CACHE_REMOVED_KEY];
                [defaults synchronize];

                // キャッシュディレクトリ再作成
                if (![[NSFileManager defaultManager] fileExistsAtPath:tmpDir])
                {
                    [[NSFileManager defaultManager] createDirectoryAtPath:tmpDir
                                              withIntermediateDirectories:YES
                                                               attributes:nil
                                                                    error:&error];
                    LOG(@"Cache Directory recreated! error = %@", error);
                }
            }
        }
    }
}

- (void)showLoginView
{
    LoginViewController *viewController = [[LoginViewController alloc] init];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
    navigationController.toolbar.tintColor = THEME_COLOR;
    
    // 一番上の階層に表示されているビューコントローラを探す
    UIViewController *parentViewController = self.tabBarController;
    while (parentViewController.presentedViewController != nil) {
        parentViewController = parentViewController.presentedViewController;
    }
    [parentViewController presentViewController:navigationController animated:YES completion:nil];
}


#pragma mark - UITabBarControllerDelegate

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController
{
    LOG_CURRENT_METHOD;
    
    if (viewController.view.tag == UITabNamePost)
    {
        if ([[AuthManager sharedManager] isAuthenticated])
        {
            PostViewController *viewController = [[PostViewController alloc] initWithStyle:UITableViewStylePlain];
            UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
            navigationController.toolbar.tintColor = THEME_COLOR;
            [self.tabBarController presentViewController:navigationController animated:YES completion:nil];
        }
        else {
            UIAlertView *alert =
            [[UIAlertView alloc] initWithTitle:nil
                                       message:NO_LOGIN_MESSAGE
                                      delegate:self
                             cancelButtonTitle:@"キャンセル"
                             otherButtonTitles:@"ログイン", nil];
            alert.tag = ALERT_LOGIN_TAG;
            [alert show];
        }

        return NO;
    }
    
    return YES;
}


#pragma mark - UIAlertView delegate

- (void)alertView:(UIAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
//	LOG(@"buttonIndex = %d", buttonIndex);
    
    switch (alertView.tag)
    {
        case ALERT_LOGIN_TAG:
        {
            if (buttonIndex == 1)
            {
                [self showLoginView];
            }
            break;
        }
            
        default:
            break;
    }
}

@end
