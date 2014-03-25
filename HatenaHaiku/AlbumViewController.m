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
#import "HttpClient.h"

@interface AlbumViewController ()

@end

@implementation AlbumViewController

#define MORE_FOOTER_HEIGHT          52.0f
#define FETCH_ALBUM_NOTIFICATION    @"fetchAlbumFromAlbumTab"

- (id)initWithCollectionViewLayout:(UICollectionViewLayout *)layout
{
    self = [super initWithCollectionViewLayout:layout];
    if (self) {
        // Custom initialization
        self.title = @"アルバム";
        self.tabBarItem.image = [UIImage imageNamed:@"album.png"];
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
    self.collectionView.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];
    self.collectionView.backgroundColor = [UIColor whiteColor];
    
    // contentViewにcellのクラスを登録
    [self.collectionView registerClass:[AlbumCollectionCell class] forCellWithReuseIdentifier:@"MY_CELL"];
    
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
    
    NSString *urlString = [NSString stringWithFormat:@"http://h.hatena.ne.jp/api/statuses/album.json?count=40&page=%d&body_formats=api", self.page];
    NSURL *url = [NSURL URLWithString:urlString];
    
    HttpClient *client = [[HttpClient alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(fetchAlbumDidFinish:)
                                                 name:FETCH_ALBUM_NOTIFICATION
                                               object:client];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [SVProgressHUD show];
    
    [client sendRequestWithURL:url method:@"GET" name:FETCH_ALBUM_NOTIFICATION];
}

#pragma mark - Override method

- (void)loadMore
{
    LOG_CURRENT_METHOD;
    
    [self fetchAlbum];
}

#pragma mark - API Callback

// アルバムリストが取れた
- (void)fetchAlbumDidFinish:(NSNotification *)notification
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
	
    HttpClient *client = (HttpClient *)[notification object];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:FETCH_ALBUM_NOTIFICATION
                                                  object:client];
    
    if (client.error == nil)
    {
        NSData *jsonData = client.data;
        NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
        //LOG(@"jsonArray %@", jsonArray);
        
        if ([jsonArray count] == 0)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                            message:@"データがありません"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
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
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"エラー"
                                                        message:@"取得できませんでした"
                                                       delegate:nil
                                              cancelButtonTitle:@"Close"
                                              otherButtonTitles:nil];
        [alert show];
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
    AlbumCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MY_CELL" forIndexPath:indexPath];
    
    NSString *urlString = [[self.statuses objectAtIndex:indexPath.item] objectForKey:@"text"];
    urlString = [[urlString componentsSeparatedByString:@"="] lastObject];
    urlString = [[urlString componentsSeparatedByString:@"\n"] objectAtIndex:0];
    
    [cell.albumImageView loadImageUrl:[NSURL URLWithString:urlString]];
//    [cell.albumImageView setFrame:CGRectMake(3, 3, cell.frame.size.width - 6, cell.frame.size.height - 6)];
    return cell;
}

#pragma mark -
#pragma mark UICollectionViewDelegateFlowLayout

// セルのサイズを画像ごとに調整
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
//    NSString *urlString = [[self.statuses objectAtIndex:indexPath.item] objectForKey:@"text"];
//    urlString = [[urlString componentsSeparatedByString:@"="] lastObject];
//    urlString = [[urlString componentsSeparatedByString:@"\n"] objectAtIndex:0];
//
//    AsyncImageView *imageView = [[AsyncImageView alloc] init];
//    [imageView loadImageUrl:[NSURL URLWithString:urlString] async:YES];

    // サイズが大きいので縮小してる
    //    return CGSizeMake(imageView.image.size.width / 5, imageView.image.size.height / 5);
    
    return CGSizeMake(79, 79);
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
//    return UIEdgeInsetsMake(15.0f, 15.0f, 15.0f, 15.0f);
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    LOG_CURRENT_METHOD;
    
    DetailViewController *detailViewController = [[DetailViewController alloc] initWithStyle:UITableViewStylePlain];
    detailViewController.statusId = [[self.statuses objectAtIndex:indexPath.row] objectForKey:@"id"];
    [self.navigationController pushViewController:detailViewController animated:YES];
}

@end
