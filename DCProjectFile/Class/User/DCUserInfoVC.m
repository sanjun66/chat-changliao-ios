//
//  DCUserInfoVC.m
//  DCProjectFile
//
//  Created  on 2023/5/29.
//

#import "DCUserInfoVC.h"
#import "DCMineInfoModel.h"
#import "DCConversationListVC.h"
#import "DCEditInputVC.h"
#import "DCUserHeaderView.h"
#import "DCInfoEditCell.h"
#import "DCMessagePswInputAlert.h"

#define ktit @"ktit"
#define kval @"kval"

@interface DCUserInfoVC ()<UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UIButton *friendButton;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
@property (nonatomic, strong) DCMineInfoModel *infoModel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) DCUserHeaderView *headerView;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableConst;

@end

@implementation DCUserInfoVC

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}
- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.headerView.frame = CGRectMake(0, 0, kScreenWidth, 128);
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self requestUserDatas];
    [self rightBarButtonItemWithString:@"icon_user_reload"];
    
    self.headerView = [DCUserHeaderView xib];
    self.tableView.tableHeaderView = self.headerView;
    self.headerView.isFromGroupChat = self.isFromGroupChat;
    [self.tableView registerNib:[UINib nibWithNibName:@"DCInfoEditCell" bundle:nil] forCellReuseIdentifier:@"DCInfoEditCell"];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DCInfoEditCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DCInfoEditCell" forIndexPath:indexPath];
    NSDictionary *data = self.dataArray[indexPath.row];
    cell.titLabel.text = data[ktit];
    if ([data[kval] isKindOfClass:[NSNumber class]]) {
        cell.descLabel.hidden = YES;
        cell.switchView.hidden = NO;
        cell.avatarImgView.hidden = YES;
        cell.arrow.hidden = YES;
        BOOL isOn = [data[kval] boolValue];
        cell.switchView.on = isOn;
    }else {
        cell.descLabel.hidden = YES;
        cell.switchView.hidden = YES;
        cell.avatarImgView.hidden = YES;
        cell.arrow.hidden = NO;
    }
    
    __weak typeof(self) ws = self;
    cell.changeStateBlock = ^(UISwitch * _Nonnull switchView) {
        if ([data[ktit] isEqualToString:@"加入黑名单"]) {
            [ws requestBlackUser:switchView];
        }else if ([data[ktit] isEqualToString:@"消息免打扰"]) {
            [ws setUpDisturbState:switchView];
        }else if ([data[ktit] isEqualToString:@"禁止发言"]) {
            if (ws.groupMuteBlock) {
                ws.groupMuteBlock(ws.member);
            }
        }
    };
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *data = self.dataArray[indexPath.row];
    if ([data[ktit] isEqualToString:@"设置备注名"]) {
        [self setUpUserNoteName];
    }
}
- (void)createDatas {
    [self.dataArray removeAllObjects];
    if (self.infoModel.is_friend) {
        self.dataArray = [NSMutableArray arrayWithObjects:
                          @{ktit:@"设置备注名" , kval:@""},
                          @{ktit:@"加入黑名单" , kval:@(self.infoModel.is_black)},
                          @{ktit:@"消息免打扰" , kval:@(self.infoModel.is_disturb)},
                          nil];
        if ((self.role == 1) || (self.role==2 && self.member.role==0)) {
            [self.dataArray addObject:@{ktit:@"禁止发言" , kval:@(self.member.is_mute)}];
        }
    }else {
        if ((self.role == 1) || (self.role==2 && self.member.role==0)) {
            self.dataArray = [NSMutableArray arrayWithObjects:
                              @{ktit:@"禁止发言" , kval:@(self.member.is_mute)},
                              nil];
        }
    }
    self.tableConst.constant = self.dataArray.count*60+128;
    
    
    
    [self.friendButton setTitle:self.infoModel.is_friend?@"发消息":@"添加好友" forState:UIControlStateNormal];
    self.deleteButton.hidden = !self.infoModel.is_friend;
    if ([self.toUid isEqualToString:kUser.uid]) {
        [self.dataArray removeAllObjects];
        self.friendButton.hidden = YES;
        self.deleteButton.hidden = YES;
    }
    
    [self.tableView reloadData];
}

//MARK: - REQUEST
/// 获取用户信息
- (void)requestUserDatas {
    [[DCRequestManager sharedManager] requestWithMethod:@"POST" url:@"api/userInfo" parameters:@{@"id":self.toUid} success:^(id  _Nullable result) {
        self.infoModel = [DCMineInfoModel modelWithDictionary:result];
        self.headerView.infoModel = self.infoModel;
        
        [self createDatas];
        DCUserInfo *user = [[DCUserInfo alloc]initWithUserId:self.toUid name:[DCTools isEmpty:self.infoModel.note_name]?self.infoModel.nick_name:self.infoModel.note_name portrait:self.infoModel.avatar];
        [user bg_saveOrUpdateAsync:^(BOOL isSuccess) {
//            bg_closeDB();
        }];
    } failure:^(NSError * _Nonnull error) {
        
    }];
}

/// 好友申请
- (void)applyFriendRequest {
    
    DCMessagePswInputAlert *alert = [DCMessagePswInputAlert xib];
    alert.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
    alert.actionType = 2;
    [[UIApplication sharedApplication].keyWindow.rootViewController.view addSubview:alert];
    [DCTools animationForView:alert.backView];
    [alert.sectetField becomeFirstResponder];
    alert.inputAlertComplete = ^(NSString * _Nullable text) {
        [[DCRequestManager sharedManager] requestWithMethod:@"POST" url:@"api/friendsApply" parameters:@{@"id":self.toUid , @"remark":text?text:@"" , @"notes":@""} success:^(id  _Nullable result) {
            [MBProgressHUD showTips:@"好友申请已发送"];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.navigationController popToRootViewControllerAnimated:YES];
            });
        } failure:^(NSError * _Nonnull error) {
            
        }];
    };
    
    
    
}

/// 设置备注名
- (void)requestSetupUserNotename:(NSString *)name {
    [[DCRequestManager sharedManager] requestWithMethod:@"POST" url:@"api/friendNotes" parameters:@{@"friend_id":self.toUid , @"remark":name} success:^(id  _Nullable result) {
        [self requestUserDatas];
    } failure:^(NSError * _Nonnull error) {
        
    }];
}
/// 拉黑&解除拉黑
- (void)requestBlackUser:(UISwitch *)sender {
    NSString *method = sender.isOn?@"POST":@"PUT";
    [[DCRequestManager sharedManager] requestWithMethod:method url:@"api/friendBlack" parameters:@{@"friend_id":self.toUid} success:^(id  _Nullable result) {
        [MBProgressHUD showTips:sender.isOn?@"加入黑名单成功":@"已从黑名单移除"];
    } failure:^(NSError * _Nonnull error) {
        
    }];
}
/// 删除好友
- (void)requestDeleteFirend {
    [[DCRequestManager sharedManager] requestWithMethod:@"DELETE" url:@"api/friends" parameters:@{@"friend_id":self.toUid} success:^(id  _Nullable result) {
//        [[DCMessageManager sharedManager] deleteConversation:self.toUid];
        [MBProgressHUD showTips:@"好友已删除"];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.navigationController popToRootViewControllerAnimated:YES];
        });
    } failure:^(NSError * _Nonnull error) {
            
    }];
}

// 消息免打扰
- (void)setUpDisturbState:(UISwitch*)sender {
    [[DCRequestManager sharedManager] requestWithMethod:@"POST" url:@"api/friendDisturb" parameters:@{@"friend_id":self.toUid , @"is_disturb":sender.isOn?@(1):@(0)} success:^(id  _Nullable result) {
        [MBProgressHUD showTips:@"操作成功"];
        NSString *where = [NSString stringWithFormat:@"set %@=%@ where %@=%@",bg_sqlKey(@"disturbState"),bg_sqlValue(sender.isOn?@"1":@"0"),bg_sqlKey(@"targetId") , bg_sqlValue(self.toUid)];
        [DCConversationModel bg_update:kConversationListTableName where:where];
    } failure:^(NSError * _Nonnull error) {
        
    }];
}

//MARK: - ACTION
- (void)setUpUserNoteName{
    DCEditInputVC *vc = [[DCEditInputVC alloc]init];
    vc.inputType = KTextInputTypeNoteName;
    vc.editInputBlock = ^(NSString * _Nonnull text) {
        [self requestSetupUserNotename:text];
    };
    [self.navigationController pushViewController:vc animated:YES];
}


- (IBAction)friendItemClick:(id)sender {
    if (self.infoModel.is_friend) {
        if (self.isFromPriveteChat) {
            NSMutableArray *array = [self.navigationController.childViewControllers mutableCopy];
            for (UIViewController *vc in array) {
                NSString *className = [NSString stringWithUTF8String:object_getClassName(vc)];
                if ([className isEqualToString:NSStringFromClass([DCConversationListVC class])]) {
                    [self.navigationController popToViewController:vc animated:YES];
                }
            }
        }else {
            DCConversationListVC *chatVc = [[DCConversationListVC alloc]initWithConversationType:DC_ConversationType_PRIVATE targetId:self.toUid];
            [self.navigationController pushViewController:chatVc animated:YES];
        }
        
    }else {
        [self applyFriendRequest];
    }
}
- (IBAction)deleteFriendClick:(id)sender {
    [self presentViewController:[DCTools actionSheet:@[@"确认删除好友？"] complete:^(int idx) {
        [self requestDeleteFirend];
    }] animated:YES completion:nil];
}


- (void)rightBarButtonAction {
    [self requestUserDatas];
}

/// 遍历VC(避免VC套娃)
- (BOOL)enumerateVC {

    // 得到当前视图控制器中的所有控制器
    NSMutableArray *array = [self.navigationController.childViewControllers mutableCopy];

    for (UIViewController *vc in array) {

        NSString *className = [NSString stringWithUTF8String:object_getClassName(vc)];
        if ([className isEqualToString:NSStringFromClass([DCConversationListVC class])]) {
            [self.navigationController popToViewController:vc animated:YES];
            return YES;
        }
    }
    return NO;
}

@end
