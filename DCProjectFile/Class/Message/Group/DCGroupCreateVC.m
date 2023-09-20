//
//  DCGroupCreateVC.m
//  DCProjectFile
//
//  Created  on 2023/7/6.
//

#import "DCGroupCreateVC.h"
#import "DCFriendListCell.h"
#import "DCFriendListModel.h"
#import "DCSortString.h"
#import "DCConversationListVC.h"

@interface DCGroupCreateVC ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *confirmBtn;
@property (strong, nonatomic) NSMutableArray *dataSource;/**<排序前的整个数据源*/
@property (nonatomic, strong) NSDictionary *friendDatas;/**<排序后的整个数据源*/
@property (strong, nonatomic) NSArray *indexDataSource;/**<索引数据源*/

@property (nonatomic, strong) NSMutableArray <DCFriendItem *>*selectArray;

@end

@implementation DCGroupCreateVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.confirmBtn.hidden = self.isForwardMsg;
    [self setupTableView];
    if (self.isDelUser) {
        [self.members enumerateObjectsUsingBlock:^(DCGroupMember * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (self.role==1) {
                if (![obj.uid isEqualToString:kUser.uid]) {
                    DCFriendItem *item = [[DCFriendItem alloc]init];
                    item.remark = obj.notes;
                    item.avatar = obj.avatar;
                    item.friend_id = obj.uid;
                    item.quickblox_id = obj.quickblox_id;
                    item.isSel = NO;
                    [self.dataSource addObject:item];
                }
            }else {
                if (![obj.uid isEqualToString:kUser.uid] && obj.role==0) {
                    DCFriendItem *item = [[DCFriendItem alloc]init];
                    item.remark = obj.notes;
                    item.avatar = obj.avatar;
                    item.friend_id = obj.uid;
                    item.quickblox_id = obj.quickblox_id;
                    item.isSel = NO;
                    [self.dataSource addObject:item];
                }
            }
        }];
        self.friendDatas = [DCSortString sortAndGroupForArray:self.dataSource PropertyName:@"remark"];
        self.indexDataSource = [DCSortString sortForStringAry:[self.friendDatas allKeys]];
        [self.tableView reloadData];
        [self.tableView setEditing:YES animated:NO];
    }else if (self.isCallInvited || self.isMentionedUser || self.isSetManager) {
        [self.dataSource removeAllObjects];
        [self.members enumerateObjectsUsingBlock:^(DCGroupMember * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (![obj.uid isEqualToString:kUser.uid]) {
                DCFriendItem *item = [[DCFriendItem alloc]init];
                item.remark = obj.notes;
                item.avatar = obj.avatar;
                item.friend_id = obj.uid;
                item.quickblox_id = obj.quickblox_id;
                item.isSel = NO;
                [self.dataSource addObject:item];
            }
        }];
        self.friendDatas = [DCSortString sortAndGroupForArray:self.dataSource PropertyName:@"remark"];
        self.indexDataSource = [DCSortString sortForStringAry:[self.friendDatas allKeys]];
        [self.tableView reloadData];
        [self.tableView setEditing:YES animated:NO];
    }else {
        [self loadFriendsDatas];
        [self requestFriendDatas];
    }
    
}
//MARK: - load data
- (void)loadFriendsDatas {
    __weak typeof(self) weakSelf = self;
    [DCFriendItem bg_findAllAsync:kFriendListTableName complete:^(NSArray * _Nullable array) {
        __strong typeof(weakSelf)self = weakSelf;
        if (array.count > 0) {
            [self.dataSource removeAllObjects];
            [self.dataSource addObjectsFromArray:array];
            self.friendDatas = [DCSortString sortAndGroupForArray:self.dataSource PropertyName:@"remark"];
            self.indexDataSource = [DCSortString sortForStringAry:[self.friendDatas allKeys]];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        }
    }];
}
- (void)requestFriendDatas {
    [self.tableView ly_startLoading];
    [[DCRequestManager sharedManager] requestWithMethod:@"POST" url:@"api/friends" parameters:nil success:^(id  _Nullable result) {
        [self.dataSource removeAllObjects];
        NSArray *array = result[@"friend_list"];
        
        [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            DCFriendListModel *model = [DCFriendListModel modelWithDictionary:obj];
            if (self.members.count > 0) {
                [model.group_list enumerateObjectsUsingBlock:^(DCFriendItem * _Nonnull item, NSUInteger idx, BOOL * _Nonnull stop) {
                    [self.members enumerateObjectsUsingBlock:^(DCGroupMember * _Nonnull member, NSUInteger idx, BOOL * _Nonnull stop) {
                        if ([item.friend_id isEqualToString:member.uid]) {
                            item.isSel = YES;
                        }
                    }];
                    [self.dataSource addObject:item];
                }];
            }else {
                [self.dataSource addObjectsFromArray:model.group_list];
            }
        }];
        if (self.dataSource.count > 0) {
            self.friendDatas = [DCSortString sortAndGroupForArray:self.dataSource PropertyName:@"remark"];
            self.indexDataSource = [DCSortString sortForStringAry:[self.friendDatas allKeys]];
            
            if (!self.isForwardMsg) {
                [self.tableView setEditing:YES animated:NO];
            }
            [self.tableView reloadData];
        }
        
        [self.tableView ly_endLoading];
    } failure:^(NSError * _Nonnull error) {
        [self.tableView ly_endLoading];
    }];
}

- (void)setupTableView {
    self.tableView.ly_emptyView = [LYEmptyView emptyViewWithImage:nil titleStr:@"暂无好友" detailStr:nil];
    
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([DCFriendListCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([DCFriendListCell class])];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.friendDatas.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *value = [self.friendDatas objectForKey:self.indexDataSource[section]];
    
    return value.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DCFriendListCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([DCFriendListCell class]) forIndexPath:indexPath];
    NSArray *value = [self.friendDatas objectForKey:self.indexDataSource[indexPath.section]];
    DCFriendItem *item = value[indexPath.row];
    cell.item = item;
    if (item.isSel) {
        [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    }else {
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
    }
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.indexDataSource[section];
}

//右侧索引列表
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return self.indexDataSource;
}

//索引点击事件
- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    [tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:index] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    return index;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleDelete | UITableViewCellEditingStyleInsert;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *value = [self.friendDatas objectForKey:self.indexDataSource[indexPath.section]];
    DCFriendItem *item = value[indexPath.row];
    if (self.isForwardMsg && self.createGroupBlock) {
        [self dismissViewControllerAnimated:YES completion:^{
            self.createGroupBlock(@[item]);
        }];        
        return;
    }
    
    [self.selectArray addObject:item];
    [self checkConfirmBtnStete];
}
- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *value = [self.friendDatas objectForKey:self.indexDataSource[indexPath.section]];
    DCFriendItem *item = value[indexPath.row];
    [self.selectArray removeObject:item];
    [self checkConfirmBtnStete];
}
- (nullable NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.isCallInvited && self.selectArray.count == 3) {
        [MBProgressHUD showTips:@"最多邀请3人"];
        return nil;
    }
    if (self.isSetManager && self.selectArray.count == self.maxNumber) {
        [MBProgressHUD showTips:[NSString stringWithFormat:@"最多设置%ld位管理员",self.maxNumber]];
        return nil;
    }
    NSArray *value = [self.friendDatas objectForKey:self.indexDataSource[indexPath.section]];
    DCFriendItem *item = value[indexPath.row];
    if (item.isSel) {
        return nil;
    }
    return indexPath;
}
- (nullable NSIndexPath *)tableView:(UITableView *)tableView willDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *value = [self.friendDatas objectForKey:self.indexDataSource[indexPath.section]];
    DCFriendItem *item = value[indexPath.row];
    if (item.isSel) {
        return nil;
    }
    return indexPath;
}


- (void)checkConfirmBtnStete {
    if (self.selectArray.count > 0) {
        self.confirmBtn.backgroundColor = kMainColor;
    }else {
        self.confirmBtn.backgroundColor = HEX(@"868A9A");
    }
}
- (IBAction)closeBtnClick:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)confirmBtnClick:(id)sender {
    if (self.selectArray.count > 0 && self.createGroupBlock) {
        if (self.isDelUser) {
            [self presentViewController:[DCTools actionSheet:@[@"确认移出群聊"] complete:^(int idx) {
                [self dismissViewControllerAnimated:YES completion:^{
                    self.createGroupBlock(self.selectArray.copy);
                }];
            }] animated:YES completion:nil];
        }else {
            [self dismissViewControllerAnimated:YES completion:^{
                self.createGroupBlock(self.selectArray.copy);
            }];
        }
    }
}

- (NSMutableArray *)dataSource {
    if (!_dataSource) {
        _dataSource = [NSMutableArray array];
    }
    return _dataSource;
}

- (NSMutableArray *)selectArray {
    if (!_selectArray) {
        _selectArray = [NSMutableArray array];
    }
    return _selectArray;
}

@end
