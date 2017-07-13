//
//  FileChooseController.m
//  TelinkBlueDemo
//
//  Created by telink on 16/1/21.
//  Copyright © 2016年 Green. All rights reserved.
//

#import "FileChooseController.h"
#import "OtaViewController.h"
#import "FileModel.h"

@interface FileChooseController ()<UITableViewDelegate,UITableViewDataSource>
@property(nonatomic,strong)OtaViewController *otaVc;
@property(nonatomic,strong)NSMutableArray *fileArrs;
@end

@implementation FileChooseController
-(NSMutableArray *)fileArrs{
    if (_fileArrs == nil) {
        _fileArrs = [[NSMutableArray alloc]init];
    }
    return _fileArrs;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self fileHandle];
    [self designUI];
    
}

-(void)designUI{
    self.navigationItem.title = @"OTA升级文件选择";
    UITableView *tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-64)];
    tableView.backgroundColor = [UIColor whiteColor];
    tableView.delegate = self;
    tableView.dataSource = self;
    [self.view addSubview:tableView];
    OtaViewController *otaVc = [[OtaViewController alloc]initWithNibName:@"OtaViewController" bundle:[NSBundle mainBundle]];
    self.otaVc = otaVc;
}

//C-Sleep_NA_v1.9
//light_8267_ota
-(void)fileHandle{
    FileModel *model = [[FileModel alloc]init];
    model.flleName = @"light_8267_ota";
    model.flleType = @"bin";
    [self.fileArrs addObject:model];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.fileArrs.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifer = @"cell_identifer";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifer];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifer];
    }
    FileModel *model = self.fileArrs[indexPath.row];
    cell.textLabel.text = model.flleName;
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    FileModel *model = self.fileArrs[indexPath.row];
    self.otaVc.fileName = model.flleName;
    self.otaVc.fileType = model.flleType;
    self.otaVc.u_address = self.u_address;
    [self.navigationController pushViewController:self.otaVc animated:YES];
}

@end
