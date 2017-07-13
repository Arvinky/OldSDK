//
//  OtaViewController.h
//  TelinkBlueDemo
//
//  Created by telink on 16/1/21.
//  Copyright © 2016年 Green. All rights reserved.
//

#import <UIKit/UIKit.h>
@class BTDevItem;
@interface OtaViewController : UIViewController

@property(nonatomic,strong)NSString *fileName;
@property(nonatomic,strong)NSString *fileType;

@property(nonatomic,assign)uint32_t u_address;
@end
