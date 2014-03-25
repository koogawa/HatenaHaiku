//
//  ReplyViewController.m
//  HatenaHaiku
//
//  Created by koogawa on 2013/03/21.
//  Copyright (c) 2013年 Kosuke Ogawa. All rights reserved.
//

#import "ReplyViewController.h"

@interface ReplyViewController ()

@end

@implementation ReplyViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // 入力欄にフォーカス
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:2];
    [self.tableView scrollToRowAtIndexPath:indexPath
                          atScrollPosition:UITableViewScrollPositionTop
                                  animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    switch (section)
    {
        case 0:
            // プレビュー
            return 1;
            break;
            
        case 1:
            // 返信先
            return 1;
            break;
            
        case 2:
            // 本文
            return 1;
            break;
            
        default:
            break;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LOG_CURRENT_METHOD;
    
    static NSString *PreviewCellIdentifier = @"PreviewCell";
    
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    
    switch (indexPath.section)
    {
        case 0:
        {
            StatusTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:PreviewCellIdentifier];
            if (cell == nil) {
                cell = [[StatusTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:PreviewCellIdentifier];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.delegate = self;
            }
            
            // プロフィールアイコン
            NSString *profileImageUrlString = [self.option objectForKey:@"profile_image_url"];
            [cell.profileImageView loadImageUrl:[NSURL URLWithString:profileImageUrlString]];
            
            // HTML生成
            NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
            NSURL *baseURL = [NSURL fileURLWithPath:bundlePath];
            NSString *html = [self.option objectForKey:@"html"];
            [cell.bodyWebView loadHTMLString:html baseURL:baseURL];
            cell.bodyWebView.userInteractionEnabled = NO;
            
            return cell;
            break;
        }
            
        default:
            break;
    }
    
    return cell;
}


#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section)
    {
        case 0:
        {
            // TODO: このへん一箇所にまとめたいなぁ
            NSString *html = [self.option objectForKey:@"html"];
            
            // <A>タグ除去
            NSRange r;
            while ((r = [html rangeOfString:@"<a [^>]+>" options:NSRegularExpressionSearch]).location != NSNotFound)
                html = [html stringByReplacingCharactersInRange:r withString:@""];
            //LOG(@"stripped html = %@", html);
            
            UIFont *font = [UIFont systemFontOfSize:16];
            CGSize size = CGSizeMake(251, CGFLOAT_MAX);
            CGSize textSize = [html sizeWithFont:font constrainedToSize:size lineBreakMode:NSLineBreakByWordWrapping];
            
            // <br> の数
            NSArray *portions = [html componentsSeparatedByString:@"<br>"];
            NSUInteger brCount = [portions count] - 1;
            
            // <p> の数
            portions = [html componentsSeparatedByString:@"<p>"];
            NSUInteger pCount = [portions count] - 1;
            
            return textSize.height + brCount*20 + pCount*20;
            break;
        }
            
        case 1:
            return TABLE_CELL_HEIGHT;
            break;
            
        case 2:
        {
            CGFloat height = [KOUtil isOverThisVersion:@"7.0"] ? TABLE_CELL_HEIGHT * 6 + STATUS_BAR_HEIGHT + NAVI_VAR_HEIGHT - 4 : TABLE_CELL_HEIGHT * 6 - 4;
            return self.tableView.frame.size.height - height;
            break;
        }
            
        default:
            break;
    }
    
    return 0;
}


#pragma mark - StatusTableViewCellDelegate

-(void)statusViewCell:(StatusTableViewCell *)cell linkDidTap:(NSURL *)url
{
    LOG_CURRENT_METHOD;
    
    // なんもせぇへん
}

@end
