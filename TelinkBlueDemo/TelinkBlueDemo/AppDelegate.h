//
//  AppDelegate.h
//  TelinkBlueDemo
//
//  Created by Green on 11/22/15.
//  Copyright (c) 2015 Green. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SettingViewController.h"
#define kDuration @"Duration"
#import "BTCentralManager.h"
#import "LogVC.h"
#define  kDelegate ((AppDelegate *)[UIApplication sharedApplication].delegate)
@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property(nonatomic,strong)SettingViewController *settingVC;
@property (nonatomic, strong)UIButton *logBtn;
@property (nonatomic, strong) LogVC *logVC;
@end

