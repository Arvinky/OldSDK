//
//  OTATipShowVC.h
//  TelinkBlueDemo
//
//  Created by Arvin on 2017/4/12.
//  Copyright © 2017年 Green. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DemoDefine.h"
@interface OTATipShowVC : UIViewController
@property (weak, nonatomic) IBOutlet UITableView *tableview;
@property (strong, nonatomic) NSMutableArray *datasource;
@property (strong, nonatomic) NSMutableArray <BTDevItem *> *otaDevices;
@property (strong, nonatomic) NSMutableArray <NSString *> *hasOTADevices;
@property (weak, nonatomic) IBOutlet UILabel *progressL;
@property (strong, nonatomic) BTDevItem *otaItem;
@property (weak, nonatomic) IBOutlet UIProgressView *progressV;
- (void)showTip:(NSString *)tip;
- (BOOL)hasOTA:(NSString *)uuidstr;
@end
