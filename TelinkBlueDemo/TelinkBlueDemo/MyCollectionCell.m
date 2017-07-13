//
//  MyCollectionViewCell.m
//  TelinkBlueDemo
//
//  Created by Green on 11/22/15.
//  Copyright (c) 2015 Green. All rights reserved.
//

#import "MyCollectionCell.h"
#import "BTCentralManager.h"
#import "BTDevItem.h"

@interface MyCollectionCell()
@end

@implementation MyCollectionCell
- (void)updateState:(DeviceModel *)model {
    NSString *tempImgName = nil;
    switch (model.stata) {
        case LightStataTypeOutline:         tempImgName  =@"icon_light_offline"; break;
        case LightStataTypeOff:                tempImgName=@"icon_light_off";        break;
        case LightStataTypeOn:                tempImgName=@"icon_light_on";        break;
        default: break;
    }
    self.imgView.image = [UIImage imageNamed:tempImgName];
    self.titleLab.text = [NSString stringWithFormat:@"%02X:%ld", model.u_DevAdress>>8, model.brightness];
    BOOL ret = [BTCentralManager shareBTCentralManager].selConnectedItem.u_DevAdress==model.u_DevAdress;
    self.titleLab.textColor = ret?[UIColor redColor] : [UIColor blackColor];
}


@end
