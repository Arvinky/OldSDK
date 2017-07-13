//
//  SignLabel.m
//  TelinkBlueDemo
//
//  Created by telink on 16/1/12.
//  Copyright © 2016年 Green. All rights reserved.
//

#import "SignLabel.h"

@implementation SignLabel

+(SignLabel *)DesignLabel{
    UILabel *signLabel = [[UILabel alloc]initWithFrame:CGRectMake(([UIScreen mainScreen].bounds.size.width/2)-50, [UIScreen mainScreen].bounds.size.height-80,100 , 30)];
    signLabel.backgroundColor = [UIColor lightGrayColor];
    signLabel.textAlignment = NSTextAlignmentCenter;
    signLabel.font = [UIFont boldSystemFontOfSize:12];
    signLabel.textColor = [UIColor greenColor];
     signLabel.hidden = YES;
    return (SignLabel *)signLabel;
}
-(void)setLabelMessage:(NSString *)text Hidden:(BOOL)isHidden{
    self.text = text;
    self.hidden = isHidden;
}
@end
