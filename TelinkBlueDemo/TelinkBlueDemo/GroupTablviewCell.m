//
//  GroupTablviewCell.m
//  TelinkBlueDemo
//
//  Created by Ken on 11/27/15.
//  Copyright © 2015 Green. All rights reserved.
//

#import "GroupTablviewCell.h"

@implementation GroupTablviewCell

- (void)awakeFromNib {
    }

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    CGRect parRect=[[UIScreen mainScreen] bounds];
    
    CGRect tempRect=CGRectMake(5, 5, 200, 30);
    self.titleLab=[[UILabel alloc] initWithFrame:tempRect];
    [self.contentView addSubview:_titleLab];
    
    tempRect=CGRectMake(CGRectGetWidth(parRect)-30*2-10, 5, 30, 30);
    self.onBtn=[UIButton buttonWithType:UIButtonTypeSystem];
    [_onBtn setFrame:tempRect];
    [_onBtn addTarget:self action:@selector(onBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [_onBtn setTitle:@"ON" forState:UIControlStateNormal];
    [self.contentView addSubview:_onBtn];
    
    tempRect=CGRectMake(CGRectGetMaxX(tempRect)+5, 5, 30, 30);
    self.offBtn=[UIButton buttonWithType:UIButtonTypeSystem];
    [_offBtn setFrame:tempRect];
    [_offBtn addTarget:self action:@selector(offBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [_offBtn setTitle:@"OFF" forState:UIControlStateNormal];
    [self.contentView addSubview:_offBtn];
    
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(IBAction)onBtnClick:(id)sender
{
     if (_delegate && [_delegate respondsToSelector:@selector(onGroupCellOnEvent:)])
         [_delegate onGroupCellOnEvent:self];
}

-(IBAction)offBtnClick:(id)sender
{   
    if (_delegate && [_delegate respondsToSelector:@selector(onGroupCellOffEvent:)])
        [_delegate onGroupCellOffEvent:self];
}
@end
