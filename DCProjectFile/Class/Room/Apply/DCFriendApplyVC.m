//
//  DCFriendApplyVC.m
//  DCProjectFile
//
//  Created  on 2023/6/14.
//

#import "DCFriendApplyVC.h"
#import "DCFriendApplyCell.h"
#import "DCFriendApplyModel.h"
#import "DCUserInfoVC.h"
#import "DCMessagePswInputAlert.h"

@interface DCFriendApplyVC ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation DCFriendApplyVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"新朋友";
    self.dataArray = [NSMutableArray array];
    [self setupTableView];
    [self requesApplyUserDatas];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(requesApplyUserDatas) name:kOnReceiveFriendApplyNotification object:nil];
}
- (void)setNeedReload:(BOOL)needReload {
    _needReload = needReload;
    if (needReload) {
        [self requesApplyUserDatas];
    }
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DCFriendApplyCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([DCFriendApplyCell class]) forIndexPath:indexPath];
    cell.model = self.dataArray[indexPath.row];
    __weak typeof(self) weakSelf = self;
    cell.actionBlock = ^(DCFriendApplyModel * _Nonnull selModel, NSInteger action) {
        __strong typeof(weakSelf)self = weakSelf;
        if (action==3) {
            DCMessagePswInputAlert *alert = [DCMessagePswInputAlert xib];
            alert.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
            alert.actionType = 3;
            [[UIApplication sharedApplication].keyWindow.rootViewController.view addSubview:alert];
            [DCTools animationForView:alert.backView];
            [alert.sectetField becomeFirstResponder];
            alert.inputAlertComplete = ^(NSString * _Nullable text) {
                [self requestForCheckApply:selModel.id action:action index:indexPath.row reson:text];
            };
            
        }else {
            [self requestForCheckApply:selModel.id action:action index:indexPath.row reson:@""];
        }
    };
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DCFriendApplyModel *model = self.dataArray[indexPath.row];
    DCUserInfoVC *vc = [[DCUserInfoVC alloc]init];
    if ([model.flag isEqualToString:@"maker"]) {
        vc.toUid = model.friend_id;
    }else {
        vc.toUid = model.uid;
    }
    
    [self.navigationController pushViewController:vc animated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)requestForCheckApply:(NSString *)applyId action:(NSInteger)action index:(NSInteger)index reson:(NSString *)string {
    [[DCRequestManager sharedManager] requestWithMethod:@"POST" url:@"api/checkApply" parameters:@{@"id":applyId , @"state":@(action) , @"process_message":string} success:^(id  _Nullable result) {
        DCFriendApplyModel *model = self.dataArray[index];
        model.state = action;
        model.process_message = string;
        [self.tableView reloadRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] withRowAnimation:UITableViewRowAnimationNone];
    } failure:^(NSError * _Nonnull error) {
            
    }];
}
- (void)requesApplyUserDatas {
    [[DCRequestManager sharedManager] requestWithMethod:@"POST" url:@"api/applyList" parameters:nil success:^(id  _Nullable result) {
        [self.dataArray removeAllObjects];
        if (((NSArray *)result[@"apply_list"]).count > 0) {
            [((NSArray *)result[@"apply_list"]) enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                DCFriendApplyModel *model = [DCFriendApplyModel modelWithDictionary:obj];
                [self.dataArray addObject:model];
            }];
            [self.tableView reloadData];
            [self.tableView ly_hideEmptyView];
        }else {
            [self.tableView ly_showEmptyView];
        }
        
    } failure:^(NSError * _Nonnull error) {
            
    }];
}


- (void)setupTableView {
    LYEmptyView *emptyView = [LYEmptyView emptyViewWithImage:nil titleStr:nil detailStr:@"暂无好友申请"];
    emptyView.detailLabFont = kFontSize(14);
    emptyView.detailLabTextColor = kTextSubColor;
    emptyView.autoShowEmptyView = NO;
    self.tableView.ly_emptyView = emptyView;
    [self.tableView ly_hideEmptyView];
    
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([DCFriendApplyCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([DCFriendApplyCell class])];
}
@end
