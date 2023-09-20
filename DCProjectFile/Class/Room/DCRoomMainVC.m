//
//  DCRoomMainVC.m
//  DCProjectFile
//
//  Created on 2023/3/1.
//

#import "DCRoomMainVC.h"

#import "DCSearchUserVC.h"
#import "DCFriendApplyVC.h"
#import "DCFriendListCell.h"
#import "DCFriendListModel.h"

#import "DCConversationListVC.h"
#import "DCFriendHeader.h"
#import "DCSortString.h"
#import "DCUserInfoVC.h"

#import <BGDB.h>
#import "DCMessageModel.h"
@interface DCRoomMainVC ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *friendListTableView;
@property (strong, nonatomic) NSMutableArray *dataSource;/**<排序前的整个数据源*/
@property (nonatomic, strong) NSDictionary *friendDatas;/**<排序后的整个数据源*/
@property (strong, nonatomic) NSArray *indexDataSource;/**<索引数据源*/

@property (nonatomic, strong) DCFriendHeader *friendHeader;

@end

@implementation DCRoomMainVC
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:kOnReceiveFriendApplyNotification object:nil];
    [self requestFriendDatas];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"朋友";
    [self rightBarButtonItemWithString:@"msg_add"];
    [self setupTableView];
//    [self loadFriendsDatas];
    [self addNotification];
    [self onCheckComplete];

}

- (void)onCheckComplete {
    DCTabBarController *tabbar = (DCTabBarController *)[UIApplication sharedApplication].keyWindow.rootViewController;
    if ([tabbar isKindOfClass:[DCTabBarController class]]) {
        self.friendHeader.applyNumber = [DCUserManager sharedManager].applyNumber;
    }
    self.friendListTableView.sectionIndexColor = kMainColor;
}
- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.friendHeader.frame = CGRectMake(0, 0, kScreenWidth, 150);
}
//MARK: - notification
- (void)addNotification {
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onFriendApply:) name:kOnReceiveFriendApplyNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onCheckComplete) name:@"tabbarcheckcomplete" object:nil];
}

//- (void)onFriendApply:(NSNotification *)aNotification {
//    dispatch_async(dispatch_get_main_queue(), ^{
//        self.friendHeader.isHaveFriendApply = YES;
//    });
//
//}

//MARK: - load data
- (void)loadFriendsDatas {
    [DCFriendItem bg_findAllAsync:kFriendListTableName complete:^(NSArray * _Nullable array) {
        if (array.count > 0) {
            [self.dataSource removeAllObjects];
            [self.dataSource addObjectsFromArray:array];
            self.friendDatas = [DCSortString sortAndGroupForArray:self.dataSource PropertyName:@"remark"];
            self.indexDataSource = [DCSortString sortForStringAry:[self.friendDatas allKeys]];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.friendListTableView reloadData];
            });
        }
    }];
}

//MARK: - request
- (void)requestFriendDatas {
    [self.friendListTableView ly_startLoading];
    [[DCRequestManager sharedManager] requestWithMethod:@"POST" url:@"api/friends" parameters:nil success:^(id  _Nullable result) {
        [self.dataSource removeAllObjects];
        NSArray *array = result[@"friend_list"];
        
        [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            DCFriendListModel *model = [DCFriendListModel modelWithDictionary:obj];
            [self.dataSource addObjectsFromArray:model.group_list];
        }];
        if (self.dataSource.count > 0) {
            [DCFriendItem bg_saveOrUpdateArrayAsync:self.dataSource complete:^(BOOL isSuccess) {
                
            }];
            self.friendDatas = [DCSortString sortAndGroupForArray:self.dataSource PropertyName:@"remark"];
            self.indexDataSource = [DCSortString sortForStringAry:[self.friendDatas allKeys]];
        }else {
            self.friendDatas = @{};
        }
        
        [self.friendListTableView reloadData];
        [self.friendListTableView ly_endLoading];
    } failure:^(NSError * _Nonnull error) {
        [self.friendListTableView ly_endLoading];
    }];
}


//MARK: - tableview
- (void)setupTableView {
    self.friendListTableView.ly_emptyView = [LYEmptyView emptyViewWithImage:nil titleStr:@"暂无好友" detailStr:nil];
    
    [self.friendListTableView registerNib:[UINib nibWithNibName:NSStringFromClass([DCFriendListCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([DCFriendListCell class])];
    
    self.friendListTableView.tableHeaderView = self.friendHeader;
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
    cell.item = value[indexPath.row];
    
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
    return 75;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *value = [self.friendDatas objectForKey:self.indexDataSource[indexPath.section]];
    DCFriendItem *item = value[indexPath.row];
    DCUserInfoVC *uVc = [[DCUserInfoVC alloc]init];
    uVc.friendItem = item;
    uVc.toUid = item.friend_id;
    [self.navigationController pushViewController:uVc animated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


//MARK: - action
- (void)rightBarButtonAction {
    DCSearchUserVC *vc = [[DCSearchUserVC alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
}


//MARK: - getter
- (NSMutableArray *)dataSource {
    if (!_dataSource) {
        _dataSource = [NSMutableArray array];
    }
    return _dataSource;
}


- (DCFriendHeader *)friendHeader {
    if (!_friendHeader) {
        _friendHeader = [DCFriendHeader xib];
    }
    return _friendHeader;
}
@end
