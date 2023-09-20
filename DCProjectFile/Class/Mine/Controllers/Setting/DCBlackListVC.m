//
//  DCBlackListVC.m
//  DCProjectFile
//
//  Created  on 2023/7/19.
//

#import "DCBlackListVC.h"
#import "DCFriendListCell.h"
#import "DCFriendListModel.h"

@interface DCBlackListVC ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArray;

@end

@implementation DCBlackListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"黑名单";
    [self setUpTableView];
    [self requestBlackUserDatas:nil];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DCFriendListCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([DCFriendListCell class]) forIndexPath:indexPath];
    cell.item = self.dataArray[indexPath.row];
    return cell;
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"删除";
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
//        [tableView beginUpdates];
        DCFriendItem *conv = self.dataArray[indexPath.row];
//        [self.dataArray removeObject:conv];
//        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationNone];
//        [tableView endUpdates];
//        if (self.dataArray.count==0) {
//            [self.tableView ly_showEmptyView];
//        }
        [self requestBlackUserDatas:conv.friend_id];
    }
}
- (void)requestBlackUserDatas:(nullable NSString *)uid {
    NSString *method = @"POST";
    NSDictionary *parms = nil;
    NSString *url = @"api/friendBlackList";
    [self.tableView ly_startLoading];
    if (uid) {
        url = @"api/friendBlack";
        method = @"PUT";
        parms = @{@"friend_id":uid};
        [self.tableView ly_endLoading];
    }
    
    [[DCRequestManager sharedManager] requestWithMethod:method url:url parameters:parms success:^(id  _Nullable result) {
        if (!uid) {
            [self.dataArray removeAllObjects];
            if ([result[@"friend_black"] isKindOfClass:[NSArray class]]) {
                NSArray *array = result[@"friend_black"];
                if (array.count > 0) {
                    [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        DCFriendItem *item = [DCFriendItem modelWithDictionary:obj];
                        [self.dataArray addObject:item];
                    }];
                }
            }
            [self.tableView reloadData];
            [self.tableView ly_endLoading];
        }else {
            [self requestBlackUserDatas:nil];
        }
    } failure:^(NSError * _Nonnull error) {
        [self.tableView ly_endLoading];
    }];
}


//MARK: - setter & getter & add

- (void)setUpTableView {
    self.tableView.ly_emptyView = [LYEmptyView emptyViewWithImage:nil titleStr:@"暂无数据" detailStr:nil];
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([DCFriendListCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([DCFriendListCell class])];
}

- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}
@end
