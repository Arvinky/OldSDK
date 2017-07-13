//
//  AddDeviceViewController.m
//  TelinkBlueDemo
//
//  Created by Ken on 11/25/15.
//  Copyright © 2015 Green. All rights reserved.
//

#define Login_Time_Out 20                  //登录超时
#define SetMesh_Time_Out 20            //加灯超时
#define Finished_Time_Out 24
#define ReplaceAddr_Time_Out  10    //分配地址


#import "AddDeviceViewController.h"
#import "AppDelegate.h"
#import "SettingViewController.h"
#import "BTCentralManager.h"
#import "BTDevItem.h"
#import "MyCollectionViewCell.h"
#import "SysSetting.h"
#import "LightData.h"
#import "TranslateTool.h"

@interface AddDeviceViewController () <BTCentralManagerDelegate>
{   
    BTCentralManager *centralManager;
    UICollectionView *listView;
    BTDevItem *settingItem;//正在被设置的灯
    NSMutableArray *oldAddresses;  //旧地址
    NSMutableArray *newAddresses; //新地址
    BOOL existed;
    BOOL isSetMesh;
    BOOL addFinishedBtnClicked;
    
}
@property (nonatomic,strong)NSMutableArray *dataArrs;
@property (nonatomic, strong) UICollectionView *listView;
@property(nonatomic,strong)NSTimer *loginTimer;         //加灯定时器
@property(nonatomic,strong)NSTimer *setMeshTimer;       //加灯定时器
@property(nonatomic,strong)NSTimer *finishedTimer;      //结束控制定时器
@property(nonatomic,strong)NSTimer *replaceTmer; //分配地址定时器
@property(nonatomic,assign)NSUInteger logintime;
@property(nonatomic,assign)NSUInteger setMeshTime;
@property(nonatomic,assign)NSUInteger finishedTime;
@property(nonatomic,assign)NSUInteger replaceTime;
@property(nonatomic,strong)UIButton *tempBtn;
@property(nonatomic,strong)NSString *filePath;
@property(nonatomic,strong)NSMutableDictionary *totalDictionary; //存放meshname，地址字典

@end
static BOOL flages = YES;
static NSUInteger addressInt;
@implementation AddDeviceViewController
@synthesize listView;


- (void)loginTimeout:(TimeoutType)type {
    [self scanPro];
}
-(NSMutableArray *)dataArrs{
    if (_dataArrs == nil) {
        _dataArrs = [[NSMutableArray alloc]init];
    }
    return _dataArrs;
}
-(NSMutableDictionary *)totalDictionary{
    if (_totalDictionary == nil) {
        _totalDictionary = [[NSMutableDictionary alloc]init];
    }
    return _totalDictionary;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    oldAddresses = [[NSMutableArray alloc]init];
    newAddresses = [[NSMutableArray alloc]init];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    UICollectionViewFlowLayout *tempLayout=[[UICollectionViewFlowLayout alloc] init];
    [tempLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    CGRect parRect=self.view.bounds;
    
    CGRect btnRect=parRect;
    btnRect.origin.y=CGRectGetHeight(parRect)-55;
    btnRect.size.height=55;
    
    UIButton *tempBtn=[UIButton buttonWithType:UIButtonTypeSystem];
    [tempBtn setFrame:btnRect];
    [tempBtn addTarget:self action:@selector(addDeviceClick:) forControlEvents:UIControlEventTouchUpInside];
    [tempBtn setTitle:@"加灯中" forState:UIControlStateDisabled];
    self.tempBtn = tempBtn;
    btnRect.origin.x=CGRectGetMaxX(btnRect);
    
    [self.view addSubview:tempBtn];
    
    
    CGRect tempRect=parRect;
    tempRect.origin.y=64;
    tempRect.size.height=CGRectGetHeight(parRect)-CGRectGetHeight(btnRect)-64;
    
    
    self.listView=[[UICollectionView alloc] initWithFrame:tempRect collectionViewLayout:tempLayout];
    listView.dataSource=self;
    listView.delegate=self;
    listView.backgroundColor=[UIColor clearColor];
    
    [listView registerClass:[MyCollectionViewCell class] forCellWithReuseIdentifier:@"AddListViewCell"];
    
    [self.view addSubview:listView];
    
    centralManager=[BTCentralManager shareBTCentralManager];
    centralManager.delegate=self;
    self.navigationItem.title = @"正在加灯中";

    isSetMesh = NO;
    [self fileHandle];    //处理文件存储
    [self performSelector:@selector(scanPro) withObject:self afterDelay:1];

}

-(void)fileHandle{
    //数据存储考虑用属性列表处理
    //    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    
    //创建文件名字
    NSString *fileName = [NSString stringWithFormat:@"%@-%@",[SysSetting shareSetting].nUserName,[SysSetting shareSetting].nUserPassword];
    NSString *filepath = [path stringByAppendingPathComponent:fileName];

    BOOL existedFile = [[NSFileManager defaultManager]fileExistsAtPath:filepath];
    existed = existedFile;
    
    if (existedFile) {
//已经存在这个文件－－查找内部文件中的分配地址个数 设置addressInt
        NSMutableDictionary *flleContent = [NSMutableDictionary dictionaryWithContentsOfFile:filepath];
        [oldAddresses addObjectsFromArray:[flleContent allValues]];
        [newAddresses addObjectsFromArray:[flleContent allKeys]];
        addressInt = [flleContent allKeys].count+1;
     }else{
//不存在这个文件－addressInt＝1；
        addressInt = 1;
    }
        self.filePath = filepath;

}

-(void)scanPro
{
    centralManager.delegate=self;
    [BTCentralManager shareBTCentralManager].scanWithOut_Of_Mesh = YES;
    [centralManager startScanWithName:[SysSetting shareSetting].oUserName Pwd:[SysSetting shareSetting].oUserPassword AutoLogin:YES];
    self.navigationItem.title = @"-Logining-";
    self.logintime = 0;
    [self.loginTimer invalidate];
    self.loginTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timeAction:) userInfo:@"loginTimer" repeats:YES];
}

//超时处理
-(void)timeAction:(NSTimer *)timer{
    if ([timer.userInfo isEqualToString:@"loginTimer"]) {
        self.logintime++;
        if (self.logintime == Login_Time_Out/2) {
            [self scanPro];
            self.navigationItem.title = @"-Scaning Again-";
            self.logintime = Login_Time_Out/2;
        }
        if (self.logintime >= Login_Time_Out) {
            self.logintime = 0;
            [self.loginTimer invalidate];
            [centralManager stopScan];
            self.navigationItem.title = @"-Finished-";
            [self.tempBtn setTitle:@"<-Unable To Connect To Other Services->" forState:UIControlStateNormal];
        }
    }else if([timer.userInfo isEqualToString:@"setMeshTimer"]){
        self.setMeshTime++;
        if (self.setMeshTime == SetMesh_Time_Out) {
            self.navigationItem.title = @"-SetNetWork Failed, Trying Again-";
            self.setMeshTime = 0;
            [self.setMeshTimer invalidate];
            addressInt--;
            [self scanPro];
        }
    }else if([timer.userInfo isEqualToString:@"finishedTimer"]){
        self.finishedTime++;
        if (self.finishedTime == Finished_Time_Out) {
            self.finishedTime = 0;
            [self.finishedTimer invalidate];
            [centralManager stopScan];
            [self.tempBtn setTitle:@"<-Add Finished->" forState:UIControlStateNormal];
            self.navigationItem.title = @"-Click...Add Finished-";
        }
    }else if([timer.userInfo isEqualToString:@"replaceTmer"]){
        self.replaceTime++;
        if (self.replaceTime == ReplaceAddr_Time_Out ) {
            //修改地址超时－－－重新扫描连接分配地址
            self.navigationItem.title = @"-Distributing Address Fail...Trying Again-";
            [self scanPro];
            
        }
        //修改地址超时
    }
}

-(void)OnDevChange:(id)sender Item:(BTDevItem *)item Flag:(DevChangeFlag)flag{
    
    if (flag == DevChangeFlag_Login && isSetMesh == NO) {
        self.finishedTime = 0;
        [self.finishedTimer invalidate];
        self.logintime = 0;
        [self.loginTimer invalidate];
        if (addressInt >= 256) {
            [self.tempBtn setTitle:@"<-《Address Overflow》->" forState:UIControlStateNormal];
            self.navigationItem.title = @"-Click_Address overflow-";
            [self fileControl];
            [self popMessage];
            return;
        }
        [centralManager replaceDeviceAddress:centralManager.selConnectedItem.u_DevAdress WithNewDevAddress:addressInt];
        self.navigationItem.title = @"-Distributing Address-";
        settingItem = item;
        [self.replaceTmer invalidate];
        self.replaceTime = 0;
        self.replaceTmer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timeAction:) userInfo:@"replaceTmer" repeats:YES];
        
        [oldAddresses addObject:[NSString stringWithFormat:@"%u",settingItem.u_DevAdress]];
    }
    
}
-(void)resultOfReplaceAddress:(uint32_t )resultAddress{
        NSString *result = [NSString stringWithFormat:@"%u",resultAddress];
        NSString *addInt = [NSString stringWithFormat:@"%ld",(unsigned long)addressInt];
    
//设置成功的时候
    if ([result isEqualToString:addInt]){
        [centralManager stopScan];
        isSetMesh = YES;
//        uint8_t tlkBuffer[20]={0xc0,0xc1,0xc2,0xc3,0xc4,0xc5,0xc6,0xc7,0xd8,0xd9,0xda,0xdb,0xdc,0xdd,0xde,0xdf,0x0,0x0,0x0,0x0};
        GetLTKBuffer;
        if ([[settingItem u_Name]isEqualToString:@"out_of_mesh"]) {
            [[BTCentralManager shareBTCentralManager]setOut_Of_MeshWithName:@"out_of_mesh" PassWord:@"123" NewNetWorkName:[SysSetting shareSetting].nUserName Pwd:[SysSetting shareSetting].oUserPassword ltkBuffer:ltkBuffer ForCertainItem:settingItem];
            
        }else{
            [[BTCentralManager shareBTCentralManager]setOut_Of_MeshWithName:[SysSetting shareSetting].oUserName PassWord:[SysSetting shareSetting].oUserPassword NewNetWorkName:[SysSetting shareSetting].nUserName Pwd:[SysSetting shareSetting].nUserPassword ltkBuffer:ltkBuffer ForCertainItem:settingItem];
        }
        [newAddresses addObject:result];                   //新地址加入
        self.setMeshTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timeAction:) userInfo:@"setMeshTimer" repeats:YES];
        self.navigationItem.title = @"-Setting NetWork-";
    }else{
//设置失败的时候
        [self scanPro];
        [oldAddresses removeLastObject];    //失败时候将最后一个元素取出
        
    }

  }

-(void)OnDevOperaStatusChange:(id)sender Status:(OperaStatus)status{
    if (status == DevOperaStatus_SetNetwork_Finish) {
        self.setMeshTime = 0;
        [self.setMeshTimer invalidate];
        isSetMesh = NO;
        [self scanPro];
        addressInt++;
        self.finishedTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timeAction:) userInfo:@"finishedTimer" repeats:YES];
         [self CreateLightSign];
        
        
    }
}
-(void)CreateLightSign{
    LightData *tempData = [[LightData alloc]init];
    
    tempData.addressName = [NSString stringWithFormat:@"%u->%lu",settingItem.u_DevAdress>>8,addressInt-1];
    tempData.devAress = (uint32_t)(addressInt-1)<<8;
 
    [self.dataArrs addObject:tempData];
    [listView reloadData];
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.dataArrs.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIden=@"AddListViewCell";
    MyCollectionViewCell *tempCell=[collectionView dequeueReusableCellWithReuseIdentifier:cellIden forIndexPath:indexPath];
    [tempCell sizeToFit];
    if (!tempCell)
    {
        return nil;
    }
    
    if (indexPath.row>=0 && indexPath.row<_dataArrs.count)
    {
        LightData *tempData=[_dataArrs objectAtIndex:indexPath.row];

        NSString *tempImgName=@"icon_light_on";
        tempCell.imgView.image=[UIImage imageNamed:tempImgName];
        tempCell.imgView.tag=indexPath.row;
        tempCell.titleLab.text = [NSString stringWithFormat:@"(%@)",tempData.addressName];
        tempCell.titleLab.font = [UIFont boldSystemFontOfSize:12];
        if ((tempData.devAress == [BTCentralManager shareBTCentralManager].selConnectedItem.u_DevAdress)) {
            tempCell.titleLab.textColor = [UIColor redColor];
        }else{
            tempCell.titleLab.textColor = [UIColor blackColor];
        }

    }
    return tempCell;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(100, 125);
}

    /**
     *点击加设备的时候
     */
-(IBAction)addDeviceClick:(id)sender
    {
        SysSetting *selSetting=[SysSetting shareSetting];
        if (!selSetting.nUserName || selSetting.nUserName.length<1) {
            [self.navigationController popViewControllerAnimated:YES];
            return;
        }
        
        if (!selSetting.nUserPassword || selSetting.nUserPassword.length<1) {
            [self.navigationController popViewControllerAnimated:YES];
            return;
        }
        
        
//登录条件转换
        [[SysSetting shareSetting]updateUserInfo];
        [[NSNotificationCenter defaultCenter]postNotificationName:@"New_Action" object:nil];
        
        [self.navigationController popViewControllerAnimated:YES];
   }

//两种情况下的文件处理
-(void)fileControl{
    //文件处理---如果没有点击这个按钮时候另外处理
    if (oldAddresses.count > newAddresses.count) {
        NSUInteger plus = oldAddresses.count-newAddresses.count;
        for (int i = 0; i < plus; i++) {
            [oldAddresses removeLastObject];
        }
        
    }
    self.totalDictionary = [[NSMutableDictionary alloc]initWithObjects:oldAddresses forKeys:newAddresses];
    [self.totalDictionary writeToFile:self.filePath atomically:YES];
//    NSDictionary *dic = [[NSDictionary alloc]initWithContentsOfFile:self.filePath];
}
-(void)popMessage{
    UIAlertView *promptAlert = [[UIAlertView alloc] initWithTitle:@"提示:" message:@"Mesh内灯已满" delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
    [NSTimer scheduledTimerWithTimeInterval:3.f
                                     target:self
                                   selector:@selector(timerFireMethod:)
                                   userInfo:promptAlert
                                    repeats:YES];
    [promptAlert show];
}
- (void)timerFireMethod:(NSTimer*)theTimer//弹出框
{
    UIAlertView *promptAlert = (UIAlertView*)[theTimer userInfo];
    [promptAlert dismissWithClickedButtonIndex:0 animated:NO];
    promptAlert =NULL;
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationItem setHidesBackButton:YES];
    flages = YES;
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    centralManager.delegate = nil;
    [self.loginTimer invalidate];
    [self.setMeshTimer invalidate];
    [self.finishedTimer invalidate];
    self.logintime = 0;
    self.setMeshTime = 0;
    self.finishedTime = 0;
    [self fileControl];
    flages = NO;
//    [[BTCentralManager shareBTCentralManager]stopScan];
}




@end
