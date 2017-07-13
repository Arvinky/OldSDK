//
//  SettingViewController.m
//  TelinkBlueDemo
//
//  Created by Ken on 11/25/15.
//  Copyright © 2015 Green. All rights reserved.
//

#import "SettingViewController.h"
#import "BTCentralManager.h"
#import "SysSetting.h"
#import "AppDelegate.h"
#import "ARMainVC.h"
@interface SettingViewController ()<UITextFieldDelegate>

//VenderID  输入口
@property (weak, nonatomic) IBOutlet UITextField *VenderIDTextField;


//@property (weak, nonatomic) IBOutlet UITextField *timerInterval;
@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    self.timerInterval.placeholder = [NSString stringWithFormat:@"%@ms",[[NSUserDefaults standardUserDefaults] objectForKey:kDuration]];
//    [[NSUserDefaults standardUserDefaults] synchronize];
    // Do any additional setup after loading the view from its nib.
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyboardHide:)];
    tapGestureRecognizer.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapGestureRecognizer];
    self.oNameTxt.delegate = self;
    self.oPasswordTxt.delegate = self;
    [self fillData];
}
-(void)keyboardHide:(UITapGestureRecognizer*)tap{
    [self.view endEditing:YES];
}


-(NSString *)getNonullStr:(NSString *)getStr
{
    if (!getStr || getStr.length<1)
        return @"";
    
    return getStr;
}

-(void)fillData
{
    [self.oNameTxt setText:[SysSetting shareSetting].oUserName];
    [self.oPasswordTxt setText:[SysSetting shareSetting].oUserPassword];
    [self.nNameTxt setText:[SysSetting shareSetting].nUserName];
    [self.nPasswordTxt setText:[SysSetting shareSetting].nUserPassword];
}
-(void)saveData
{
    SysSetting *selSeting=[SysSetting shareSetting];
    selSeting.oUserName=[self.oNameTxt text];
    selSeting.oUserPassword=[self.oPasswordTxt text];
    selSeting.nUserName=[self.nNameTxt text];
    selSeting.nUserPassword=[self.nPasswordTxt text];
}

-(IBAction)saveBtnClick:(id)sender {
    [self saveData];
    [SysSetting saveSetting];
    NSArray *ar = self.parentViewController.childViewControllers;
    for (int i=0; i<ar.count; i++) {
        UIViewController *v = ar[i];
        if ([v isKindOfClass:[ARMainVC class]]) {
            ARMainVC *vc = (ARMainVC *)v;
            vc.isNeedRescan = YES;
            if (vc.UpdateMeshInfo) {
                vc.UpdateMeshInfo(self.oNameTxt.text, self.oPasswordTxt.text);
            }
        }
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}
- (void)textFieldDidBeginEditing:(UITextField *)textField{
    if (textField == self.oNameTxt || textField == self.oPasswordTxt ) {
        self.TextTransition.constant = -10.f;
}else{
        self.TextTransition.constant = 80.f;    
    }
}
- (void)textFieldDidEndEditing:(UITextField *)textField{
    self.TextTransition.constant = 80.f;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear: animated];
    self.navigationController.navigationBarHidden = YES;
    self.tabBarController.tabBar.hidden = YES;
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.tabBarController.tabBar.hidden = NO;
}


@end
