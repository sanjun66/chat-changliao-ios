//
//  DCSettingVC.m
//  DCProjectFile
//
//  Created  on 2023/7/10.
//

#import "DCSettingVC.h"
#import "DCMineDataModel.h"
#import "DCInfoEditCell.h"
#import "DCBlackListVC.h"
@interface DCSettingVC ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArray;

@end

@implementation DCSettingVC
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.title = @"通用设置";
    [self initDatas];
    [self.tableView registerNib:[UINib nibWithNibName:@"DCInfoEditCell" bundle:nil] forCellReuseIdentifier:@"DCInfoEditCell"];
    
    UILabel *version = [[UILabel alloc]init];
    version.textColor = HEX(@"#939393");
    version.font = kFontSize(11);
    version.text = [NSString stringWithFormat:@"版本号：%@",kBundleVersion];
    version.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:version];
    [version mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.offset (0);
        make.bottom.offset (-HEIGHT_SCALE(60));
    }];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DCInfoEditCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DCInfoEditCell" forIndexPath:indexPath];
    if (indexPath.row == 0 || indexPath.row == 1) {
        cell.arrow.hidden = YES;
        cell.switchView.hidden = NO;
    }else {
        cell.arrow.hidden = NO;
        cell.switchView.hidden = YES;
    }
    cell.descLabel.hidden = YES;
    cell.avatarImgView.hidden = YES;
    
    DCMineDataModel *model = self.dataArray[indexPath.row];
    cell.titLabel.text = model.title;
    cell.switchView.on = [[NSNumber numberWithString:model.desc] boolValue];
    
    __weak typeof(self) weakSelf = self;
    cell.switchViewBlock = ^(DCInfoEditCell * _Nonnull selCell, BOOL isOn) {
        __strong typeof(weakSelf)self = weakSelf;
        NSIndexPath *selIdxPath = [self.tableView indexPathForCell:selCell];
        if (selIdxPath.row == 0) {
            [self requestForInfoEditWithParms:@{@"apply_auth":@(isOn)}];
        }
        if (selIdxPath.row == 1) {
            [[NSUserDefaults standardUserDefaults] setBool:isOn forKey:@"kisNeedMute"];
        }
    };
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 2) {
        DCBlackListVC *vc = [[DCBlackListVC alloc]init];
        [self.navigationController pushViewController:vc animated:YES];
    }
}
- (void)requestForInfoEditWithParms:(NSDictionary *)parms{
    [[DCRequestManager sharedManager] requestWithMethod:@"PUT" url:@"api/userInfo" parameters:parms success:^(id  _Nullable result) {
        
    } failure:^(NSError * _Nonnull error) {
        
    }];
}

- (void)initDatas {
    
    BOOL isNeedMute = [[NSUserDefaults standardUserDefaults] boolForKey:@"kisNeedMute"];
    
    NSArray *titles = @[@"加我为朋友时需要验证",@"静音所有消息",@"黑名单"];
    
    NSArray *descs = @[[NSString stringWithFormat:@"%ld",self.infoModel.apply_auth], [NSString stringWithFormat:@"%@",@(isNeedMute)],@""];
    
    
    for (int i=0; i<titles.count; i++) {
        DCMineDataModel *model = [[DCMineDataModel alloc]init];
        model.title = titles[i];
        model.desc = descs[i];
        [self.dataArray addObject:model];
    }
}

 - (NSMutableArray *)dataArray {
     if (!_dataArray) {
         _dataArray = [NSMutableArray array];
     }
     return _dataArray;
 }

@end
