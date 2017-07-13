//
//  GroupVC.m
//  TelinkBlueDemo
//
//  Created by Arvin on 2017/4/11.
//  Copyright © 2017年 Green. All rights reserved.
//

#import "GroupVC.h"
#import "DemoDefine.h"
#import "GroupCell.h"
@interface GroupVC () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableview;

@end

@implementation GroupVC
-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
- (void)viewDidLoad {
    [super viewDidLoad];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [SysSetting shareSetting].grpArrs.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GroupCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GroupCell"];
    GroupInfo *info = [SysSetting shareSetting].grpArrs[indexPath.row];
    cell.groupID = info.grpAdr;
    cell.textLabel.text = info.grpName;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}
@end
