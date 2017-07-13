//
//  GroupCell.h
//  TelinkBlueDemo
//
//  Created by Arvin on 2017/4/12.
//  Copyright © 2017年 Green. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GroupCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UISwitch *turnOn;
@property (assign, nonatomic) uint32_t groupID;
@end
