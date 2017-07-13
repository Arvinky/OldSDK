//
//  ARMainVC.m
//  TelinkBlueDemo
//
//  Created by Arvin on 2017/4/10.
//  Copyright © 2017年 Green. All rights reserved.
//

#import "ARMainVC.h"
#import "ARTips.h"
#import "SettingViewController.h"
#import "AppDelegate.h"
#import "SysSetting.h"
#import "AddDeviceViewController.h"
#import "MyCollectionCell.h"
#import "DeviceModel.h"
#import "DemoDefine.h"
#import "SingleSettingViewController.h"

@interface ARMainVC () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, BTCentralManagerDelegate> {
    NSInteger Rescan_Count;
}
@property (nonatomic, strong) NSMutableArray *hasBeenOTADevicesAddress;
@property (nonatomic, strong) NSData *otaData;
@property (nonatomic, assign) NSInteger number; //数据包的包个数；
@property (nonatomic, assign) NSInteger location;  //当前所发送的包的Index；
@property (nonatomic, strong) NSTimer *otaTimer;
@property (nonatomic, strong) NSTimer *scanDeviceTimer;
@property (nonatomic, assign) BOOL isStartOTA;
@property (nonatomic, assign) BOOL isSingleSendFinsh;
@property (nonatomic, assign) BOOL isHasBeganSend;
@property (nonatomic, assign) BOOL isSingleFinish;
@property (nonatomic, assign) BOOL isAllFinish;
@property (nonatomic, assign) BOOL isPartDataSendFinsh;
@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;
@property(nonatomic, strong) NSMutableArray <DeviceModel *>*collectionSource;
@property (nonatomic, strong) OTATipShowVC *otaShowTipVC;


@end

@implementation ARMainVC
#define kMaxScanCount (3)
#pragma mark- Delegate
- (NSMutableArray *)hasBeenOTADevicesAddress {
    if (!_hasBeenOTADevicesAddress) {
        _hasBeenOTADevicesAddress = [[NSMutableArray alloc] init];
    }
    return _hasBeenOTADevicesAddress;
}
- (OTATipShowVC *)otaShowTipVC {
    if (!_otaShowTipVC) {
        _otaShowTipVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"OTATipShowVC"];
    }
    return _otaShowTipVC;
}
- (void)addchild {
    self.otaShowTipVC.view.frame = CGRectMake(0, 0, kMScreenW, kMScreenH);
    [[UIApplication sharedApplication].windows[0] addSubview:self.otaShowTipVC.view];
//    [self addChildViewController:self.otaShowTipVC];
//    [self.view addSubview:self.otaShowTipVC.view];
//    [self.otaShowTipVC didMoveToParentViewController:self];
//    self.otaShowTipVC.view.frame = CGRectMake(0, 0, kMScreenW, kMScreenH);
}
- (void)removeChild {
    [self.otaShowTipVC.view removeFromSuperview];
//    [self.otaShowTipVC willMoveToParentViewController:nil];
//    [self.otaShowTipVC removeFromParentViewController];
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.collectionSource.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MyCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MyCollectionCell" forIndexPath:indexPath];
    DeviceModel *model = self.collectionSource[indexPath.item];
    [cell updateState:model];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(100, 125);
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    //得到灯现在的状态
    DeviceModel *pathModel = self.collectionSource[indexPath.row];
    switch (pathModel.stata) {
        case LightStataTypeOutline: return; break;
        case LightStataTypeOff:
            [kCentralManager turnOnCertainLightWithAddress:pathModel.u_DevAdress]; break;
        case LightStataTypeOn:
            [kCentralManager turnOffCertainLightWithAddress:pathModel.u_DevAdress]; break;
        default: break;
    }
}

#pragma mark- Setter & Getter
- (NSMutableArray *)collectionSource{
    if (!_collectionSource) {
        _collectionSource = [[NSMutableArray alloc]init];
    }
    return _collectionSource;
}
- (NSInteger)number {
    NSUInteger len = self.otaData.length;
    BOOL ret = (NSInteger)(len %16);
    return !ret?((NSInteger)(len/16)+1):((NSInteger)(len/16)+2);
}
- (NSData *)otaData {
    if (!_otaData) {
        _otaData = [[NSFileHandle fileHandleForReadingAtPath:[[NSBundle mainBundle] pathForResource:@"light_8267_ota" ofType:@"bin"]] readDataToEndOfFile];
    }
    return _otaData;
}
#pragma mark- Click Events
- (IBAction)allOn {
    [[BTCentralManager shareBTCentralManager] turnOnAllLight];
}

- (IBAction)allOff {
    [[BTCentralManager shareBTCentralManager] turnOffAllLight];
}
- (IBAction)startOTA {
    [self addchild];
    self.isStartOTA = YES;
    if (kCentralManager.isLogin) {
        self.location = 0;
        self.otaShowTipVC.otaItem = [[BTDevItem alloc] initWithDevice:kCentralManager.selConnectedItem];
        kCentralManager.isAutoLogin = NO;
        [self.otaShowTipVC.otaDevices addObject:kCentralManager.selConnectedItem];
        NSString *tip = [NSString stringWithFormat:@"begain ota device with address: %x", self.otaShowTipVC.otaItem.u_DevAdress];
        [self.otaShowTipVC showTip:tip];
        [self sendPcaket];
    }else{
        [self scanDeviceForOTA];
    }
}

- (void)removeOTAView:(UILongPressGestureRecognizer *)sender{
    if (self.otaTimer) {
        [self.otaTimer invalidate];
        self.otaTimer = nil;
    }
    self.location = 0;
    self.isStartOTA = NO;
    self.isAllFinish = NO;
    self.isSingleFinish = NO;
    self.isPartDataSendFinsh = NO;
    [self.otaShowTipVC.otaDevices removeAllObjects];
    [self.otaShowTipVC.hasOTADevices removeAllObjects];
    [self.hasBeenOTADevicesAddress removeAllObjects];
    [self removeChild];
    [self.collectionSource removeAllObjects];
    [self.collectionView reloadData];
    [self startScan];
}
- (void)normalSetting {
    self.isNeedRescan = YES;
    UIBarButtonItem *leftBtn = [[UIBarButtonItem alloc] initWithTitle:@"Setting" style:UIBarButtonItemStylePlain target:self action:@selector(settingMesh)];
    self.navigationItem.leftBarButtonItem = leftBtn;
    
    UIBarButtonItem *rightBtn = [[UIBarButtonItem alloc] initWithTitle:@"Add Devices" style:UIBarButtonItemStylePlain target:self action:@selector(addDevice)];
    self.navigationItem.rightBarButtonItem = rightBtn;
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]
                                               initWithTarget:self action:@selector(longPressGestureRecognized:)];
    [self.collectionView addGestureRecognizer:longPress];
    
    UILongPressGestureRecognizer *quitOtaGesture = [[UILongPressGestureRecognizer alloc]
                                                    initWithTarget:self action:@selector(removeOTAView:)];
    quitOtaGesture.numberOfTouchesRequired = 2;
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [window addGestureRecognizer:quitOtaGesture];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self normalSetting];
    Rescan_Count = 0;
    [kDelegate logBtn];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [BTCentralManager shareBTCentralManager].delegate = self;
    self.navigationController.navigationBarHidden = NO;
    self.tabBarController.tabBar.hidden = NO;
    if (kCentralManager.isLogin) {
        if (!self.isNeedRescan) {
            [kCentralManager setNotifyOpenPro];
        }
    }else{
        self.isNeedRescan = YES;
    }
    
    if (self.isNeedRescan) {
        [self startScan];
        self.isNeedRescan = NO;
    }
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)sendPcaket {
    if(self.location < 0) return;
    kEndTimer(self.otaTimer)
    if (self.location > self.number) {
        return;
    }
    NSUInteger packLoction;
    NSUInteger packLength;
    
    if (self.location == self.number) {
        packLength = 0;
    }else if(self.location == self.number-1){
        packLength = [self.otaData length]-self.location*16;
    }else{
        packLength = 16;
    }
    packLoction = self.location*16;
    NSRange range = NSMakeRange(packLoction, packLength);
    NSData *sendData = [self.otaData subdataWithRange:range];
    [kCentralManager sendPack:sendData];
    if (self.location==self.number) {
        self.isSingleSendFinsh = YES;
        [self.otaShowTipVC showTip:@"Send_Single_Finished"];
    }
    CGFloat per = self.location *1.0 / self.number;
    if (per>0.99) {
        per = 0.99;
    }
    self.otaShowTipVC.progressL.text = [NSString stringWithFormat:@"----%.f%%--- ",per*100.f];
    self.otaShowTipVC.progressV.progress = per;
    
    
    self.location++;
    if ((packLoction%kOTAPartSize == 0 && packLoction!= 0)||self.location==self.number+1) {
        [kCentralManager readFeatureOfselConnectedItem];
        if (!self.isSingleSendFinsh) {
            if (!(packLoction%(1024*kPrintPerDataSend))) {
                NSString *p = [NSString stringWithFormat:@"%d kb data has been send", kPrintPerDataSend];
                [self.otaShowTipVC showTip:p];
            }
        }
        return;
    }
    self.otaTimer = [NSTimer scheduledTimerWithTimeInterval:0.00 target:self selector:@selector(sendPcaket) userInfo:nil repeats:YES];
}
#pragma mark- Delegate
- (void)dosomethingWhenDiscoverDevice:(BTDevItem *)item {
    if (!self.otaShowTipVC.otaItem) {
        self.otaShowTipVC.otaItem = item;
        [kCentralManager connectWithItem:item];
        return;
    }
    //是否是上次ota的设备
    BOOL islastDevice = [self.otaShowTipVC.otaItem.uuidString isEqualToString:item.uuidString];
    BOOL contain = [self.otaShowTipVC hasOTA:item.uuidString];
    if (!contain) {
        //ota成功的设备中不包含扫描到的设备，有两种情况，
            //1:已经ota过，处于重启状态
            //2:没有ota过，或是ota失败
        //扫描到的设备是最后一次ota的device
        if (islastDevice) {
            NSString *tip;
            //假如发包完成，说明重启状态
            if (self.isSingleSendFinsh) {
                tip = [NSString stringWithFormat:@"reboot address: %x", self.otaShowTipVC.otaItem.u_DevAdress];
                [kCentralManager connectWithItem:item];
            }
            //未发包完成，说明ota失败，需retry
            else{
                tip = [NSString stringWithFormat:@"ota retry address: %x", self.otaShowTipVC.otaItem.u_DevAdress];
            }
            [self.otaShowTipVC showTip:tip];
        }
        //扫描到的设备不是最后一次ota的device
        
        else{
            //
            if (!self.isSingleSendFinsh) {
                self.otaShowTipVC.otaItem = item;
                if (kCentralManager.devArrs.count==1) {
                    [kCentralManager connectWithItem:item];
                }else{
                    CBPeripheral *per = [kCentralManager.devArrs[kCentralManager.devArrs.count-2] blDevInfo];
                    if (per.state!=CBPeripheralStateConnecting&&per.state!=CBPeripheralStateConnected) {
                        [kCentralManager connectWithItem:item];
                    }
                }
            }
        }
    }
}
- (void)dosomethingWhenConnectedDevice:(BTDevItem *)item {
    kEndTimer(self.scanDeviceTimer)
    NSString *tip = [NSString stringWithFormat:@"connected device address: %x", item.u_DevAdress];
    [self.otaShowTipVC showTip:tip];
}
- (void)scanedLoginCharacteristic {
    if (!self.isStartOTA) return;
    [kCentralManager loginWithPwd:nil];
}
- (void)dosomethingWhenDisConnectedDevice:(BTDevItem *)item {
    if (self.location>self.number) {
        NSString *tip = [NSString stringWithFormat:@"disconnect and reboot with address: %x", self.otaShowTipVC.otaItem.u_DevAdress];
        [self.otaShowTipVC showTip:tip];
        Rescan_Count = 0;
        [self scanDeviceForOTA];
    }else{
        [self.otaShowTipVC showTip:@"disconnect...."];
        [self.otaShowTipVC showTip:@"OTA fail..."];
    }
}
- (void)dosomethingWhenLoginDevice:(BTDevItem *)item {
    NSString *otip = [NSString stringWithFormat:@"login in success  mesh -> %@ / %@", kSettingLastName, kSettingLastPwd];
    [self.otaShowTipVC showTip:otip];
    if ([self.otaShowTipVC.otaItem.uuidString isEqualToString:item.uuidString]&&self.location&&!self.isSingleFinish) {
        self.isSingleFinish = YES;
        NSString *addressS = [NSString stringWithFormat:@"Finish single device OTA with address %02x", item.u_DevAdress];
        [self.otaShowTipVC showTip:addressS];
        [self.otaShowTipVC.hasOTADevices addObject:self.otaShowTipVC.otaItem.uuidString];
        NSString *otaadd = [NSString stringWithFormat:@"%02x",kCentralManager.selConnectedItem.u_DevAdress>>8];
        [self.hasBeenOTADevicesAddress addObject:otaadd];
        self.otaShowTipVC.progressL.text = @"100/100";
        self.otaShowTipVC.progressV.progress = 1.;
    }
    if (!self.isSingleFinish) {
        kCentralManager.isAutoLogin = NO;
        self.location = 0;
    }
    [kCentralManager readFeatureOfselConnectedItem];
}
- (void)OnDevChange:(id)sender Item:(BTDevItem *)item Flag:(DevChangeFlag)flag {
    if (!self.isStartOTA) return;
    kCentralManager.isAutoLogin = NO;
    switch (flag) {
        case DevChangeFlag_Add:                      [self dosomethingWhenDiscoverDevice:item]; break;
        case DevChangeFlag_Connected:           [self dosomethingWhenConnectedDevice:item]; break;
        case DevChangeFlag_Login:                    [self dosomethingWhenLoginDevice:item];      break;
        case DevChangeFlag_DisConnected:      [self dosomethingWhenDisConnectedDevice:item]; break;
        default:    break;
    }
}

- (void)OnConnectionDevFirmWare:(NSData *)data{
    
    Byte *byte = (Byte *)[data bytes];
    NSMutableString *mStr = [NSMutableString string];
    for (int i = 0; i<data.length; i++) {
        [ mStr appendFormat:@"%c",byte[i] ];
    }
    NSString *showFirm = [NSString stringWithFormat:@"%@-%@",self.isSingleFinish ? (@"升级后:"):(@"升级前"),mStr];
    if (((self.location - 1) * 16.0) / kOTAPartSize == 1) {
        [self.otaShowTipVC showTip:showFirm];
    }
    if (!self.isSingleFinish) {
        [self sendPcaket];
    }else{
        [self.otaShowTipVC showTip:showFirm];
        self.isSingleFinish = NO;
        self.location = 0;
        Rescan_Count = 0;
        //save devices has been ota
        [self.otaShowTipVC.otaDevices removeObject:kCentralManager.selConnectedItem];
        //扫描进行下一个
        self.isSingleSendFinsh = NO;
        self.otaShowTipVC.progressV.progress = 0;
        self.otaShowTipVC.progressL.text = @"0/100";
        [self scanDeviceForOTA];
    }
}

- (void)OnCenterStatusChange:(id)sender {
    if (kCentralManager.centerState==CBCentralManagerStatePoweredOff) {
        [self.collectionSource removeAllObjects];
        [self.collectionView reloadData];
        NSURL *url = [NSURL URLWithString:@"prefs:root=Bluetooth"];
        if ([[UIApplication sharedApplication] canOpenURL:url]) {
            [[UIApplication sharedApplication] openURL:url];
        }
    }
}
- (void)notifyBackWithDevice:(DeviceModel *)model {
    if (!model) return;
    NSMutableArray *macs = [[NSMutableArray alloc] init];
    
    for (int i=0; i<self.collectionSource.count; i++) {
        [macs addObject:@(self.collectionSource[i].u_DevAdress)];
    }
    //更新既有设备状态
    if ([macs containsObject:@(model.u_DevAdress)]) {
        NSUInteger index = [macs indexOfObject:@(model.u_DevAdress)];
        DeviceModel *tempModel =[self.collectionSource objectAtIndex:index];
        [tempModel updataLightStata:model];
        [self.collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]]];
    }
    //添加新设备
    else{
        DeviceModel *omodel = [[DeviceModel alloc] initWithModel:model];
        [self.collectionSource addObject:omodel];
        [self.collectionView reloadData];
    }
}

//特殊情况处理－默认已经与所有灯断开连接－－所有灯的状态设置为0---
-(void)resetStatusOfAllLight{
    for (DeviceModel *model in self.collectionSource) {
        model.stata = 0;
        model.brightness = 0;
        [self.collectionView reloadItemsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:[self.collectionSource indexOfObject:model] inSection:0]]];
    }
}
- (void)loginTimeout:(TimeoutType)type {
    switch (type) {
        case TimeoutTypeConnectting:
            [kCentralManager connectPro];
            break;
        case TimeoutTypeScanServices:
            [kCentralManager.selConnectedItem.blDevInfo discoverServices:nil];
            break;
        case TimeoutTypeScanCharacteritics:
            for (CBService *ser in kCentralManager.selConnectedItem.blDevInfo.services) {
                [kCentralManager.selConnectedItem.blDevInfo discoverCharacteristics:nil forService:ser];
            }   break;
        case TimeoutTypeWritePairFeatureBack:
            [kCentralManager loginWithPwd:nil]; break;
        default:
            [self startScan];
            break;
    }
}

- (void)longPressGestureRecognized:(UILongPressGestureRecognizer *)longPress {
    if (!kCentralManager.isLogin) return;
    if (longPress.state==UIGestureRecognizerStateBegan) {
        NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:[longPress locationInView:self.collectionView]];
        if (!self.collectionSource||!indexPath)  return;
        SingleSettingViewController *tempCon=[[SingleSettingViewController alloc] initWithNibName:@"SingleSettingViewController" bundle:[NSBundle mainBundle]];
        tempCon.isGroup=NO;
        tempCon.selData=[self.collectionSource objectAtIndex:indexPath.item];
        [self.navigationController pushViewController:tempCon animated:YES];
    }
}
- (void)scantimeOut:(NSTimer *)timer {
    Rescan_Count++;
    NSString *tip;
    if (Rescan_Count<=kMaxScanCount) {
        if ([self.otaShowTipVC.hasOTADevices containsObject:self.otaShowTipVC.otaItem.uuidString]) {
            tip = [NSString stringWithFormat:@"reboot address: %x  for %ld/s", self.otaShowTipVC.otaItem.u_DevAdress, 6*Rescan_Count];
        }else{
            tip = [NSString stringWithFormat:@"scan address: %x  for %ld/s", self.otaShowTipVC.otaItem.u_DevAdress, 6*Rescan_Count];
        }
    }else{
        if (self.hasBeenOTADevicesAddress.count>0) {
           tip = [NSString stringWithFormat:@"ota devices : %@",[self.hasBeenOTADevicesAddress componentsJoinedByString:@" - "]];
        }else{
            tip = [NSString stringWithFormat:@"No more device found" ];
        }
        kEndTimer(timer)
        [kCentralManager stopScan];
    }
    [self.otaShowTipVC showTip:tip];
}
- (void)scanDeviceForOTA {
    [kCentralManager startScanWithName:kSettingLastName Pwd:kSettingLastPwd AutoLogin:NO];
    self.scanDeviceTimer = [NSTimer scheduledTimerWithTimeInterval:6 target:self selector:@selector(scantimeOut:) userInfo:nil repeats:YES];
}
- (void)startScan {
    [self.collectionSource removeAllObjects];
    [self.collectionView reloadData];
    kCentralManager.scanWithOut_Of_Mesh = NO;
    [kCentralManager startScanWithName:kSettingLastName Pwd:kSettingLastPwd AutoLogin:YES];
}
- (void)settingMesh {
    SettingViewController *tempCon=[[SettingViewController alloc] initWithNibName:@"SettingViewController" bundle:[NSBundle mainBundle]];
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    delegate.settingVC = tempCon;
    [self.navigationController pushViewController:tempCon animated:YES];
}

- (void)addDevice {
    BOOL eq = [kSettingLastName isEqualToString:kSettingLatestName]&&[kSettingLastPwd isEqualToString:kSettingLatestPwd];
    BOOL nilor = !kSettingLatestName.length || !kSettingLatestPwd.length;
    if (eq || nilor) {
        [self popMessage];
        return;
    }
    //要添加更新cell
//    [mainView stopPro];
    self.tabBarController.tabBar.hidden = YES;
    AddDeviceViewController *tempCon=[[AddDeviceViewController alloc] init];
    [self.navigationController pushViewController:tempCon animated:YES];
}


- (void)popMessage {
    UIAlertView *promptAlert = [[UIAlertView alloc] initWithTitle:ARTip message:ARChangeMeshInfo delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
    [NSTimer scheduledTimerWithTimeInterval:3.f target:self selector:@selector(timerFireMethod:) userInfo:promptAlert repeats:YES];
    [promptAlert show];
}
- (void)timerFireMethod:(NSTimer*)theTimer {
    UIAlertView *promptAlert = (UIAlertView*)[theTimer userInfo];
    [promptAlert dismissWithClickedButtonIndex:0 animated:NO];
    promptAlert =NULL;
}
@end
