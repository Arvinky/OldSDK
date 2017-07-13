//
//  AppDelegate.m
//  TelinkBlueDemo
//
//  Created by Green on 11/22/15.
//  Copyright (c) 2015 Green. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()
@end
@implementation AppDelegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window=[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor=[UIColor whiteColor];
    self.window.rootViewController=[[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"RootVC"];
    [self.window makeKeyAndVisible];
    return YES;
}

- (UIButton *)logBtn {
    if (!kTestLog) return nil;
    if (!_logBtn) {
        _logBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_logBtn setTitle:@"Log" forState:UIControlStateNormal];
        _logBtn.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height-89, [UIScreen mainScreen].bounds.size.width, 40);
        
        _logBtn.backgroundColor = [UIColor colorWithRed:(178./255) green:200./255 blue:187./255 alpha:1];
        _logBtn.titleLabel.font = [UIFont systemFontOfSize:10];
        [[UIApplication sharedApplication].windows[0] addSubview:_logBtn];
        
        [_logBtn addTarget:self action:@selector(showLogHH) forControlEvents:UIControlEventTouchUpInside];
        
        [[BTCentralManager shareBTCentralManager] setPrintBlock:^(NSString *tip) {
            [_logBtn setTitle:tip forState:UIControlStateNormal];
            [_logBtn setNeedsDisplay];
        }];
    }
    return _logBtn;
}
- (void)showLogHH {
    _logBtn.selected = !_logBtn.selected;
    if (_logBtn.selected) {
        self.logVC = [[LogVC alloc] init];
        UITabBarController *navi  = (UITabBarController *)[UIApplication sharedApplication].keyWindow.rootViewController;
        [navi presentViewController:self.logVC animated:YES completion:nil];
    }else{
        [self.logVC dismissViewControllerAnimated:NO completion:nil];
    }
}
@end
