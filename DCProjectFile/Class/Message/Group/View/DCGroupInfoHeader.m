//
//  DCGroupInfoHeader.m
//  DCProjectFile
//
//  Created  on 2023/7/12.
//

#import "DCGroupInfoHeader.h"
#import "DCGroupMemberCell.h"
#import "DCGroupCreateVC.h"
#import "DCFriendListModel.h"
#import "DCUserInfoVC.h"
@interface DCGroupInfoHeader ()<UICollectionViewDelegate,UICollectionViewDataSource>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIButton *checkAllBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *checkAllHeight;
@property (nonatomic, strong) NSMutableArray *dataArrray;

@end

@implementation DCGroupInfoHeader

- (void)awakeFromNib {
    [super awakeFromNib];
    self.dataArrray = [NSMutableArray array];
    [self setupCollectionView];
}

- (void)setGroupData:(DCGroupDataModel *)groupData {
    _groupData = groupData;
//    NSInteger showTotal = self.isGroupOwner?18:19;
    
//    self.checkAllHeight.constant = groupData.group_member.count > showTotal ? 60:0;
//    self.checkAllBtn.hidden = groupData.group_member.count <= showTotal;
    self.checkAllHeight.constant = 0;
    self.checkAllBtn.hidden = YES;
    [self.dataArrray removeAllObjects];
//    NSArray *showArr = groupData.group_member.count > showTotal ? [groupData.group_member subarrayWithRange:NSMakeRange(0, showTotal)] : groupData.group_member;
    [self.dataArrray addObjectsFromArray:groupData.group_member];
    [self.collectionView reloadData];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataArrray.count + 1 + ((self.isGroupOwner||self.groupData.group_info.role==2) ? 1 : 0);
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    DCGroupMemberCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"DCGroupMemberCell" forIndexPath:indexPath];
    if (indexPath.row == self.dataArrray.count) {
        cell.avatar.image = [UIImage imageNamed:@"profile_ic_grid_member_add"];
        cell.nameLabel.text = @"";
    }else if (indexPath.row > self.dataArrray.count) {
        cell.avatar.image = [UIImage imageNamed:@"profile_ic_grid_member_delete"];
        cell.nameLabel.text = @"";
    }else {
        DCGroupMember *member = self.dataArrray[indexPath.row];
        [cell.avatar sd_setImageWithURL:[NSURL URLWithString:member.avatar]];
        cell.nameLabel.text = member.notes;
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row >= self.dataArrray.count) {
        BOOL isDelUser = indexPath.row > self.dataArrray.count;
        if (isDelUser && self.groupData.group_member.count <= 1) {
            return;
        }
        DCGroupCreateVC *vc = [[DCGroupCreateVC alloc]init];
        vc.role = self.groupData.group_info.role;
        vc.members = self.groupData.group_member;
        vc.isDelUser = isDelUser;
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
            if (isDelUser) {
                [self requestRemoveGroupUser:ids];
            }else {
                [self requestInviteGroupMember:ids];
            }
            
        };
        [[DCTools topViewController] presentViewController:vc animated:YES completion:nil];
    }else {
//        if (!self.isGroupOwner) {
//            return;
//        }
//        DCGroupMember *member = self.dataArrray[indexPath.row];
//        if ([member.uid isEqualToString:kUser.uid]) {
//            return;
//        }
//
//        UIViewController *alert = [DCTools actionSheet:@[member.is_mute?@"解除禁言":@"禁止发言",@"移出群聊"] complete:^(int idx) {
//            if (idx==0) {
//                [self requestMuteUser:member];
//            }
//            if (idx==1) {
//                [self requestRemoveGroupUser:member];
//            }
//        }];
//        [[DCTools topViewController] presentViewController:alert animated:YES completion:nil];
        
        DCGroupMember *member = self.dataArrray[indexPath.row];
        DCUserInfoVC *vc = [[DCUserInfoVC alloc]init];
        vc.toUid = member.uid;
        vc.role = self.groupData.group_info.role;
        vc.member = member;
        vc.isFromGroupChat = YES;
        vc.groupMuteBlock = ^(DCGroupMember * _Nonnull selMember) {
            [self requestMuteUser:selMember];
        };
        [[DCTools navigationViewController] pushViewController:vc animated:YES];
    }
}

- (void)requestInviteGroupMember:(NSString *)ids {
    [[DCRequestManager sharedManager] requestWithMethod:@"POST" url:@"api/inviteGroup" parameters:@{@"id":[self.groupId componentsSeparatedByString:@"_"].lastObject , @"member_id":ids} success:^(id  _Nullable result) {
        if (self.operateCompleteBlock) {
            self.operateCompleteBlock();
        }
    } failure:^(NSError * _Nonnull error) {
        
    }];
}

- (void)requestMuteUser:(DCGroupMember *)member {
    NSDictionary *parms = @{@"group_id":[self.groupId componentsSeparatedByString:@"_"].lastObject , @"id":member.uid , @"is_mute":@(!member.is_mute)};
    
    [[DCRequestManager sharedManager] requestWithMethod:@"POST" url:@"api/muteMemberGroup" parameters:parms success:^(id  _Nullable result) {
        member.is_mute = !member.is_mute;
        [MBProgressHUD showTips:@"操作成功"];
    } failure:^(NSError * _Nonnull error) {

    }];
}

- (void)requestRemoveGroupUser:(NSString *)ids {
    [[DCRequestManager sharedManager] requestWithMethod:@"POST" url:@"api/kickOutGroup" parameters:@{@"group_id":[self.groupId componentsSeparatedByString:@"_"].lastObject , @"id":ids} success:^(id  _Nullable result) {
        if (self.operateCompleteBlock) {
            self.operateCompleteBlock();
        }
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


