//
//  DCGroupListVC.m
//  DCProjectFile
//
//  Created  on 2023/7/14.
//

#import "DCGroupListVC.h"
#import "DCFriendListCell.h"
#import "DCFriendListModel.h"
#import "DCConversationListVC.h"
@interface DCGroupListVC ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArray;
@end

@implementation DCGroupListVC
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self requestGroupDatas];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.title = @"群组";
    [self setupTableView];
}

- (void)requestGroupDatas {
    [self.tableView ly_startLoading];
    [[DCRequestManager sharedManager] requestWithMethod:@"POST" url:@"api/groupList" parameters:nil success:^(id  _Nullable result) {
        [self.dataArray removeAllObjects];
        NSArray *array = result[@"group_list"];
        
        [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            DCFriendItem *model = [DCFriendItem modelWithDictionary:obj];
            [self.dataArray addObject:model];
        }];
        
        [self.tableView reloadData];
        [self.tableView ly_endLoading];
    } failure:^(NSError * _Nonnull error) {
        [self.tableView ly_endLoading];
    }];
}


- (void)setupTableView {
    self.tableView.ly_emptyView = [LYEmptyView emptyViewWithImage:nil titleStr:@"暂无群组" detailStr:nil];
    
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([DCFriendListCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([DCFriendListCell class])];
    
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DCFriendListCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([DCFriendListCell class]) forIndexPath:indexPath];
    cell.item = self.dataArray[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DCFriendItem *item = self.dataArray[indexPath.row];
    if (self.isForwardMsg && self.selectItemBlock) {
        [self.navigationController popViewControllerAnimated:YES];
        self.selectItemBlock(item);
        return;
    }
    DCConversationListVC *chatVc = [[DCConversationListVC alloc]initWithConversationType:DC_ConversationType_GROUP targetId:[NSString stringWithFormat:@"group_%ld",item.group_id]];
    chatVc.conversationTitle = item.name;
    [self.navigationController pushViewController:chatVc animated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

@end
