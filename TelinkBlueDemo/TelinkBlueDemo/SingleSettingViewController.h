//
//  SingleSettingViewController.h
//  TelinkBlueDemo
//
//  Created by Ken on 11/27/15.
//  Copyright © 2015 Green. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DeviceModel;
@class BTDevItem;
@interface SingleSettingViewController : UIViewController

@property (nonatomic, assign, getter=isGroup) BOOL isGroup;
@property(nonatomic,strong)BTDevItem *btItem;

@property (nonatomic, assign) int32_t groupAdr;
@property (nonatomic, strong) DeviceModel *selData;
@property (nonatomic,strong) IBOutlet  UISlider *brightSlider;
@property (nonatomic,strong) IBOutlet  UISlider *tempSlider;

-(IBAction)brightValueChange:(id)sender;
-(IBAction)tempValueChange:(id)sender;

-(IBAction)addToGroupClick:(id)sender;
-(IBAction)removeFromGroupClick:(id)sender;

@end
