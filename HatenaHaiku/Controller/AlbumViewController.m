//
//  AlbumViewController.m
//  HatenaHaiku
//
//  Created by koogawa on 2013/02/12.
//  Copyright (c) 2013年 Kosuke Ogawa. All rights reserved.
//

#import "AlbumViewController.h"
#import "DetailViewController.h"
#import "AlbumCollectionCell.h"

@interface AlbumViewController ()

@end

@implementation AlbumViewController

#define MORE_FOOTER_HEIGHT          52.0f

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super initWithCoder:decoder];
    if (self) {
        // Custom initialization
        self.page = 1;
        self.statuses = [[NSMutableArray alloc] init];
    }

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationController.navigationBar.tintColor = THEME_COLOR;
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshOccured:) forControlEvents:UIControlEventValueChanged];
    [self.collectionView addSubview:self.refreshControl];
    
    // 背景を設定
    self.collectionView.backgroundColor = [UIColor whiteColor];
    
    // contentViewにcellのクラスを登録
    [self.collectionView registerClass:[AlbumCollectionCell class] forCellWithReuseIdentifier:@"Cell"];

    _haikuManager = [[HaikuManager alloc] init];
    _haikuManager.delegate = self;

    [SVProgressHUD show];
    [self fetchAlbum];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private method

- (void)refreshOccured:(id)sender
{
    LOG_CURRENT_METHOD;
    
    self.page = 1;
    
    [self fetchAlbum];
}

// アルバムリストを取得
- (void)fetchAlbum
{
    LOG_CURRENT_METHOD;

    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;

    [_haikuManager fetchAlbumWithPage:self.page];
}

#pragma mark - Override method

- (void)loadMore
{
    LOG_CURRENT_METHOD;
    
    [self fetchAlbum];
}

#pragma mark - HaikuManager delegate

// アルバムリストが取れた
- (void)haikuManager:(HaikuManager *)manager didFetchAlbumWithData:(NSData *)data error:(NSError *)error
{
    LOG_CURRENT_METHOD;
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [SVProgressHUD dismiss];
    
    // リロード中か？更に読込中か？
    if (self.page == 1) {
        [self.refreshControl endRefreshing];
    }
    else {
        [self stopMoreLoading];
    }
	
    if (error == nil)
    {
        NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        
        if ([jsonArray count] == 0)
        {
            UIAlertController *alertController =
            [UIAlertController alertControllerWithTitle:ERROR_TITLE
                                                message:NO_DATA_MESSAGE
                                         preferredStyle:UIAlertControllerStyleAlert];
            [alertController addAction:[UIAlertAction actionWithTitle:OK_BUTTON_TITLE
                                                                style:UIAlertActionStyleCancel
                                                              handler:nil]];
            [self presentViewController:alertController
                               animated:YES
                             completion:nil];
        }

        // 結果取得
        if (self.page == 1)
        {
            // 最初から読み込む場合は一度配列を空にする
            [self.statuses removeAllObjects];
            self.statuses = [NSMutableArray arrayWithArray:jsonArray];
        }
        else {
            [self.statuses addObjectsFromArray:jsonArray];
        }
        
        // 読み込み位置更新
        self.page++;
        
        [self.collectionView reloadData];
    }
    else {
        UIAlertController *alertController =
        [UIAlertController alertControllerWithTitle:ERROR_TITLE
                                            message:FETCH_ERROR_MESSAGE
                                     preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:OK_BUTTON_TITLE
                                                            style:UIAlertActionStyleCancel
                                                          handler:nil]];
        [self presentViewController:alertController
                           animated:YES
                         completion:nil];
        return;
    }
}

#pragma mark -
#pragma mark UICollectionViewDataSource

// セクション数
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

// セルの数
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.statuses count];
}

// コレクションビューのセルを生成
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    AlbumCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    
    NSString *urlString = (self.statuses)[indexPath.item][@"text"];
    urlString = [[urlString componentsSeparatedByString:@"="] lastObject];
    urlString = [urlString componentsSeparatedByString:@"\n"][0];
    
    [cell.albumImageView loadImageUrl:[NSURL URLWithString:urlString]];
    return cell;
}

#pragma mark -
#pragma mark UICollectionViewDelegateFlowLayout

// セルのサイズを画像ごとに調整
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat width = (self.collectionView.frame.size.width - 8.0) / 4;
    return CGSizeMake(width, width);
}

// 横の画像との最小スペース
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}

// 縦の画像との最小スペース
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}

// 上下左右の余白
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(2, 2, 2, 2);
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    LOG_CURRENT_METHOD;
    
    DetailViewController *detailViewController = [[DetailViewController alloc] initWithStyle:UITableViewStylePlain];
    detailViewController.statusId = (self.statuses)[indexPath.row][@"id"];
    [self.navigationController pushViewController:detailViewController animated:YES];
}

@end
