//
//  ARMainVC.h
//  TelinkBlueDemo
//
//  Created by Arvin on 2017/4/10.
//  Copyright © 2017年 Green. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ARMainVC : UIViewController
@property (nonatomic, copy) void(^UpdateMeshInfo)(NSString *name, NSString *pwd);
@property (nonatomic, assign) BOOL isNeedRescan;
@end
