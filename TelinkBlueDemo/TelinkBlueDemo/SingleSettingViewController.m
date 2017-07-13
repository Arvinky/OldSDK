//
//  SingleSettingViewController.m
//  TelinkBlueDemo
//
//  Created by Ken on 11/27/15.
//  Copyright © 2015 Green. All rights reserved.
//

#import "SingleSettingViewController.h"
#import "DTColorPickerImageView.h"
#import "SingleSettingViewController.h"
#import "BTCentralManager.h"
#import "BTDevItem.h"
#import "LightData.h"
#import "ChooseGroupViewController.h"
#import "FileChooseController.h"
#import "DemoDefine.h"
#import "ARMainVC.h"

static NSUInteger addIndex;
@interface SingleSettingViewController () <DTColorPickerImageViewDelegate>

@property (atomic, assign) int lastBright;
@property (atomic, strong) UIColor *lastColor;
@property (atomic, assign) int lastTemp;
@property (nonatomic, strong) NSTimer *sendCmdTimer;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *addH;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *ctH;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cbH;

@end

@implementation SingleSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self normalSetting];
}
- (void)normalSetting {
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(backClick:)];
    
    self.navigationItem.leftBarButtonItem=leftButton;
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"OTA" style:UIBarButtonItemStylePlain target:self action:@selector(oTAClick:)];
    self.navigationItem.rightBarButtonItem=rightButton;
    self.navigationItem.title = @"设置";
    self.lastBright=-1;
    self.lastTemp=-1;
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = YES;
    CGRect rect = kDelegate.logBtn.frame;
    CGFloat h = rect.origin.y+49;
    kDelegate.logBtn.frame = CGRectMake(rect.origin.x, h, rect.size.width, rect.size.height);
    if (kMScreenH<667) {
        self.addH.constant = 36;
        self.ctH.constant = 32;
        self.cbH.constant = 32;
    }else{
        self.addH.constant = 50;
        self.ctH.constant = 50;
        self.cbH.constant = 50;
    }
    [self.view setNeedsLayout];
    self.brightSlider.value = self.selData.brightness;
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    CGRect rect = kDelegate.logBtn.frame;
    CGFloat h = rect.origin.y-49;
    kDelegate.logBtn.frame = CGRectMake(rect.origin.x, h, rect.size.width, rect.size.height);
}
-(void)backClick:(id)sender {
    [self.sendCmdTimer invalidate];

    [self.navigationController popViewControllerAnimated:YES];
}

-(void)logByte:(uint8_t *)bytes Len:(int)len Str:(NSString *)str
{
    NSMutableString *tempMStr=[[NSMutableString alloc] init];
    for (int i=0;i<len;i++)
        [tempMStr appendFormat:@"%0x  ",bytes[i]];
    NSLog(@"%@ == %@",str,tempMStr);
}


- (void)imageView:(DTColorPickerImageView *)imageView didPickColorWithColor:(UIColor *)color {
    CGFloat red, green, blue;
    [color getRed:&red green:&green blue:&blue alpha:NULL];
    if (self.isGroup) {
        if (self.groupAdr==0)   return;
        [kCentralManager setLightOrGroupRGBWithDestinateAddress:self.selData.u_DevAdress WithColorR:red WithColorG:green WithB:blue];
    }
    else
    {
        if (!self.selData)
            return;
        uint8_t cmd[14]={0x11,0x11,0x11,0x00,0x00,0x66,0x00,0xe2,0x11,0x02,0x04,0x0,0x0,0x0};
        cmd[5]=(self.selData.u_DevAdress>>8) & 0xff;
        cmd[6]=self.selData.u_DevAdress & 0xff;
        cmd[2]=cmd[2]+addIndex;
        if (cmd[2]==254) {
            cmd[2]=1;
        }
        addIndex++;
        cmd[11]=red*255.f;
        cmd[12]=green*255.f;
        cmd[13]=blue*255.f;
        
        [self logByte:cmd Len:11 Str:@"RGB"];
        [kCentralManager sendCommand:cmd Len:14];
    }
}

-(IBAction)brightValueChange:(UISlider *)sender {
    if (self.selData.stata==LightStataTypeOff&&sender.value>0) {
        [kCentralManager turnOnCertainLightWithAddress:self.selData.u_DevAdress];
    }else if (self.selData.stata==LightStataTypeOn&&sender.value==0) {
        [kCentralManager turnOffCertainLightWithAddress:self.selData.u_DevAdress];
        return;
    }
    if (self.isGroup) {
        if (self.groupAdr==0) return;
        uint8_t cmd[13]={0x11,0x61,0x21,0x00,0x00,0x66,0x00,0xd2,0x11,0x02,0x0A};
        cmd[5]=self.groupAdr & 0xff;
        cmd[6]=(self.groupAdr>>8) & 0xff;
        cmd[10]=sender.value;
        [self logByte:cmd Len:11 Str:@"亮度"];
        [kCentralManager sendCommand:cmd Len:11];
    } else {
        if (!self.selData) return;
        [kCentralManager setLightOrGroupLumWithDestinateAddress:self.selData.u_DevAdress WithLum:sender.value];
    }
}

-(IBAction)tempValueChange:(UISlider *)sender
{
    if (self.isGroup) {
        if (self.groupAdr==0) return;
        
        uint8_t cmd[12]={0x11,0x80,0x21,0x00,0x00,0x66,0x00,0xe2,0x11,0x02,0x05,0x0};
        cmd[2]=cmd[2]+addIndex;
        if (cmd[2]==254) {
            cmd[2]=1;
        }
        
        addIndex++;
        cmd[5]=self.groupAdr & 0xff;
        cmd[6]=(self.groupAdr>>8) & 0xff;
        cmd[10]=sender.value;
        [self logByte:cmd Len:12 Str:@"色温"];
        [kCentralManager sendCommand:cmd Len:12];
    } else {
        if (!self.selData)  return;
        [kCentralManager setCTOfLightWithDestinationAddress:self.selData.u_DevAdress AndCT:sender.value];
    }
}
- (IBAction)quit:(UIButton *)sender {
    [[BTCentralManager shareBTCentralManager]kickoutLightFromMeshWithDestinateAddress:self.selData.u_DevAdress];
    [self.navigationController popViewControllerAnimated:YES];
}


-(IBAction)addToGroupClick:(id)sender
{
    ChooseGroupViewController *tempCon=[[ChooseGroupViewController alloc] init];
    tempCon.isRemove=NO;
    tempCon.selData=self.selData;
    [self.navigationController pushViewController:tempCon animated:YES];
}

-(IBAction)removeFromGroupClick:(id)sender
{
    ChooseGroupViewController *tempCon=[[ChooseGroupViewController alloc] init];
    tempCon.isRemove=YES;
    tempCon.selData=self.selData;
    [self.navigationController pushViewController:tempCon animated:YES];
}

-(void)oTAClick:(id)sender{
    FileChooseController *fileChoose = [[FileChooseController alloc]init];
    fileChoose.u_address = self.selData.u_DevAdress;
    [self.navigationController pushViewController:fileChoose animated:YES];

}
@end
