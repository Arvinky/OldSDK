//
//  OTATipShowVC.m
//  TelinkBlueDemo
//
//  Created by Arvin on 2017/4/12.
//  Copyright © 2017年 Green. All rights reserved.
//

#import "OTATipShowVC.h"
#import "ShowTipModel.h"
@interface OTATipShowVC () <UITableViewDelegate, UITableViewDataSource>


@end

@implementation OTATipShowVC
- (NSMutableArray *)datasource {
    if (!_datasource) {
        _datasource = [[NSMutableArray alloc] init];
    }
    return _datasource;
}
- (NSMutableArray<BTDevItem *> *)otaDevices {
    if (!_otaDevices) {
        _otaDevices = [[NSMutableArray alloc] init];
    }
    return _otaDevices;
}
- (NSMutableArray<NSString *> *)hasOTADevices {
    if (!_hasOTADevices) {
        _hasOTADevices = [[NSMutableArray alloc] init];
    }
    return _hasOTADevices;
}

- (BOOL)hasOTA:(NSString *)uuidstr {
    BOOL contain = NO;
    for (int j=0; j<self.hasOTADevices.count; j++) {
        if ([self.hasOTADevices[j] isEqualToString:uuidstr]) {
            contain = YES;
            break;
        }
    }
    return contain;
}
- (void)viewDidLoad {
    [super viewDidLoad];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.datasource removeAllObjects];
    [self.tableview reloadData];
}
- (void)showTip:(NSString *)tip {
    ShowTipModel *model = [[ShowTipModel alloc] init];
    model.tip = tip;
    model.showColor = [tip isEqualToString:@"Send_Single_Finished"];
    [self.datasource addObject:model];
    
    NSIndexPath *path = [NSIndexPath indexPathForRow:self.datasource.count-1 inSection:0];
    [self.tableview insertRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationNone];
    [self.tableview scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.datasource.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UITableViewCell"];
    }
    ShowTipModel *model = self.datasource[indexPath.row];
    cell.textLabel.text = model.tip;
    cell.textLabel.font = [UIFont systemFontOfSize:10];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 26;
}
@end
