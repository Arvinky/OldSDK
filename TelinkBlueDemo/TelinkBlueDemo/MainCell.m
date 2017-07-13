//
//  MainCell.m
//  TelinkBlueDemo
//
//  Created by telink on 15/12/12.
//  Copyright © 2015年 Green. All rights reserved.
//

#import "MainCell.h"

@implementation MainCell


-(void)descriptionWith:(LightData *)tempdata{
    
    
    /**
      *
     
     //        LightData *tempData=[dataArrs objectAtIndex:indexPath.row];
     //        NSString *tempImgName=@"icon_light_offline";
     //
     /
     //  *灯的状态的回调
     //  */
    //        if (tempData.lightStatus==1)
    //            tempImgName=@"icon_light_off";
    //        else if (tempData.lightStatus==2)
    //        tempImgName=@"icon_light_on";
    //        tempCell.imgView.image=[UIImage imageNamed:tempImgName];
    //        tempCell.imgView.tag=indexPath.row;
    //        tempCell.titleLab.text=[NSString stringWithFormat:@"%0x",tempData.devAress];
    //        if ((tempData.devAress == [BTCentralManager shareBTCentralManager].selConnectedItem.u_DevAdress)) {
    //            tempCell.titleLab.textColor = [UIColor redColor];
    //        }else{
    //            tempCell.titleLab.textColor = [UIColor blackColor];
    //        }

    self.tintColor = [UIColor redColor];
    
    }



@end
