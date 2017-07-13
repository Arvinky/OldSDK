//
//  ChooseGroupViewController.m
//  TelinkBlueDemo
//
//  Created by Ken on 11/30/15.
//  Copyright © 2015 Green. All rights reserved.
//

#import "ChooseGroupViewController.h"
#import "SysSetting.h"
#import "DeviceModel.h"
#import "BTCentralManager.h"
#import "BTDevItem.h"
#import "DemoDefine.h"
static NSUInteger addIndex;
@interface ChooseGroupViewController () <BTCentralManagerDelegate>
{
    SysSetting *selSetting;
}
@property (nonatomic, strong) NSMutableArray *dataArrs;
@property (nonatomic,strong) UITableView *grpTableView;
@end

@implementation ChooseGroupViewController
- (NSMutableArray *)dataArrs {
    if (!_dataArrs) {
        _dataArrs = [[NSMutableArray alloc] init];
    }
    return _dataArrs;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGRect tempRect=[self.view bounds];
    tempRect.origin.y=64;
    tempRect.size.height=CGRectGetHeight(tempRect)-64;
    self.grpTableView=self.tableView;
    
    selSetting=[SysSetting shareSetting];
    
    if (self.isRemove) {
        kCentralManager.delegate = self;
        [kCentralManager getGroupAddressWithDeviceAddress:self.selData.u_DevAdress];
    }
    else {
        [self.dataArrs addObjectsFromArray:selSetting.grpArrs];
    }
}




- (void)OnDevNofify:(id)sender Byte:(uint8_t *)byte {
    if (byte[7]==0xd4) {
        [self.dataArrs removeAllObjects];
        for (int j=0; j<4; j++) {
            if (byte[10+j]==0xff) break;
            switch (byte[10+j]) {
                case 1:
                    [self.dataArrs addObject:[GroupInfo ItemWith:@"Living Room" Adr:0x8001]];
                    break;
                case 2:
                    [self.dataArrs addObject:[GroupInfo ItemWith:@"Family Room" Adr:0x8002]];
                    break;
                case 3:
                    [self.dataArrs addObject:[GroupInfo ItemWith:@"Kitchen" Adr:0x8003]];
                    break;
                case 4:
                    [self.dataArrs addObject:[GroupInfo ItemWith:@"Bedroom" Adr:0x8004]];
                    break;
                default:
                    break;
            }
        }
        
        [self.tableView reloadData];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)addGroupLightWithAdr:(int)addAdr IsAdd:(BOOL)isAdd
{
    uint8_t cmd[13]={0x11,0x71,0x11,0x00,0x00,0x66,0x00,0xd7,0x11,0x02,0x01,0x01,0x80};
    cmd[5]=(_selData.u_DevAdress>>8) & 0xff;
    cmd[6]=_selData.u_DevAdress & 0xff;
    
    cmd[11]=addAdr;
    
    if (isAdd)
    {
        cmd[10]=0x01;
        cmd[2]=cmd[2]+addIndex;
        if (cmd[2]==250) {
            cmd[2]=4;
        }
        
        addIndex++;
    }
    else
    {
        cmd[10]=0x00;
        cmd[12]=(addAdr>>8) & 0xff;
        cmd[11]=addAdr & 0xff;
        cmd[2]=cmd[2]+addIndex;
        if (cmd[2]==250) {
            cmd[2]=1;
        }
        
        addIndex++;
    }
    
    [[BTCentralManager shareBTCentralManager] sendCommand:cmd Len:13];
}

-(BOOL)checkGrpInData:(int)grpData
{
    BOOL result=NO;
    for (int i=0;i<8;i++)
    {
        if (_selData->grpAdress[i]==grpData)
        {
            result=YES;
            break;
        }
    }
    return result;
}

-(NSArray *)getGrpArrWithAdr
{
    NSMutableArray *tempArrs=[[NSMutableArray alloc] init];
    for (GroupInfo *tempData in selSetting.grpArrs)
    {
        if  ([self checkGrpInData:tempData.grpAdr & 0xff])
            [tempArrs addObject:tempData];
    }
    return tempArrs;
}



#pragma mark - tableView Dada source /Delegate


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.dataArrs)
        return [self.dataArrs count];
    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdStr=@"tableCell";
    
    if (!(indexPath.row>=0 && indexPath.row<self.dataArrs.count))
        return nil;
    
    UITableViewCell *tempCell=[tableView dequeueReusableCellWithIdentifier:cellIdStr];
    if (!tempCell)
        tempCell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdStr];
    
    GroupInfo *tempData=[self.dataArrs objectAtIndex:indexPath.row];
    tempCell.textLabel.text=tempData.grpName;
    
    return tempCell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!(indexPath.row>=0 && indexPath.row<self.dataArrs.count))
        return;
    GroupInfo *tempData=[self.dataArrs objectAtIndex:indexPath.row];
    
    int tempAdr=tempData.grpAdr & 0xff;
    if (tempAdr==0xff)
        return;
    if (_isRemove)
    {
        if ([self.selData removeGrpAddressPro:tempAdr])
            [self addGroupLightWithAdr:tempAdr IsAdd:NO];
    }
    else
//加组的时候
        
    {
        if ([self.selData addGrpAddressPro:tempAdr])
            NSLog(@"组的地址－－－－%d",tempAdr);
            [self addGroupLightWithAdr:tempAdr IsAdd:YES];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

@end
