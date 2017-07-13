//
//  GroupViewController.m
//  TelinkBlueDemo
//
//  Created by Ken on 11/24/15.
//  Copyright © 2015 Green. All rights reserved.
//

#import "GroupViewController.h"
#import "SysSetting.h"
#import "SingleSettingViewController.h"
#import "BTCentralManager.h"
#import "BTDevItem.h"
@interface GroupViewController ()
{
    SysSetting *selSetting;
}

@property (nonatomic,strong) UITableView *grpTableView;

@end

@implementation GroupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    CGRect tempRect=[self.view bounds];
    tempRect.origin.y=64;
    tempRect.size.height=CGRectGetHeight(tempRect)-64;
    self.grpTableView=[[UITableView alloc] initWithFrame:tempRect];
    _grpTableView.dataSource=self;
    _grpTableView.delegate=self;
    _grpTableView.rowHeight=40;
    _grpTableView.allowsSelection=NO;
    [self.view addSubview:_grpTableView];
    
//    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]
//                                               initWithTarget:self action:@selector(longPressGestureRecognized:)];
//    [self.grpTableView addGestureRecognizer:longPress];
    

    selSetting=[SysSetting shareSetting];
    
}
#pragma mark - tableView Dada source /Delegate


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return selSetting.grpArrs.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdStr=@"tableCell";
    
    if (!(indexPath.row>=0 && indexPath.row<selSetting.grpArrs.count))
        return nil;
    
    GroupTablviewCell *tempCell=[tableView dequeueReusableCellWithIdentifier:cellIdStr];
    if (!tempCell)
    {
        tempCell=[[GroupTablviewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdStr];
        tempCell.delegate=self;
    }
    
    GroupInfo *tempData=[selSetting.grpArrs objectAtIndex:indexPath.row];
    
    tempCell.titleLab.text=tempData.grpName;
    
    return tempCell;
}


-(void)logByte:(uint8_t *)bytes Len:(int)len Str:(NSString *)str
{
    NSMutableString *tempMStr=[[NSMutableString alloc] init];
    for (int i=0;i<len;i++)
        [tempMStr appendFormat:@"%0x  ",bytes[i]];
    NSLog(@"%@ == %@",str,tempMStr);
}

-(void)setGroupLightWithAdr:(int)setAdr IsOn:(BOOL)isOn
{
    uint8_t cmd[13]={0x11,0x61,0x11,0x00,0x00,0x66,0x00,0xd0,0x11,0x02,0x01,0x01,0x00};
    cmd[5]=setAdr & 0xff;
    cmd[6]=(setAdr>>8) & 0xff;
    
    if (isOn)
    {
        cmd[10]=0x1;
        cmd[2]=0x11;
    }
    else
    {
        cmd[10]=0x0;
        cmd[2]=0x12;
    }
    
    [self logByte:cmd Len:13 Str:@"开关灯"];
    [[BTCentralManager shareBTCentralManager] sendCommand:cmd Len:13];
}


-(void)onGroupCellOnEvent:(id)sender
{
    NSIndexPath *tempIndexPath=[_grpTableView indexPathForCell:sender];
    if (tempIndexPath.row>=0  &&  tempIndexPath.row<selSetting.grpArrs.count)
    {
        GroupInfo *tempData=[selSetting.grpArrs objectAtIndex:tempIndexPath.row];
        int tempAdr=tempData.grpAdr;
        if ([tempData isAllRoom])
            tempAdr=0xffff;
        [self setGroupLightWithAdr:tempAdr IsOn:YES];
    }
}
-(void)onGroupCellOffEvent:(id)sender
{
    NSIndexPath *tempIndexPath=[_grpTableView indexPathForCell:sender];
    if (tempIndexPath.row>=0  &&  tempIndexPath.row<selSetting.grpArrs.count)
    {
        GroupInfo *tempData=[selSetting.grpArrs objectAtIndex:tempIndexPath.row];
        int tempAdr=tempData.grpAdr;
        if ([tempData isAllRoom])
            tempAdr=0xffff;
        [self setGroupLightWithAdr:tempAdr IsOn:NO];
    }
}

//-(void)longPressGestureRecognized:(id)sender
//{
//    UILongPressGestureRecognizer *longPress = (UILongPressGestureRecognizer *)sender;
//    UIGestureRecognizerState state = longPress.state;
//    
//    if (state==UIGestureRecognizerStateBegan)
//    {
//        CGPoint location = [longPress locationInView:self.grpTableView];
//        NSIndexPath *indexPath = [self.grpTableView indexPathForRowAtPoint:location];
//        NSLog(@"选中%@",indexPath);
//        
//        if (indexPath.row>=0 && indexPath.row<[selSetting.grpArrs count])
//        {
//            SingleSettingViewController *tempCon=[[SingleSettingViewController alloc] initWithNibName:@"SingleSettingViewController" bundle:[NSBundle mainBundle]];
//            tempCon.isGroup=YES;
//            tempCon.groupAdr=[(GroupInfo *)[selSetting.grpArrs objectAtIndex:indexPath.row] grpAdr];
//            [(UINavigationController *)self.view.window.rootViewController pushViewController:tempCon animated:YES];
//        }
//    }
//}

@end
