//
//  DCGroupManagerVC.m
//  DCProjectFile
//
//  Created  on 2023/9/1.
//

#import "DCGroupManagerVC.h"
#import "DCGroupMemberCell.h"
#import "DCGroupCreateVC.h"
#import "DCFriendListModel.h"
#import "DCUserInfoVC.h"

@interface DCGroupManagerVC ()<UICollectionViewDelegate,UICollectionViewDataSource>

@property (weak, nonatomic) IBOutlet UILabel *noticeLabel;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *dataArray;
@end

@implementation DCGroupManagerVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.title = @"群管理员";

    self.dataArray = [NSMutableArray array];
    [self setupCollectionView];
    [self setupGroupData];
}


- (void)setupGroupData {
    [self.dataArray removeAllObjects];
    self.noticeLabel.text = self.groupData.group_info.manager_explain;
    [self.groupData.group_member enumerateObjectsUsingBlock:^(DCGroupMember * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.role==2) {
            [self.dataArray addObject:obj];
        }
    }];
    
    [self.collectionView reloadData];
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataArray.count + ([kUser.uid isEqualToString:self.groupData.group_info.uid]?2:0);
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    DCGroupMemberCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"DCGroupMemberCell" forIndexPath:indexPath];
    if (indexPath.row == self.dataArray.count) {
        cell.avatar.image = [UIImage imageNamed:@"profile_ic_grid_member_add"];
        cell.nameLabel.text = @"";
    }else if (indexPath.row > self.dataArray.count) {
        cell.avatar.image = [UIImage imageNamed:@"profile_ic_grid_member_delete"];
        cell.nameLabel.text = @"";
    }else {
        DCGroupMember *member = self.dataArray[indexPath.row];
        [cell.avatar sd_setImageWithURL:[NSURL URLWithString:member.avatar]];
        cell.nameLabel.text = member.notes;
    }
    
    return cell;
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row >= self.dataArray.count) {
        BOOL isDelUser = indexPath.row > self.dataArray.count;
        if (isDelUser && self.dataArray.count <= 0) {
            return;
        }
        if (!isDelUser && self.dataArray.count == self.groupData.group_info.max_manager) {
            [MBProgressHUD showTips:@"管理员数量已达上限"];
            return;
        }
        DCGroupCreateVC *vc = [[DCGroupCreateVC alloc]init];
        vc.role = self.groupData.group_info.role;
        if (isDelUser) {
            vc.members = self.dataArray;
        }else {
            NSMutableArray *notMagArray = [NSMutableArray new];
            [self.groupData.group_member enumerateObjectsUsingBlock:^(DCGroupMember * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if (obj.role==0) {
                    [notMagArray addObject:obj];
                }
            }];
            vc.members = notMagArray;
        }
        vc.isSetManager = YES;
        vc.maxNumber = self.groupData.group_info.max_manager-self.dataArray.count;
        
        vc.createGroupBlock = ^(NSArray * _Nonnull selItems) {
            __block NSString *ids = @"";
            [selItems enumerateObjectsUsingBlock:^(DCFriendItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                NSString *msgId;
                if (idx==0) {
                    msgId = [NSString stringWithFormat:@"%@",obj.friend_id];
                }else {
                    msgId = [NSString stringWithFormat:@",%@",obj.friend_id];
                }
                ids = [ids stringByAppendingFormat:@"%@",msgId];
            }];
            [self requestSetUserAdmin:ids isCancelMag:isDelUser];
            
        };
        [[DCTools topViewController] presentViewController:vc animated:YES completion:nil];
    }else {
//        DCGroupMember *member = self.dataArray[indexPath.row];
//        DCUserInfoVC *vc = [[DCUserInfoVC alloc]init];
//        vc.toUid = member.uid;
//        vc.role = self.groupData.group_info.role;
//        vc.member = member;
//        vc.isFromGroupChat = YES;
//        vc.groupMuteBlock = ^(DCGroupMember * _Nonnull selMember, NSInteger action) {
//            if (action==1) {
////                [self requestMuteUser:selMember];
//            }else {
////                [self requestSetUserAdmin:selMember];
//            }
//        };
//        [[DCTools navigationViewController] pushViewController:vc animated:YES];
    }
}
- (void)requestSetUserAdmin:(NSString *)ids isCancelMag:(BOOL)isCancel {
    NSDictionary *parms = @{@"group_id":self.groupData.group_info.groupId , @"user_str":ids , @"is_manager":(isCancel?@(0):@(2))};
    [[DCRequestManager sharedManager] requestWithMethod:@"POST" url:@"api/groupManager" parameters:parms success:^(id  _Nullable result) {
        [MBProgressHUD showTips:@"设置成功"];
        [self requestGroupInfo];
    } failure:^(NSError * _Nonnull error) {
        
    }];
}

- (void)requestGroupInfo {
    NSString *groupId = self.groupData.group_info.groupId;
    [[DCRequestManager sharedManager] requestWithMethod:@"POST" url:@"api/groupInfo" parameters:@{@"id":groupId} success:^(id  _Nullable result) {
        DCGroupDataModel *model = [DCGroupDataModel modelWithDictionary:result];
        self.groupData = model;
        [self setupGroupData];
    } failure:^(NSError * _Nonnull error) {
                
    }];
}

- (void)setupCollectionView {
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
    CGFloat itemW = (kScreenWidth/5);
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc]init];
    flowLayout.itemSize = CGSizeMake(itemW, 100);
    flowLayout.minimumInteritemSpacing = 0;
    flowLayout.minimumLineSpacing = 0;
    self.collectionView.collectionViewLayout = flowLayout;
    [self.collectionView registerNib:[UINib nibWithNibName:@"DCGroupMemberCell" bundle:nil] forCellWithReuseIdentifier:@"DCGroupMemberCell"];
    
}
@end
