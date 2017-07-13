//
//  LogVC.m
//  TelinkBlueDemo
//
//  Created by Arvin on 2017/3/23.
//  Copyright © 2017年 Green. All rights reserved.
//

#import "LogVC.h"
#import "DemoDefine.h"
@interface LogVC ()
@property (nonatomic, weak) UITextView *logText;
@property (nonatomic, strong) UIButton *btn;
@end

@implementation LogVC
- (UIButton *)btn {
    if (!_btn) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setTitle:@"Clear" forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        btn.backgroundColor = [UIColor colorWithRed:(69./255) green:137./255 blue:148./255 alpha:1];
        btn.titleLabel.font = [UIFont systemFontOfSize:10];
        [btn addTarget:self action:@selector(clearLocal) forControlEvents:UIControlEventTouchUpInside];
        btn.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height-49, [UIScreen mainScreen].bounds.size.width, 49);
        _btn = btn;
    }
    return _btn;
}
- (UITextView *)logText {
    if (!_logText) {
        UITextView *text = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-89)];
        text.editable = NO;
        _logText = text;
    }
    return _logText;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self normalSetting];
}
- (void)normalSetting {
    [self.view addSubview:self.logText];
    [self.view addSubview:self.btn];
    self.tabBarController.tabBar.hidden = YES;
    [self updateContent];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    self.tabBarController.tabBar.hidden = YES;
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.tabBarController.tabBar.hidden = NO;
    self.navigationController.navigationBarHidden = NO;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}
- (void)updateContent {
    dispatch_queue_t quene = dispatch_queue_create(DISPATCH_QUEUE_PRIORITY_DEFAULT, NULL);
    dispatch_async(quene, ^{
        NSData *data = [NSData dataWithContentsOfFile:kDocumentFilePath(@"content")];
        NSMutableString *temp = [[NSMutableString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.logText.text = temp;
            self.logText.scrollsToTop = NO;
            [self.view setNeedsDisplay];
        });
    });
}
- (void)clearLocal {
    NSString *contentS = @"";
    NSData *tempda = [contentS dataUsingEncoding:NSUTF8StringEncoding];
    [tempda writeToFile:kDocumentFilePath(@"content") atomically:YES];
    [self updateContent];
}


@end
