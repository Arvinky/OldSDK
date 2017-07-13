//
//  GroupTablviewCell.h
//  TelinkBlueDemo
//
//  Created by Ken on 11/27/15.
//  Copyright © 2015 Green. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GroupTablviewCellDelegate <NSObject>
-(void)onGroupCellOnEvent:(id)sender;
-(void)onGroupCellOffEvent:(id)sender;
@end


@interface GroupTablviewCell : UITableViewCell

@property (nonatomic, assign) id<GroupTablviewCellDelegate> delegate;
@property(nonatomic,strong)  UILabel *titleLab;
@property(nonatomic,strong)  UIButton *onBtn;
@property(nonatomic,strong)  UIButton *offBtn;

@end
