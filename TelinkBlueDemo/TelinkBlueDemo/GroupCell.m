//
//  GroupCell.m
//  TelinkBlueDemo
//
//  Created by Arvin on 2017/4/12.
//  Copyright © 2017年 Green. All rights reserved.
//

#import "GroupCell.h"
#import "DemoDefine.h"
@implementation GroupCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
}
- (IBAction)turnOn:(UISwitch *)sender {
    if (sender.on) {
        [kCentralManager turnOnCertainGroupWithAddress:self.groupID];
    }else{
        [kCentralManager turnOffCertainGroupWithAddress:self.groupID];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
