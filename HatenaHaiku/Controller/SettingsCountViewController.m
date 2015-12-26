//
//  SettingsCountViewController.m
//  HatenaHaiku
//
//  Created by koogawa on 2013/02/07.
//  Copyright (c) 2013年 Kosuke Ogawa. All rights reserved.
//

#import "SettingsCountViewController.h"

@interface SettingsCountViewController ()

@end

@implementation SettingsCountViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        self.title = @"一度に取得する投稿件数";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    cell.textLabel.text = [NSString stringWithFormat:@"%ld", (long)((indexPath.row + 1) * 10)];
    
    // 現在の設定
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSInteger count = [defaults integerForKey:@"CONFIG_FETCH_COUNT"];
    cell.accessoryType = (count == (indexPath.row + 1) * 10) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
	
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 選択されてるセルを探す
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSInteger selectedRow = [defaults integerForKey:@"CONFIG_FETCH_COUNT"] / 10 - 1;
    
    // チェックを外す
	UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:selectedRow inSection:0]];
	selectedCell.accessoryType = UITableViewCellAccessoryNone;
	
	// チェックをつける
	UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
	cell.accessoryType = UITableViewCellAccessoryCheckmark;

    NSInteger count = (indexPath.row + 1) * 10;
	[defaults setInteger:count forKey:@"CONFIG_FETCH_COUNT"];
    [defaults synchronize];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    NSLog(@"before %d", indexPath.row);
}

@end
