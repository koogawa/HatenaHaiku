//
//  PostViewController.h
//  HatenaHaiku
//
//  Created by koogawa on 2012/12/09.
//  Copyright (c) 2012年 Kosuke Ogawa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "HaikuManager.h"

@interface PostViewController : UITableViewController <UITextFieldDelegate, UINavigationControllerDelegate, CLLocationManagerDelegate, UIImagePickerControllerDelegate, HaikuManagerDelegate>

@property (nonatomic, retain) NSDictionary  *option;
@property (nonatomic, retain) UITextField   *keywordField;
@property (nonatomic, retain) UITextField   *replyToField;
@property (nonatomic, retain) UITextView    *bodyView;
@property (nonatomic, retain) UIImageView   *attachedImageView;

@property (nonatomic, retain) CLLocationManager *locationManager;

@end
