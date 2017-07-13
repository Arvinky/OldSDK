//
//  ChooseGroupViewController.h
//  TelinkBlueDemo
//
//  Created by Ken on 11/30/15.
//  Copyright © 2015 Green. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DeviceModel;

@interface ChooseGroupViewController : UITableViewController
{
}
@property (nonatomic,strong) DeviceModel *selData;
@property (nonatomic,assign) BOOL isRemove;
@end
