//
//  DCGroupInfoVC.m
//  DCProjectFile
//
//  Created  on 2023/7/11.
//

#import "DCGroupInfoVC.h"
#import "DCGroupInfoHeader.h"
#import "DCInfoEditCell.h"
#import "DCMineDataModel.h"
#import "DCEditInputVC.h"
#import "DCGroupManagerVC.h"
#import "DCGroupQRCodeVC.h"
@interface DCGroupInfoVC ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) DCGroupInfoHeader *headerView;
@property (nonatomic, assign) BOOL isGroupOwner;

@end

@implementation DCGroupInfoVC
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self requestGroupInfo];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.title = [NSString stringWithFormat:@"群组信息(%ld)",self.groupData.group_member.count];
    [self dcInit];
    
}
- (void)requestGroupInfo {
    NSString *groupId = [self.groupId componentsSeparatedByString:@"_"].lastObject;
    [[DCRequestManager sharedManager] requestWithMethod:@"POST" url:@"api/groupInfo" parameters:@{@"id":groupId} success:^(id  _Nullable result) {
        DCGroupDataModel *model = [DCGroupDataModel modelWithDictionary:result];
        self.groupData = model;
        self.headerView.groupData = model;
        NSInteger row = ceilf((self.groupData.group_member.count + 1 + @(self.isGroupOwner).intValue)/5.0);
        self.headerView.frame = CGRectMake(0, 0, kScreenWidth, row * 100 + 10);
        self.navigationItem.title = [NSString stringWithFormat:@"群组信息(%ld)",self.groupData.group_member.count];
    } failure:^(NSError * _Nonnull error) {
                
    }];
}

- (void)dcInit {
    self.tableView.tableHeaderView = self.headerView;
    self.headerView.groupId = self.groupId;
    self.headerView.groupData = self.groupData;
    [self.tableView registerNib:[UINib nibWithNibName:@"DCInfoEditCell" bundle:nil] forCellReuseIdentifier:@"DCInfoEditCell"];
    
}


- (void)setGroupData:(DCGroupDataModel *)groupData {
    _groupData = groupData;
    self.isGroupOwner = groupData.group_info.role==1;
    self.headerView.isGroupOwner = self.isGroupOwner;
    [self createDatas];
}

- (void)createDatas {
    [self.dataArray removeAllObjects];
    NSArray *tits = @[@"群头像",@"群名称",@"群二维码",@"消息免打扰"];
    NSArray *descs = @[self.groupData.group_info.avatar,
                       self.groupData.group_info.name ,
                       @"" ,
                       self.groupData.group_info.is_disturb?@"1":@"0"
    ];
    for (int i=0; i<tits.count; i++) {
        DCMineDataModel *model = [[DCMineDataModel alloc]init];
        model.title = tits[i];
        model.desc = descs[i];
        [self.dataArray addObject:model];
    }
    
    DCMineDataModel *muteModel = [[DCMineDataModel alloc]init];
    muteModel.title = @"全员禁言";
    muteModel.desc = self.groupData.group_info.is_mute?@"1":@"0";
    
    DCMineDataModel *magModel = [[DCMineDataModel alloc]init];
    magModel.title = @"群管理员";
    magModel.desc = @"";
    
    
    DCMineDataModel *callModel = [[DCMineDataModel alloc]init];
    callModel.title = @"允许群音视频通话";
    callModel.desc = self.groupData.group_info.is_audio?@"1":@"0";
    
    
    if (self.groupData.group_info.role != 0) {
        [self.dataArray insertObject:magModel atIndex:3];
        [self.dataArray addObject:muteModel];
    }
    
    if (self.groupData.group_info.audio && self.isGroupOwner) {
        [self.dataArray addObject:callModel];
    }
    [self.tableView reloadData];
}
- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.tableView.frame = self.view.bounds;
    
    self.headerView.frame = CGRectMake(0, 0, kScreenWidth, ceilf((self.groupData.group_member.count + 1)/5.0) * 100 + (self.groupData.group_member.count>19?68:8));
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DCInfoEditCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DCInfoEditCell" forIndexPath:indexPath];
    DCMineDataModel *model = self.dataArray[indexPath.row];
    if ([model.title isEqualToString:@"群头像"] || [model.title isEqualToString:@"群二维码"]) {
        cell.descLabel.hidden = YES;
        cell.switchView.hidden = YES;
        cell.avatarImgView.hidden = NO;
        cell.arrow.hidden = NO;
    }else if ([model.title isEqualToString:@"群名称"] || [model.title isEqualToString:@"群管理员"]) {
        cell.descLabel.hidden = NO;
        cell.switchView.hidden = YES;
        cell.avatarImgView.hidden = YES;
        cell.arrow.hidden = NO;
    }else {
        cell.descLabel.hidden = YES;
        cell.switchView.hidden = NO;
        cell.avatarImgView.hidden = YES;
        cell.arrow.hidden = YES;
    }
    if ([model.title isEqualToString:@"群头像"]) {
        [cell.avatarImgView sd_setImageWithURL:[NSURL URLWithString:model.desc]];
    }else if ([model.title isEqualToString:@"群二维码"]) {
        cell.avatarImgView.image = [UIImage imageNamed:@"group_qrcode"];
    }else {
        cell.avatarImgView.image = nil;
    }
    
    cell.titLabel.text = model.title;
    cell.descLabel.text = model.desc;
    cell.switchView.on = [model.desc isEqualToString:@"1"];
    __weak typeof (self) weakSelf = self;
    
    cell.changeStateBlock = ^(UISwitch * _Nonnull switchView) {
        if ([model.title isEqualToString:@"消息免打扰"]) {
            [weakSelf requestDisturbGroup:switchView];
            return;
        }
        
        if (weakSelf.groupData.group_info.role==0) {
            [MBProgressHUD showTips:@"您没有修改权限"];
            switchView.on = !switchView.isOn;
            return;
        }
        
        if ([model.title isEqualToString:@"全员禁言"]) {
            NSDictionary *parms = @{@"is_mute":@(!weakSelf.groupData.group_info.is_mute)};
            [weakSelf requestSaveGroupInfo:parms];
        }
        if ([model.title isEqualToString:@"允许群音视频通话"]) {
            NSDictionary *parms = @{@"is_audio": switchView.isOn?@(1):@(0)};
            [weakSelf requestSaveGroupInfo:parms];
        }
    };
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 90;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:self.isGroupOwner?@"解散群聊":@"退出群聊" forState:UIControlStateNormal];
    [button setTitleColor:kMainColor forState:UIControlStateNormal];
    button.titleLabel.font = kFontSize(18);
    button.frame = CGRectMake(0, 0, kScreenWidth, 60);
    [button addTarget:self action:@selector(logoutClick) forControlEvents:UIControlEventTouchUpInside];
    
    return button;
}
- (void)logoutClick {
    [self presentViewController:[DCTools actionSheet:@[self.isGroupOwner?@"确认解散群聊":@"确认退出群聊"] complete:^(int idx) {
        [self requestDismissGroup];
    }] animated:YES completion:nil];
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    DCMineDataModel *model = self.dataArray[indexPath.row];
    if ([model.title isEqualToString:@"群二维码"]) {
        DCGroupQRCodeVC *vc = [[DCGroupQRCodeVC alloc]init];
        vc.groupData = self.groupData;
        [self.navigationController pushViewController:vc animated:YES];
        return;
    }
    if (self.groupData.group_info.role==0) {
        [MBProgressHUD showTips:@"您没有修改权限"];
        return;
    }
    if ([model.title isEqualToString:@"群头像"]) {
        HXPhotoEditConfiguration *editConfig = [[HXPhotoEditConfiguration alloc]init];
        editConfig.onlyCliping = YES;
        editConfig.aspectRatio = HXPhotoEditAspectRatioType_1x1;
        HXPhotoManager *manager = [DCTools photoManager:1 isVideo:NO];
        manager.configuration.photoCanEdit = YES;
        manager.configuration.singleSelected = YES;
        manager.configuration.singleJumpEdit = YES;
        manager.configuration.photoEditConfigur = editConfig;
        
        [manager clearSelectedList];
        [[DCTools topViewController] hx_presentSelectPhotoControllerWithManager:manager didDone:^(NSArray<HXPhotoModel *> * _Nullable allList, NSArray<HXPhotoModel *> * _Nullable photoList, NSArray<HXPhotoModel *> * _Nullable videoList, BOOL isOriginal, UIViewController * _Nullable viewController, HXPhotoManager * _Nullable manager) {
            [self getImageData:photoList.firstObject];
        } cancel:^(UIViewController * _Nullable viewController, HXPhotoManager * _Nullable manager) {
                    
        }];
    }
    
    if ([model.title isEqualToString:@"群名称"]) {
        DCEditInputVC *vc = [[DCEditInputVC alloc]init];
        vc.inputType = KTextInputTypeGroupName;
        vc.editInputBlock = ^(NSString * _Nonnull text) {
            DCMineDataModel *model = self.dataArray[indexPath.row];
            model.desc = text;
            [self.tableView reloadRowAtIndexPath:indexPath withRowAnimation:UITableViewRowAnimationNone];
            
            [self requestSaveGroupInfo:@{@"name":text}];
        };
        [self.navigationController pushViewController:vc animated:YES];
    }
    
    if ([model.title isEqualToString:@"群管理员"]) {
        DCGroupManagerVC *vc = [[DCGroupManagerVC alloc]init];
        vc.groupData = self.groupData;
        [self.navigationController pushViewController:vc animated:YES];
    }
}
- (void) getImageData:(HXPhotoModel*)model {
    [model getImageWithSuccess:^(UIImage * _Nullable image, HXPhotoModel * _Nullable model, NSDictionary * _Nullable info) {
        
        [self uploadAvatar:image];
    } failed:^(NSDictionary * _Nullable info, HXPhotoModel * _Nullable model) {
        [MBProgressHUD showTips:@"图片获取失败"];
    }];
}

- (void)uploadAvatar:(UIImage *)image {
    NSData *data = [UIImage lubanCompressImage:image];
    NSString *namePre = [DCTools uploadFileNamePre];
    NSString *fileName = [NSString stringWithFormat:@"%@.png",namePre];
    
    [[DCFileUploadManager sharedManager] upload:data name:fileName uniquelyIdentifies:nil success:^(NSString * _Nonnull result) {
        NSDictionary *parms = @{@"avatar":result , @"driver":[DCUserManager sharedManager].ossModel.oss_status};
        [self requestSaveGroupInfo:parms];
    } failure:^(id  _Nonnull nullable) {
        [MBProgressHUD showTips:@"头像上传失败"];
    }];
    
}

- (void)requestSaveGroupAvatar:(NSString*)imageName {
    NSMutableDictionary *parms = [NSMutableDictionary dictionary];
    [parms setObject:imageName forKey:@"image"];
    [parms setObject:[DCUserManager sharedManager].ossModel.oss_status forKey:@"driver"];
    [parms setObject:@"2" forKey:@"type"];
    [[DCRequestManager sharedManager] requestWithMethod:@"POST" url:@"api/modifyAvatarNew" parameters:parms success:^(id  _Nullable result) {
        DCMineDataModel *model = self.dataArray.firstObject;
        model.desc = result[@"avatar"];
        [self.tableView reloadRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] withRowAnimation:UITableViewRowAnimationNone];
        NSString *name = result[@"image_name"];
        [self requestSaveGroupInfo:@{@"avatar":name}];
    } failure:^(NSError * _Nonnull error) {
        
    }];
    
}


- (void)requestSaveGroupInfo:(NSDictionary *)parms {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:[self.groupId componentsSeparatedByString:@"_"].lastObject forKey:@"id"];
    [dict addEntriesFromDictionary:parms];
    
    [[DCRequestManager sharedManager] requestWithMethod:@"PUT" url:@"api/groupInfo" parameters:dict success:^(id  _Nullable result) {
        [MBProgressHUD showTips:@"修改成功"];
        [self requestGroupInfo];
    } failure:^(NSError * _Nonnull error) {
        
    }];
}

- (void)requestDismissGroup {
    [[DCRequestManager sharedManager] requestWithMethod:@"POST" url:self.isGroupOwner ? @"api/dismissGroup" : @"api/exitGroup" parameters:@{@"group_id":[self.groupId componentsSeparatedByString:@"_"].lastObject} success:^(id  _Nullable result) {
        [MBProgressHUD showTips:self.isGroupOwner?@"解散成功":@"退出成功"];
        [self.navigationController popToRootViewControllerAnimated:YES];
    } failure:^(NSError * _Nonnull error) {
        
    }];
}

- (void)requestDisturbGroup:(UISwitch*)switchView {
    NSDictionary *parms = @{@"group_id":[self.groupId componentsSeparatedByString:@"_"].lastObject , @"is_disturb":switchView.isOn?@(1):@(0)};
    [[DCRequestManager sharedManager] requestWithMethod:@"POST" url:@"api/groupDisturb" parameters:parms success:^(id  _Nullable result) {
        [MBProgressHUD showTips:@"设置成功"];
        NSString *groupId = self.groupId;
        if (![DCTools isGroupId:self.groupId]) {
            groupId = [NSString stringWithFormat:@"group_%@",self.groupId];
        }
        NSString *where = [NSString stringWithFormat:@"set %@=%@ where %@=%@",bg_sqlKey(@"disturbState"),bg_sqlValue(switchView.isOn?@"1":@"0"),bg_sqlKey(@"targetId") , bg_sqlValue(groupId)];
        [DCConversationModel bg_update:kConversationListTableName where:where];
    } failure:^(NSError * _Nonnull error) {
        
    }];
}
- (DCGroupInfoHeader *)headerView {
    if (!_headerView) {
        _headerView = [DCGroupInfoHeader xib];
        _headerView.frame = CGRectZero;
        __weak typeof(self) weakSelf = self;
        _headerView.operateCompleteBlock = ^{
            [weakSelf requestGroupInfo];
        };
    }
    return _headerView;
}
- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}
@end
