//
//  MoreLoadTableViewController.m
//  HatenaHaiku
//
//  Created by koogawa on 2012/12/05.
//  Copyright (c) 2012年 Kosuke Ogawa. All rights reserved.
//

#import "MoreLoadTableViewController.h"

#define MORE_FOOTER_HEIGHT 52.0f

@implementation MoreLoadTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        self.moreLoadEnabled = YES;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super initWithCoder:decoder];
    if (self) {
        self.moreLoadEnabled = YES;
    }

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (self.moreLoadEnabled) {
        [self addMoreLoadFooter];
    }
}


#pragma mark - Private method

- (void)addMoreLoadFooter
{
    self.moreFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, self.tableView.contentSize.height, self.tableView.frame.size.width, MORE_FOOTER_HEIGHT)];
    self.moreFooterView.backgroundColor = [UIColor clearColor];
    
    self.moreLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, MORE_FOOTER_HEIGHT)];
    self.moreLabel.backgroundColor = [UIColor clearColor];
    self.moreLabel.font = [UIFont boldSystemFontOfSize:12.0];
    self.moreLabel.textAlignment = NSTextAlignmentCenter;
    self.moreLabel.text = @"読み込み中…";
    
    self.moreSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.moreSpinner.frame = CGRectMake(floorf(floorf(MORE_FOOTER_HEIGHT - 20) / 2), floorf((MORE_FOOTER_HEIGHT - 20) / 2), 20, 20);
    self.moreSpinner.hidesWhenStopped = YES;
    
    [self.moreFooterView addSubview:self.moreLabel];
    [self.moreFooterView addSubview:self.moreSpinner];
    [self.tableView addSubview:self.moreFooterView];
    

    // Hide at first
    [self.moreFooterView setHidden:YES];
}

- (void)startMoreLoading
{
    self.isLoading = YES;
    
    self.moreFooterView.frame = CGRectMake(0, self.tableView.contentSize.height, self.tableView.frame.size.width, MORE_FOOTER_HEIGHT);
    self.moreFooterView.hidden = NO;
    [self.moreSpinner startAnimating];
    
    [self loadMore];
}

- (void)stopMoreLoading
{
    self.isLoading = NO;
    
    self.moreFooterView.hidden = YES;
    [self.moreSpinner stopAnimating];
}

- (void)loadMore
{
    // This is just a demo. Override this method with your custom reload action.
    // Don't forget to call stopLoading at the end.
    [self performSelector:@selector(stopMoreLoading) withObject:nil afterDelay:2.0];
}


#pragma mark - Table view delegate

// オーバーライドするときは [super ...] でここも呼ぶこと！
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!self.moreLoadEnabled) return;
    
    NSInteger lastSec = [self numberOfSectionsInTableView:tableView] - 1;
    NSInteger lastRow = [self tableView:tableView numberOfRowsInSection:lastSec] - 1;
    
    // 一番下までスクロールしたら更に読み込み
    // ロード中は何もしない && 無限ループ防止の為、ドラッグ時にしか反応させない
    if (!self.isLoading && self.tableView.dragging && indexPath.section == lastSec && indexPath.row == lastRow)
    {
        LOG(@"*********** more load! *************");
        CGFloat height = [KGWUtil isOverThisVersion:@"7.0"] ? MORE_FOOTER_HEIGHT + TAB_BAR_HEIGHT : MORE_FOOTER_HEIGHT;
        self.tableView.contentInset = UIEdgeInsetsMake(self.tableView.contentInset.top, 0, height, 0);
        [self performSelector:@selector(startMoreLoading) withObject:nil afterDelay:0.0];
    }
}

@end
