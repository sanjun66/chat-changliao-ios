//
//  DCMineMainVC.m
//  DCProjectFile
//
//  Created on 2023/3/1.
//

#import "DCMineMainVC.h"
#import "DCMineTableHeader.h"
#import "DCMineTableCell.h"
#import "DCMineInfoModel.h"
#import "DCMineDataModel.h"
#import "DCInfoEditVC.h"
#import "DCSettingVC.h"
#import "DCPasswordSetVC.h"
#import "SCMyCodeVC.h"
#import "DCWalletVC.h"


@interface DCMineMainVC ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topImgMargin;
@property (weak, nonatomic) IBOutlet UIImageView *avatar;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *accountLabel;

@property (nonatomic, strong) DCMineTableHeader *tableHeader;
@property (nonatomic, strong) DCMineInfoModel *infoModel;

@end

@implementation DCMineMainVC

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [self requestUserInfo];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.topImgMargin.constant = 178-64+kNavHeight;
    
    self.navigationItem.title = @"个人中心";
    [self initDatas];
//    self.tableView.tableHeaderView = self.tableHeader;
    [self.tableView registerNib:[UINib nibWithNibName:@"DCMineTableCell" bundle:nil] forCellReuseIdentifier:@"DCMineTableCell"];
    
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
//    self.tableView.frame = self.view.bounds;
//    self.tableHeader.frame = CGRectMake(0, 0, kScreenWidth, 320);
}
- (void)requestUserInfo {
    [[DCRequestManager sharedManager] requestWithMethod:@"POST" url:@"api/userInfo" parameters:@{@"id":[[DCUserManager sharedManager] userModel].uid} success:^(id  _Nullable result) {
        self.infoModel = [DCMineInfoModel modelWithDictionary:result];
//        self.tableHeader.infoModel = self.infoModel;
        [self.avatar sd_setImageWithURL:[NSURL URLWithString:self.infoModel.avatar] placeholderImage:kPlaceholderImage];
        self.nameLabel.text = self.infoModel.nick_name;
        self.accountLabel.text = [NSString stringWithFormat:@"账号:%@",([DCTools isEmpty:self.infoModel.phone]?self.infoModel.email:self.infoModel.phone)];
        
        DCUserInfo *user = [[DCUserInfo alloc]initWithUserId:[[DCUserManager sharedManager] userModel].uid name:self.infoModel.nick_name portrait:self.infoModel.avatar];
        [DCUserManager sharedManager].currentUserInfo = user;
        
        [user bg_saveOrUpdateAsync:^(BOOL isSuccess) {
//            bg_closeDB();
        }];
    } failure:^(NSError * _Nonnull error) {
        
    }];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DCMineTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DCMineTableCell" forIndexPath:indexPath];
    
    DCMineDataModel *model = self.dataArray[indexPath.row];
    
    cell.titleLabel.text = model.title;
    
    cell.titleImg.image = [UIImage imageNamed:model.imgName];
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (!self.infoModel) {return;}
    DCMineDataModel *model = self.dataArray[indexPath.row];
    Class cls = NSClassFromString(model.controller);
    
    UIViewController *vc = [[cls alloc]init];
    
    if ([vc isKindOfClass:[DCPasswordSetVC class]]) {
        ((DCPasswordSetVC*)vc).isEmail = [DCTools isEmpty:self.infoModel.phone];
        ((DCPasswordSetVC*)vc).isLoginAlso = YES;
    }
    
    if ([vc isKindOfClass:[DCInfoEditVC class]]) {
        ((DCInfoEditVC*)vc).infoModel = self.infoModel;
    }
    
    if ([vc isKindOfClass:[DCSettingVC class]]) {
        ((DCSettingVC*)vc).infoModel = self.infoModel;
    }
    
    if ([vc isKindOfClass:[DCWalletVC class]]) {
        ((DCWalletVC*)vc).account = [DCTools isEmpty:self.infoModel.phone]?self.infoModel.email:self.infoModel.phone;
    }
    
    [self.navigationController pushViewController:vc animated:YES];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 90;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:@"退出登录" forState:UIControlStateNormal];
    [button setTitleColor:kMainColor forState:UIControlStateNormal];
    button.titleLabel.font = kBoldSize(16);
    button.frame = CGRectMake(0, 0, kScreenWidth, 60);
    [button addTarget:self action:@selector(logoutClick) forControlEvents:UIControlEventTouchUpInside];
    UIView *line = [[UIView alloc]init];
    line.backgroundColor = kMainColor;
    line.frame = CGRectMake(kScreenWidth/2-30, 53, 60, 2);
    [button addSubview:line];
    
//    [button setImage:[UIImage imageNamed:@"Icon open-account-logout"] forState:UIControlStateNormal];
//    [button setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 5)];
//    [button setTitleEdgeInsets:UIEdgeInsetsMake(0, 5, 0, 0)];
    return button;
}
- (IBAction)clickAvatar:(id)sender {
    DCInfoEditVC *vc = [[DCInfoEditVC alloc]init];
    vc.infoModel = self.infoModel;
    [[DCTools navigationViewController] pushViewController:vc animated:YES];
}

- (IBAction)clickName:(id)sender {
    [self presentViewController:[DCTools actionSheet:@[@"复制账号"] complete:^(int idx) {
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = ([DCTools isEmpty:self.infoModel.phone]?self.infoModel.email:self.infoModel.phone);
        [MBProgressHUD showTips:@"复制成功"];
    }] animated:YES completion:nil];
}
- (IBAction)qrcodeClick:(id)sender {
    SCMyCodeVC *vc = [[SCMyCodeVC alloc]init];
    [[DCTools navigationViewController] pushViewController:vc animated:YES];
}

- (void)logoutClick {
    [self presentViewController:[DCTools actionSheet:@[@"确认退出登录"] complete:^(int idx) {
        [[DCUserManager sharedManager] cleanUser];
        [[DCUserManager sharedManager] resetRootVc];
    }] animated:YES completion:nil];
}
- (void)initDatas {
    NSArray *imgs = @[@"mine_editIcon",@"mine_pwdIcon",@"mine_wallet",@"mine_setting"];
    NSArray *titles = @[@"编辑资料",@"修改密码",@"我的钱包",@"通用设置"];
    NSArray *controllers = @[@"DCInfoEditVC",@"DCPasswordSetVC",@"DCWalletVC",@"DCSettingVC"];
    for (int i=0; i<titles.count; i++) {
        DCMineDataModel *model = [[DCMineDataModel alloc]init];
        model.imgName = imgs[i];
        model.title = titles[i];
        model.controller = controllers[i];
        [self.dataArray addObject:model];
    }
}
- (DCMineTableHeader *)tableHeader {
    if (!_tableHeader) {
        _tableHeader = [[NSBundle mainBundle]loadNibNamed:@"DCMineTableHeader" owner:self options:nil].lastObject;
        _tableHeader.frame = CGRectMake(0, 0, kScreenWidth, 320);
    }
    return _tableHeader;
}

- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}
@end
