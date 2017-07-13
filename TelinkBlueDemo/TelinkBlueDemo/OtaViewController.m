//
//  OtaViewController.m
//  TelinkBlueDemo
//
//  Created by telink on 16/1/21.
//  Copyright © 2016年 Green. All rights reserved.

#import "OtaViewController.h"
#import "BTCentralManager.h"
#import "BTDevItem.h"
#import "SysSetting.h"
#import "DemoDefine.h"

@interface OtaViewController ()<UITableViewDataSource,UITableViewDelegate>{
    BTCentralManager *centraManager;
    int location;
    NSData *otaData;
    NSUInteger number;
    BOOL isStartSend;
    BOOL otaCricleFinished;
    NSUInteger len;
    int loginTime;
    BOOL oneKBSent;   //每一kb数据发送时候；
}
@property (weak, nonatomic) IBOutlet UITableView *ProgressTableView;
@property (weak, nonatomic) IBOutlet UILabel *ProgressLabel;
@property(nonatomic,strong)NSMutableArray *otaLogArrs;
@property(nonatomic,strong)NSTimer *otaTimer;
@property(nonatomic,strong)NSTimer *loginTimer;       //第一次进入时候Login－TimeOut
@property(nonatomic,strong) NSData *translatedData;    //已经发送的数据
@property(nonatomic,strong) NSData *otaData;
@property (strong, nonatomic) BTDevItem *otaItem;
@end

@implementation OtaViewController

-(NSMutableArray *)otaLogArrs{
    if (!_otaLogArrs) {
        _otaLogArrs = [[NSMutableArray alloc]init];
    }
    return _otaLogArrs;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    oneKBSent = NO;
    location = 0;
    centraManager = [BTCentralManager shareBTCentralManager];
    centraManager.delegate = self;
    self.ProgressTableView.delegate = self;
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.ProgressTableView.dataSource =self;
    loginTime = 0;
    if ([centraManager isLogin] && centraManager.selConnectedItem.u_DevAdress == self.u_address) {
        self.otaItem = centraManager.selConnectedItem;
        [self showLogMessageWithStr:@"已经Login" item:centraManager.selConnectedItem];
        [centraManager readFeatureOfselConnectedItem];
    }else{
        [self StartConnectIsAutoLogin:NO];
    }
    
}

-(void)StartConnectIsAutoLogin:(BOOL)isAutoLogin{
    [self showLogMessageWithStr:@"Scan device for OTA..." item:nil];
    [centraManager startScanWithName:kSettingLastName Pwd:kSettingLastPwd AutoLogin:isAutoLogin];
     self.loginTimer = [NSTimer scheduledTimerWithTimeInterval:6 target:self selector:@selector(TimeOutAction:) userInfo:@(isAutoLogin) repeats:YES];
}

-(void)TimeOutAction:(NSTimer *)timer{
    loginTime++;
    if (loginTime == 3) {
        loginTime = 0;
        [self.loginTimer invalidate];
        [self showLogMessageWithStr:@"OTA failled due to Unable to connect and Login " item:self.otaItem];
    }
    [centraManager startScanWithName:kSettingLastName Pwd:kSettingLastPwd AutoLogin:[timer.userInfo boolValue]];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.otaLogArrs.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static  NSString *identifer_cell = @"identifer_cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifer_cell];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifer_cell];
    }
    cell.textLabel.text = self.otaLogArrs[indexPath.row];
    cell.textLabel.font = [UIFont boldSystemFontOfSize:10];
    return cell;
}


-(void)OnDevChange:(id)sender Item:(BTDevItem *)item Flag:(DevChangeFlag)flag{
    NSLog(@"%@",item);
    if (flag == DevChangeFlag_Add) {
        NSLog(@"添加了设备");
        if (item.u_DevAdress==self.u_address) {
            [centraManager connectWithItem:item];
            [self showLogMessageWithStr:@"Scaned a device" item:item];
        }
    }
    if (item.u_DevAdress == self.u_address && item&& flag == DevChangeFlag_Connected) {
        loginTime = 0;
        [self.loginTimer invalidate];
        [self performSelector:@selector(loginAction) withObject:nil afterDelay:1];
        [self showLogMessageWithStr:@"Connected" item:item];
        [self showLogMessageWithStr:@"Login in..." item:item];
    }else if(item.u_DevAdress == self.u_address && item && flag == DevChangeFlag_Login){
        loginTime = 0;
        [self.loginTimer invalidate];
        self.otaItem = item;
        [self showLogMessageWithStr:@"Login success" item:item];
        [self showLogMessageWithStr:@"Read device and ready for OTA" item:item];
        [centraManager readFeatureOfselConnectedItem];
    }else if(item.u_DevAdress == self.u_address && item && flag == DevChangeFlag_DisConnected){
        NSLog(@"%d",centraManager.isAutoLogin);
        if (!otaCricleFinished && location < number && location != 0) {
            [self showLogMessageWithStr:@"Ota失败" item:item];
            return;
        }
        [self StartConnectIsAutoLogin:NO];
        [self.otaTimer invalidate];
        [self showLogMessageWithStr:@"Disconnect" item:item];
        [self showLogMessageWithStr:@"Connecting......" item:item];
    }else if(item.u_DevAdress == self.u_address && item && flag == DevChangeFlag_ConnecteFail){
        [self showLogMessageWithStr:@"ConnectFail" item:item];
        [self.otaTimer invalidate];
    }
}
-(void)OnConnectionDevFirmWare:(NSData *)data{
    if (otaCricleFinished) {
        return;
    }
    NSString *firm = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    if (oneKBSent == YES) {
        oneKBSent = NO;
    
        [self showLogMessageWithStr:firm item:self.otaItem];
        [self distributeAndSendPackNumber];
        return;
    }
    NSString *firmWare = !isStartSend ? [NSString stringWithFormat:@"升级之前firmWare：%@",firm]:[NSString stringWithFormat:@"升级之后firmWare：%@",firm];
    [self showLogMessageWithStr:firmWare item:self.otaItem];
    if (!isStartSend) {
        NSData *data = [[NSFileHandle fileHandleForReadingAtPath:[[NSBundle mainBundle] pathForResource:self.fileName ofType:self.fileType]] readDataToEndOfFile];
        otaData = data;
        number = ((int)data.length %16)?(((int)data.length/16)+1):(((int)data.length/16)+2);
        if (!otaCricleFinished) {
            [self distributeAndSendPackNumber];
        }
    }else{
//已经发过包了
        otaCricleFinished = YES;
        [self showLogMessageWithStr:@"CircleFinished" item:self.otaItem];
        
    }
}
-(void)loginAction{
     centraManager.isAutoLogin = NO;
    [centraManager loginWithPwd:[SysSetting shareSetting].oUserPassword];
}

-(void)distributeAndSendPackNumber {
    [self.otaTimer invalidate];
    if (location < number) {
        float progress = location*100.f/number;
        self.ProgressLabel.text = [NSString stringWithFormat:@"%.f%%",progress];
    }
    if(location < 0) {
        return;
    }
    if (location > number && centraManager.isConnected) {
        [self showLogMessageWithStr:@"数据包发送完毕" item:self.otaItem];
        
        [self.otaTimer invalidate];
        return;
    }
    isStartSend = YES;
    NSUInteger packLoction;
    NSUInteger packLength;
    NSUInteger length;
    if (location == number) {
        packLength = 0;
        length = [otaData length];
    }else if(location == number-1){
        packLength = [otaData length]-location*16;
        length = [otaData length];
    }else{
        packLength = 16;
        length = location*20;
    }
    packLoction = location*16;
    NSRange range = NSMakeRange(packLoction, packLength);
    NSData *sendData = [otaData subdataWithRange:range];
    NSLog(@"--%ld",self.translatedData.length);
    [centraManager sendPack:sendData];
    location++;
    if ((length%kOTAPartSize == 0 && length != 0)||location==number+1) {
        oneKBSent = YES;
        [self showLogMessageWithStr:@"1KB_Send" item:centraManager.selConnectedItem];
        [centraManager readFeatureOfselConnectedItem];
        return;
    }
    self.otaTimer = [NSTimer scheduledTimerWithTimeInterval:0.00 target:self selector:@selector(distributeAndSendPackNumber) userInfo:nil repeats:YES];
}
-(void)showLogMessageWithStr:(NSString *)str item:(BTDevItem *)item{
    NSString *logStr;
    if (item) {
         logStr = [NSString stringWithFormat:@"address-%u--->%@",item.u_DevAdress,str];
        [self.otaLogArrs addObject:logStr];
    }else{
        logStr = [NSString stringWithFormat:@"address-NULL--->%@",str];
    }
    [self.otaLogArrs addObject:logStr];
    [self.ProgressTableView reloadData];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    centraManager.isAutoLogin = YES;
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    centraManager.isAutoLogin = NO;
}

@end
