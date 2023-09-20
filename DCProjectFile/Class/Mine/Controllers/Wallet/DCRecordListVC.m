//
//  DCRecordListVC.m
//  DCProjectFile
//
//  Created  on 2023/9/15.
//

#import "DCRecordListVC.h"
#import "DCRecordListCell.h"
#import "DCRecordListModel.h"
@interface DCRecordListVC ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, assign) NSInteger page;
@end

@implementation DCRecordListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.title = @"钱包记录";
    [self.tableView registerNib:[UINib nibWithNibName:@"DCRecordListCell" bundle:nil] forCellReuseIdentifier:@"DCRecordListCell"];
    __weak typeof(self) weakSelf = self;
    MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        __strong typeof(weakSelf)self = weakSelf;
        self.page++;
        [self requestRecordListDatas];
    }];
    footer.refreshingTitleHidden = YES;
    footer.stateLabel.hidden = YES;
    self.tableView.mj_footer = footer;
    
    self.page = 1;
    [self requestRecordListDatas];
}
- (void)requestRecordListDatas {
    [[DCRequestManager sharedManager] requestWithMethod:@"POST" url:@"api/walletDetail" parameters:@{@"page":@(self.page)} success:^(id  _Nullable result) {
        [self.tableView.mj_footer endRefreshing];
        if ([result isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dict = (NSDictionary *)result;
            if (self.page==1) {
                [self.dataArray removeAllObjects];
            }
            if (((NSArray *)dict[@"data"]).count > 0) {
                [(NSArray *)dict[@"data"] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    DCRecordListModel *model = [DCRecordListModel modelWithDictionary:obj];
                    [self.dataArray addObject:model];
                }];
                [self.tableView reloadData];
            }
        }
    } failure:^(NSError * _Nonnull error) {
        [self.tableView.mj_footer endRefreshing];
    }];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DCRecordListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DCRecordListCell" forIndexPath:indexPath];
    cell.model = self.dataArray[indexPath.row];
    return cell; 
}
- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
