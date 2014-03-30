//
//  PostViewController.m
//  HatenaHaiku
//
//  Created by koogawa on 2012/12/09.
//  Copyright (c) 2012年 Kosuke Ogawa. All rights reserved.
//

#import "PostViewController.h"
#import "AppDelegate.h"
#import "AuthManager.h"
#import "OAConsumer.h"
#import "OADataFetcher.h"
#import "OAMutableURLRequest.h"

@interface PostViewController ()

@end

@implementation PostViewController
{
    HaikuManager *_haikuManager;
}

#define CANCEL_ALERT_TAG    101
#define POST_ALERT_TAG      102
#define PIN_ALERT_TAG       103

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationController.navigationBar.tintColor = THEME_COLOR;

    // キャンセルボタン
    UIBarButtonItem *cancelButton =
    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                  target:self
                                                  action:@selector(cancelButtonAction)];
    self.navigationItem.leftBarButtonItem = cancelButton;
    
    // 地図ボタン
    UIBarButtonItem *mapButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"pin.png"]
                                                                  style:UIBarButtonItemStylePlain
                                                                 target:self
                                                                 action:@selector(pinButtonAction)];
    
    // カメラボタン
    UIBarButtonItem *cameraButton =
    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera
                                                  target:self
                                                  action:@selector(cameraButtonAction)];
    
    // 送信ボタン
    UIBarButtonItem *sendButton =
    [[UIBarButtonItem alloc] initWithTitle:@"Haiku!"
                                     style:UIBarButtonItemStyleDone
                                    target:self
                                    action:@selector(sendButtonAction)];
    
    self.navigationItem.rightBarButtonItems = @[sendButton, cameraButton, mapButton];

    _haikuManager = [HaikuManager sharedManager];
    _haikuManager.delegate = self;

    self.locationManager = [[CLLocationManager alloc] init];
    [self.locationManager setDelegate:self];
    [self.locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
    [self.locationManager setDistanceFilter:kCLDistanceFilterNone];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private Method

- (void)cancelButtonAction
{
    // ダイアログを表示しない設定ならすぐさま実行
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"CONFIG_DIALOG_CANCEL"])
    {
        [self dismissViewControllerAnimated:YES completion:nil];
        return;
    }
    
    UIAlertView *alert =
    [[UIAlertView alloc] initWithTitle:nil
                               message:@"入力された内容は保存されません。\nよろしいですか？"
                              delegate:self
                     cancelButtonTitle:@"いいえ"
                     otherButtonTitles:@"はい", nil];
    alert.tag = CANCEL_ALERT_TAG;
    [alert show];
}

- (void)pinButtonAction
{
    LOG_CURRENT_METHOD;
    
    // ダイアログを表示しない設定ならすぐさま実行
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"CONFIG_DIALOG_LOCATION"])
    {
        // 現在地取得
        [self.locationManager startUpdatingLocation];
        return;
    }
    
    UIAlertView *alert =
    [[UIAlertView alloc] initWithTitle:nil
                               message:@"本文に位置情報を挿入します。\nよろしいですか？"
                              delegate:self
                     cancelButtonTitle:@"いいえ"
                     otherButtonTitles:@"はい", nil];
    [alert setTag:PIN_ALERT_TAG];
    [alert show];
}

- (void)cameraButtonAction
{
    LOG_CURRENT_METHOD;
    
    UIActionSheet *sheet = [[UIActionSheet alloc] init];
	sheet.delegate = self;
    
    if (self.attachedImageView.image == nil)
    {
        [sheet addButtonWithTitle:@"写真を撮る"];
        [sheet addButtonWithTitle:@"ライブラリから選択する"];
        [sheet addButtonWithTitle:@"キャンセル"];
        
        sheet.cancelButtonIndex = 2;
    }
    else {
        [sheet addButtonWithTitle:@"写真を取り消す"];
        [sheet addButtonWithTitle:@"キャンセル"];
        
        sheet.destructiveButtonIndex = 0;
        sheet.cancelButtonIndex = 1;
    }
    
    [sheet showInView:self.view];
}

- (void)sendButtonAction
{
    LOG_CURRENT_METHOD;
    
    // 空チェック
    if ([self.bodyView.text length] == 0 && self.attachedImageView.image == nil)
    {
        [SVProgressHUD showErrorWithStatus:@"未入力エラー"];
        return;
    }
    
    // ダイアログを表示しない設定ならすぐさま実行
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"CONFIG_DIALOG_POST"])
    {
        [self post];
        return;
    }
    
    UIAlertView *alert =
    [[UIAlertView alloc] initWithTitle:nil
                               message:@"この内容で投稿します。\nよろしいですか？"
                              delegate:self
                     cancelButtonTitle:@"いいえ"
                     otherButtonTitles:@"はい", nil];
    alert.tag = POST_ALERT_TAG;
    [alert show];
}

- (void)removeAttachedImage
{
    LOG_CURRENT_METHOD;
    
    // アニメーション準備
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    [UIView setAnimationDuration:1.0];
    
    // 画像フェードイン
    self.attachedImageView.alpha = 0;
    
    // テキスト入力領域をもとに戻す
    self.bodyView.frame = CGRectMake(0, 0, self.tableView.frame.size.width, self.tableView.frame.size.height - TABLE_CELL_HEIGHT * 6);
    
    // 画像を表示する
    self.attachedImageView.image = nil;
    
    // アニメーション開始
    [UIView commitAnimations];
}

- (void)post
{
    LOG_CURRENT_METHOD;

    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [SVProgressHUD show];
    
    [[HaikuManager sharedManager] updateStatusWithKeyword:self.keywordField.text
                                                   status:self.bodyView.text
                                                inReplyTo:self.replyToField.text
                                                    image:self.attachedImageView.image];
}


#pragma mark - HaikuManager delegate

- (void)haikuManager:(HaikuManager *)manager didUpdateStatusWithData:(NSData *)data error:(NSError *)error
{
    LOG_CURRENT_METHOD;
    LOG(@"data = %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    
    // トークン切れチェック
    NSString *response = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if ([response isEqualToString:@"oauth_problem=token_rejected"])
    {
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate showLoginView];
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        [SVProgressHUD showSuccessWithStatus:@"ログイン期限が切れました"];
        
        return;
    }

    if (error == nil)
    {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        [SVProgressHUD showSuccessWithStatus:@"投稿しました"];

        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        [SVProgressHUD showErrorWithStatus:@"投稿できませんでした"];
    }
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    switch (section)
    {
        case 0:
            // リプライなら非表示
            return ((self.option)[@"in_reply_to"] > 0) ? 0 : 1;
            break;
            
        case 1:
            // リプライなら表示
            return ((self.option)[@"in_reply_to"] > 0) ? 1 : 0;
            break;
            
        case 2:
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
    
    static NSString *KeywordCellIdentifier = @"KeywordCell";
    static NSString *ReplyToCellIdentifier = @"ReplyToCell";
    static NSString *BodyCellIdentifier    = @"BodyCell";
    
    switch (indexPath.section)
    {
        case 0:
        {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:KeywordCellIdentifier];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:KeywordCellIdentifier];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                
                cell.textLabel.text = @"お題:";
                cell.textLabel.textColor = [UIColor grayColor];
                cell.textLabel.font = [UIFont systemFontOfSize:16];
                
                self.keywordField = [[UITextField alloc] initWithFrame:CGRectMake(80, 7, 240, 30)];
                self.keywordField.font = [UIFont systemFontOfSize:16];
                //textField.backgroundColor = [UIColor yellowColor];
                self.keywordField.borderStyle = UITextBorderStyleNone;
                self.keywordField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
                self.keywordField.placeholder = @"（省略可能）";
                self.keywordField.clearButtonMode = UITextFieldViewModeWhileEditing;
                self.keywordField.delegate = self;
                [cell.contentView addSubview:self.keywordField];
                
                // デフォルト指定があれば
                self.keywordField.text = (self.option)[@"keyword"];
            }
            
            return cell;
            break;
        }
            
        case 1:
        {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ReplyToCellIdentifier];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:ReplyToCellIdentifier];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                
                cell.textLabel.text = @"返信先:";
                cell.textLabel.textColor = [UIColor grayColor];
                cell.textLabel.font = [UIFont systemFontOfSize:16];
                
                self.replyToField = [[UITextField alloc] initWithFrame:CGRectMake(80, 7, 240, 30)];
                self.replyToField.font = [UIFont systemFontOfSize:16];
                self.replyToField.textColor = [UIColor grayColor];
                self.replyToField.borderStyle = UITextBorderStyleNone;
                self.replyToField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
                self.replyToField.placeholder = @"なし";
                self.replyToField.enabled = NO;
                self.replyToField.clearButtonMode = UITextFieldViewModeWhileEditing;
                self.replyToField.delegate = self;
                [cell.contentView addSubview:self.replyToField];
                
                // デフォルト指定があれば
                self.replyToField.text = (self.option)[@"in_reply_to"];
            }
            
            return cell;
            break;
        }
            
        case 2:
        {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:BodyCellIdentifier];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:BodyCellIdentifier];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                
                CGFloat height = [KGWUtil isOverThisVersion:@"7.0"] ? TABLE_CELL_HEIGHT * 6 + STATUS_BAR_HEIGHT + NAVI_VAR_HEIGHT : TABLE_CELL_HEIGHT * 6;
                CGRect rect = CGRectMake(0, 0, self.tableView.frame.size.width, self.tableView.frame.size.height - height);
                
                self.bodyView = [[UITextView alloc] initWithFrame:rect];
                self.bodyView.editable = YES;
                self.bodyView.font = [UIFont systemFontOfSize:16];
                [cell.contentView addSubview:self.bodyView];
                [self.bodyView performSelector:@selector(becomeFirstResponder) withObject:nil afterDelay:0.5];
                
                self.attachedImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.tableView.frame.size.width - 50 + 3, 3, 44, 44)];
                self.attachedImageView.alpha = 0;
                [cell.contentView addSubview:self.attachedImageView];
            }
            
            return cell;
            break;
        }
            
        default:
            break;
    }
    
    return nil;
}


#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section)
    {
        case 0:
        case 1:
            return TABLE_CELL_HEIGHT;
            break;
            
        case 2:
        {
            CGFloat height = [KGWUtil isOverThisVersion:@"7.0"] ? TABLE_CELL_HEIGHT * 6 + STATUS_BAR_HEIGHT + NAVI_VAR_HEIGHT - 4 : TABLE_CELL_HEIGHT * 6 - 4;
            return self.tableView.frame.size.height - height;
            break;
        }
            
        default:
            break;
    }
    
    return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
//    [textField resignFirstResponder];
    return YES;
}

#pragma mark - UIActionSheet Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    LOG(@"buttonIndex %d", buttonIndex);
    
    // ソースタイプを決定する
    UIImagePickerControllerSourceType sourceType = 0;
    
    if (self.attachedImageView.image == nil)
    {
        switch (buttonIndex)
        {
            case 0:
            {
                sourceType = UIImagePickerControllerSourceTypeCamera;
                break;
            }
            case 1:
            {
                sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                break;
            }
            case 2:
            {
                return;
                break;
            }
        }
    }
    else {
        switch (buttonIndex)
        {
            case 0:
            {
                [self removeAttachedImage];
                return;
                break;
            }
            case 1:
            {
                return;
                break;
            }
        }
    }
    
    // 使用可能かどうかチェックする
    if (![UIImagePickerController isSourceTypeAvailable:sourceType]) {
        return;
    }
    
    // イメージピッカーを作る
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.sourceType = sourceType;
    imagePicker.delegate = self;
    
    // イメージピッカーを表示する
    [self presentViewController:imagePicker animated:YES completion:nil];
}

#pragma mark - UIAlertView delegate

- (void)alertView:(UIAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	LOG(@"buttonIndex = %d", buttonIndex);
    
    switch (alertView.tag)
    {
        case CANCEL_ALERT_TAG:
        {
            if (buttonIndex == 1)
            {
                [self dismissViewControllerAnimated:YES completion:nil];
            }
            break;
        }
            
        case POST_ALERT_TAG:
        {
            if (buttonIndex == 1)
            {
                [self post];
            }
            break;
        }
            
        case PIN_ALERT_TAG:
        {
            if (buttonIndex == 1)
            {
                // 現在地取得
                [self.locationManager startUpdatingLocation];
            }
            break;
        }
            
        default:
            break;
    }
}

#pragma mark - CLLocationManager delegate

// 位置が更新されたら呼ばれる
- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
		   fromLocation:(CLLocation *)oldLocation
{
    LOG_CURRENT_METHOD;
    
    [self.locationManager stopUpdatingLocation];
    
    // map記法を生成
    NSString *mapString = [NSString stringWithFormat:@"map:%f:%f", newLocation.coordinate.latitude, newLocation.coordinate.longitude];
    
    // 本文の文末に挿入
    NSString *bodyString = self.bodyView.text;
    bodyString = [NSString stringWithFormat:@"%@\n\n%@", bodyString, mapString];
    self.bodyView.text = bodyString;
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
    LOG_CURRENT_METHOD;
    
    [SVProgressHUD showErrorWithStatus:@"位置情報を取得できませんでした"];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    LOG_CURRENT_METHOD;
    
    // イメージピッカーを隠す
    [self dismissViewControllerAnimated:YES completion:nil];
    
    // アニメーション準備
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    [UIView setAnimationDuration:1.0];
    
    // 画像フェードイン
    self.attachedImageView.alpha = 1;
    
    // テキスト入力領域を縮める
    self.bodyView.frame = CGRectMake(0, 0, self.tableView.frame.size.width - 50, self.tableView.frame.size.height - TABLE_CELL_HEIGHT * 6);
    
    // オリジナル画像を取得する
    UIImage *originalImage;
    originalImage = info[UIImagePickerControllerOriginalImage];
    //LOG(@"size = %@", NSStringFromCGSize(originalImage.size));
    
    // 長辺をMAX_IMAGE_SIZEに縮小する
	CGSize originalSize = originalImage.size;
	CGFloat ratio = 0;
	if (originalSize.width > originalSize.height) {
		// 横長なので横幅で比率計算
		ratio = MAX_IMAGE_SIZE / originalSize.width;
	} else {
		// 縦長
		ratio = MAX_IMAGE_SIZE / originalSize.height;
	}
    
    // もともとMAX_IMAGE_SIZE以下なら比率はそのまま
    if (ratio > 1.0) ratio = 1.0;
    //LOG(@"ratio = %f", ratio);

    // グラフィックスコンテキストを作る
    CGSize size = CGSizeMake(ratio * originalSize.width, ratio * originalSize.height);
    //LOG(@"size = %@", NSStringFromCGSize(size));
    UIGraphicsBeginImageContext(size);
    
    // 画像を縮小して描画する
    CGRect rect;
    rect.origin = CGPointZero;
    rect.size = size;
    [originalImage drawInRect:rect];
    
    // 描画した画像を取得する
    UIImage *shrinkedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // 画像を表示する
    self.attachedImageView.image = shrinkedImage;
    
    // アニメーション開始
    [UIView commitAnimations];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController*)picker
{
    LOG_CURRENT_METHOD;
    
    // イメージピッカーを隠す
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
