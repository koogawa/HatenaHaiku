//
//  SettingsViewController.m
//  HatenaHaiku
//
//  Created by koogawa on 2013/02/06.
//  Copyright (c) 2013年 Kosuke Ogawa. All rights reserved.
//

#import "SettingsViewController.h"
#import "SettingsCountViewController.h"
#import "KeywordViewController.h"
#import "WebViewController.h"
#import "AuthManager.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        self.title = @"設定";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // 完了ボタン
    UIBarButtonItem *cancelButton =
    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                  target:self
                                                  action:@selector(cancelButtonAction)];
    self.navigationItem.leftBarButtonItem = cancelButton;
    
    // コピーライト
    UIView *tableFooterView = [[UIView alloc] initWithFrame: CGRectMake(0, 0, self.view.frame.size.width, 40)];
	UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, self.view.frame.size.width - 20, 16)];
	label.textAlignment =  NSTextAlignmentCenter;
	label.backgroundColor = [UIColor clearColor];
	label.font = [UIFont systemFontOfSize:14];
	label.adjustsFontSizeToFitWidth = YES;
	label.numberOfLines = 1;
	label.text = @"(c) 2013 - 2016 @koogawa";
	[tableFooterView addSubview:label];
    self.tableView.tableFooterView = tableFooterView;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // 戻ってきた時にリロード
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private Method

- (void)cancelButtonAction
{
    LOG_CURRENT_METHOD;
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)dialogPostSwitchAction:(UISwitch *)sender
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setBool:sender.on forKey:@"CONFIG_DIALOG_POST"];
    [defaults synchronize];
}

- (void)dialogLocationSwitchAction:(UISwitch *)sender
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setBool:sender.on forKey:@"CONFIG_DIALOG_LOCATION"];
    [defaults synchronize];
}

- (void)dialogCancelSwitchAction:(UISwitch *)sender
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setBool:sender.on forKey:@"CONFIG_DIALOG_CANCEL"];
    [defaults synchronize];
}

- (void)logout
{
    // 自動で再ログインされてしまうのを防ぐため
    NSHTTPCookieStorage *cookieStrage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (id obj in [cookieStrage cookies]) {
        [cookieStrage deleteCookie:obj];
    }

    // トークン解除
    [[AuthManager sharedManager] clearAccessToken];

    [SVProgressHUD showSuccessWithStatus:@"ログアウト完了"];

    // ログアウトセルを削除
    [self.tableView reloadData];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return ([[AuthManager sharedManager] isAuthenticated]) ? 4 : 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    switch (section)
    {
		case 0:
			return 3;
			break;
            
		case 1:
			return 1;
			break;
            
		case 2:
			return 1;
			break;
            
		case 3:
			return 1;
			break;
            
		default:
			return 0;
	}
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch(section)
    {
        case 0:
            return @"確認画面を表示するタイミング";
            break;
            
		default:
			return nil;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifierText		= @"CellText";
    static NSString *CellIdentifierSwitch	= @"CellSwitch";
    
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
	switch (indexPath.section)
    {
		case 0:
        {
			switch (indexPath.row)
            {
				case 0:
				{
					UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierSwitch];
					if (cell == nil)
                    {
						cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifierSwitch];
                        cell.textLabel.text = @"投稿時";
                        cell.selectionStyle = UITableViewCellSelectionStyleNone;
                        UISwitch *configSwitch = [[UISwitch alloc] init];
                        CGFloat xPoint = self.tableView.frame.size.width - configSwitch.frame.size.width - 30;
                        CGRect frame = CGRectMake(xPoint,
                                                  8,
                                                  configSwitch.frame.size.width,
                                                  configSwitch.frame.size.height);
                        configSwitch.frame = frame;
                        BOOL on = ([defaults objectForKey:@"CONFIG_DIALOG_POST"] == nil) ? YES : [defaults boolForKey:@"CONFIG_DIALOG_POST"];
                        configSwitch.on = on;
                        [configSwitch addTarget:self
                                         action:@selector(dialogPostSwitchAction:)
                               forControlEvents:UIControlEventValueChanged];
                        [cell.contentView addSubview:configSwitch];
					}
					return cell;
					break;
				}
                    
				case 1:
				{
					UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierSwitch];
					if (cell == nil)
                    {
						cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifierSwitch];
                        cell.textLabel.text = @"位置情報挿入時";
                        cell.selectionStyle = UITableViewCellSelectionStyleNone;
                        UISwitch *configSwitch = [[UISwitch alloc] init];
                        CGFloat xPoint = self.tableView.frame.size.width - configSwitch.frame.size.width - 30;
                        CGRect frame = CGRectMake(xPoint,
                                                  8,
                                                  configSwitch.frame.size.width,
                                                  configSwitch.frame.size.height);
                        configSwitch.frame = frame;
                        BOOL on = ([defaults objectForKey:@"CONFIG_DIALOG_LOCATION"] == nil) ? YES : [defaults boolForKey:@"CONFIG_DIALOG_LOCATION"];
                        configSwitch.on = on;
                        [configSwitch addTarget:self
                                         action:@selector(dialogLocationSwitchAction:)
                               forControlEvents:UIControlEventValueChanged];
                        [cell.contentView addSubview:configSwitch];
					}
					return cell;
					break;
				}
                    
				case 2:
				{
					UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierSwitch];
					if (cell == nil)
                    {
						cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifierSwitch];
                        cell.textLabel.text = @"投稿キャンセル時";
                        cell.selectionStyle = UITableViewCellSelectionStyleNone;
                        
                        UISwitch *configSwitch = [[UISwitch alloc] init];
                        CGFloat xPoint = self.tableView.frame.size.width - configSwitch.frame.size.width - 30;
                        CGRect frame = CGRectMake(xPoint,
                                                  8,
                                                  configSwitch.frame.size.width,
                                                  configSwitch.frame.size.height);
                        configSwitch.frame = frame;
                        BOOL on = ([defaults objectForKey:@"CONFIG_DIALOG_CANCEL"] == nil) ? YES : [defaults boolForKey:@"CONFIG_DIALOG_CANCEL"];
                        configSwitch.on = on;
                        [configSwitch addTarget:self
                                         action:@selector(dialogCancelSwitchAction:)
                               forControlEvents:UIControlEventValueChanged];
                        [cell.contentView addSubview:configSwitch];
					}
					return cell;
					break;
				}
                    
				default:
					break;
			}
			break;
        }
            
		case 1:
        {
			switch (indexPath.row)
            {
				case 0:
				{
					UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierText];
					if (cell == nil) {
						cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifierText];
					}
					cell.textLabel.text = @"一度に取得する投稿件数";
                    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                    NSInteger count = [defaults integerForKey:@"CONFIG_FETCH_COUNT"];
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld", (long)count];
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
					return cell;
					break;
				}
                    
				default:
					break;
			}
            
			break;
        }
            
        case 2:
        {
			switch (indexPath.row)
            {
                    /*
				case 0:
				{
					UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierText];
					if (cell == nil) {
						cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifierText];
					}
					cell.textLabel.text = @"サポート場所";
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
					return cell;
					break;
				}
                    */
				case 0:
				{
					UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierText];
					if (cell == nil) {
						cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifierText];
					}
					cell.textLabel.text = @"ライセンス情報";
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
					return cell;
					break;
				}
                    
				default:
					break;
			}
            
			break;
        }
            
        case 3:
        {
			switch (indexPath.row)
            {
				case 0:
				{
					UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierText];
					if (cell == nil) {
						cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifierText];
					}
					cell.textLabel.text = @"ログアウト";
                    cell.accessoryType = UITableViewCellAccessoryNone;
					return cell;
					break;
				}
                    
				default:
					break;
			}
            
			break;
        }
	}
    
	return nil;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section)
    {
        case 1:
        {
            switch (indexPath.row)
            {
                case 0:
                {
                    SettingsCountViewController *viewController = [[SettingsCountViewController alloc] initWithStyle:UITableViewStyleGrouped];
                    [self.navigationController pushViewController:viewController animated:YES];
                    break;
                }
                    
                default:
                    break;
            }
            
            break;
        }
            
        case 2:
        {
            switch (indexPath.row)
            {
                    /*
                case 0:
                {
                    KeywordViewController *viewController = [[KeywordViewController alloc] initWithStyle:UITableViewStylePlain];
                    viewController.keyword = @"%E3%81%AF%E3%81%A6%E3%81%AA%E3%83%8F%E3%82%A4%E3%82%AF%E3%82%A2%E3%83%97%E3%83%AA%20for%20iPhone";
                    [self.navigationController pushViewController:viewController animated:YES];
                    break;
                }
                    */
                case 0:
                {
                    WebViewController *viewController = [[WebViewController alloc] initWithPath:@"lisence.html"];
                    viewController.title = @"ライセンス情報";
                    viewController.navigationBarHidden = NO;
                    viewController.toolbarHidden = YES;
                    [self.navigationController pushViewController:viewController animated:YES];
                    break;
                }
                    
                default:
                    break;
            }
            
            break;
        }
            
        case 3:
        {
            switch (indexPath.row)
            {
                case 0:
                {
                    // ログアウト
                    UIAlertController *alertController =
                    [UIAlertController alertControllerWithTitle:nil
                                                        message:@"ログアウトしますか？"
                                                 preferredStyle:UIAlertControllerStyleAlert];
                    [alertController addAction:[UIAlertAction actionWithTitle:CANCEL_BUTTON_TITLE
                                                                        style:UIAlertActionStyleCancel
                                                                      handler:nil]];
                    [alertController addAction:[UIAlertAction actionWithTitle:OK_BUTTON_TITLE
                                                                        style:UIAlertActionStyleDefault
                                                                      handler:^(UIAlertAction *action) {
                                                                          [self logout];
                                                                      }]];
                    [self presentViewController:alertController
                                       animated:YES
                                     completion:nil];

                    break;
                }
                    
                default:
                    break;
            }
            
            break;
        }
            
        default:
            break;
    }
}

@end
