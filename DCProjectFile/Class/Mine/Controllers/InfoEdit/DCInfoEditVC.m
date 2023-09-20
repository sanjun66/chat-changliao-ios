//
//  DCInfoEditVC.m
//  DCProjectFile
//
//  Created  on 2023/7/10.
//

#import "DCInfoEditVC.h"
#import "DCInfoEditCell.h"
#import "DCMineDataModel.h"
#import "DCEditInputVC.h"
@interface DCInfoEditVC ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArray;
@end

@implementation DCInfoEditVC
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.title = @"编辑资料";
    [self initDatas];
    [self.tableView registerNib:[UINib nibWithNibName:@"DCInfoEditCell" bundle:nil] forCellReuseIdentifier:@"DCInfoEditCell"];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DCInfoEditCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DCInfoEditCell" forIndexPath:indexPath];
    if (indexPath.row == 0) {
        cell.descLabel.hidden = YES;
        cell.avatarImgView.hidden = NO;
    }else {
        cell.descLabel.hidden = NO;
        cell.avatarImgView.hidden = YES;
    }
    
    DCMineDataModel *model = self.dataArray[indexPath.row];
    [cell.avatarImgView sd_setImageWithURL:[NSURL URLWithString:model.desc]];
    cell.titLabel.text = model.title;
    cell.descLabel.text = model.desc;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
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
    
    if (indexPath.row == 1) {
        DCEditInputVC *vc = [[DCEditInputVC alloc]init];
        vc.inputType = KTextInputTypeNickName;
        vc.editInputBlock = ^(NSString * _Nonnull text) {
            [self requestForInfoEditWithParms:@{@"nick_name":text} complete:^{
                DCMineDataModel *model = self.dataArray[indexPath.row];
                model.desc = text;
                [tableView reloadRowAtIndexPath:indexPath withRowAnimation:UITableViewRowAnimationNone];
            }];
            
        };
        [self.navigationController pushViewController:vc animated:YES];
    }
    
    if (indexPath.row == 2) {
        [self presentViewController:[DCTools actionSheet:@[@"男",@"女"] complete:^(int idx) {
            [self requestForInfoEditWithParms:@{@"sex":@(idx+1)} complete:^{
                DCMineDataModel *model = self.dataArray[indexPath.row];
                model.desc = idx==0?@"男":@"女";
                [self.tableView reloadRowAtIndexPath:indexPath withRowAnimation:UITableViewRowAnimationNone];
            }];
        }] animated:YES completion:nil];
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
        [self requestSaveUserAvatar:result];
    } failure:^(id  _Nonnull nullable) {
        [MBProgressHUD showTips:@"头像上传失败"];
    }];
    
}
- (void)requestSaveUserAvatar:(NSString*)imageName {
    NSMutableDictionary *parms = [NSMutableDictionary dictionary];
    [parms setObject:imageName forKey:@"image"];
    [parms setObject:[DCUserManager sharedManager].ossModel.oss_status forKey:@"driver"];
    [parms setObject:@"1" forKey:@"type"];
    [[DCRequestManager sharedManager] requestWithMethod:@"POST" url:@"api/modifyAvatarNew" parameters:parms success:^(id  _Nullable result) {
        DCMineDataModel *model = self.dataArray.firstObject;
        model.desc = result[@"avatar"];
        [self.tableView reloadRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] withRowAnimation:UITableViewRowAnimationNone];
    } failure:^(NSError * _Nonnull error) {
        
    }];
    
}
- (void)requestForInfoEditWithParms:(NSDictionary *)parms complete:(void(^)(void))block {
    [[DCRequestManager sharedManager] requestWithMethod:@"PUT" url:@"api/userInfo" parameters:parms success:^(id  _Nullable result) {
        [MBProgressHUD showTips:@"修改成功"];
        block();
    } failure:^(NSError * _Nonnull error) {
        
    }];
}
- (void)initDatas {
    NSString *sex = @"未知";
    if (self.infoModel.sex == 1) {
        sex = @"男";
    }else if (self.infoModel.sex==2) {
        sex = @"女";
    }
    
    NSArray *titles = @[@"头像",@"昵称",@"性别"];
    
    NSArray *descs = @[self.infoModel.avatar , self.infoModel.nick_name,sex];
    
    
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
