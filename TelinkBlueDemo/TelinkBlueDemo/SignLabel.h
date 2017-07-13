//
//  SignLabel.h
//  TelinkBlueDemo
//
//  Created by telink on 16/1/12.
//  Copyright © 2016年 Green. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SignLabel : UILabel

+(SignLabel *)DesignLabel;

-(void)setLabelMessage:(NSString *)text Hidden:(BOOL)isHidden;



@end
