//
//  MyCollectionViewCell.h
//  TelinkBlueDemo
//
//  Created by Green on 11/22/15.
//  Copyright (c) 2015 Green. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DeviceModel.h"
@interface MyCollectionCell : UICollectionViewCell

@property (nonatomic, strong) IBOutlet UIImageView *imgView;
@property (nonatomic, strong) IBOutlet UILabel *titleLab;
- (void)updateState:(DeviceModel *)model;
@end
