//
//  SettingViewController.h
//  TelinkBlueDemo
//
//  Created by Ken on 11/25/15.
//  Copyright © 2015 Green. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingViewController : UIViewController

@property (nonatomic,strong) IBOutlet UITextField *oNameTxt;
@property (nonatomic,strong) IBOutlet UITextField *oPasswordTxt;

@property (nonatomic,strong) IBOutlet UITextField *nNameTxt;
@property (nonatomic,strong) IBOutlet UITextField *nPasswordTxt;

//输入框约束

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *TextTransition;
//平常情况为80



-(IBAction)saveBtnClick:(id)sender;
@end
