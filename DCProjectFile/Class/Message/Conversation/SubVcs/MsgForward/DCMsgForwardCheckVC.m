//
//  DCMsgForwardCheckVC.m
//  DCProjectFile
//
//  Created  on 2023/9/6.
//

#import "DCMsgForwardCheckVC.h"
#import "DCMsgForwardCheckHeader.h"
#import "DCFriendListCell.h"

#import "DCGroupCreateVC.h"
#import "DCGroupListVC.h"

@interface DCMsgForwardCheckVC ()<UITableViewDelegate,UITableViewDataSource,DCMsgForwardCheckHeaderDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *conversationDatas;
@property (nonatomic, strong) DCMsgForwardCheckHeader *headerView;

@end

@implementation DCMsgForwardCheckVC
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.tableHeaderView = self.headerView;
    [self.tableView registerNib:[UINib nibWithNibName:@"DCFriendListCell" bundle:nil] forCellReuseIdentifier:@"DCFriendListCell"];
    [self getConversationDatas];
}

- (void)viewDidLayoutSubviews {
    self.headerView.frame = CGRectMake(0, 0, kScreenWidth, 120);
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *secView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 60)];
    secView.backgroundColor = kBackgroundColor;
    UILabel *secLabel = [[UILabel alloc]initWithFrame:CGRectMake(16, 0, kScreenWidth-16, 60)];
    secLabel.text = @"最近聊天";
    secLabel.font = kFontSize(14);
    secLabel.textColor = kTextSubColor;
    [secView addSubview: secLabel];
    return secView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 60;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.conversationDatas.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DCFriendListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DCFriendListCell" forIndexPath:indexPath];
    cell.conversation = self.conversationDatas[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DCConversationModel *conv = self.conversationDatas[indexPath.row];
    [self showForwardAlert:conv.conversationInfo.name targetId:conv.targetId talkType:conv.conversationType];
}
- (void)getConversationDatas {
    if (![DCConversationModel bg_isExistForTableName:kConversationListTableName]) {return;}
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSString* where = [NSString stringWithFormat:@"order by %@ desc",bg_sqlKey(@"lastMsgTime")];
        [DCConversationModel bg_findAsync:kConversationListTableName where:where complete:^(NSArray * _Nullable array) {
            if (array.count == 0) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.conversationDatas removeAllObjects];
                    [self.tableView reloadData];
                });
            }else {
                dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);
                dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
                [self.conversationDatas removeAllObjects];
                [self.conversationDatas addObjectsFromArray:array];
                
                dispatch_semaphore_signal(semaphore);
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableView reloadData];
                });
            }
        }];
    });
}

- (void)msgForwardHeaderSelectorWith:(NSInteger)action {
    if (action==1) {
        DCGroupCreateVC *vc = [[DCGroupCreateVC alloc]init];
        vc.isForwardMsg = self.forwardMsgs.count>0;
        [self presentViewController:vc animated:YES completion:nil];
        vc.createGroupBlock = ^(NSArray * _Nonnull selItems) {
            DCFriendItem * item = selItems.firstObject;
            [self showForwardAlert:([DCTools isEmpty:item.remark]?item.name:item.remark) targetId:item.friend_id talkType:1];
        };
    }else {
        DCGroupListVC *vc = [[DCGroupListVC alloc]init];
        vc.isForwardMsg = self.forwardMsgs.count>0;
        [self.navigationController pushViewController:vc animated:YES];
        vc.selectItemBlock = ^(DCFriendItem * _Nonnull item) {
            [self showForwardAlert:item.name targetId:@(item.group_id).stringValue talkType:2];
        };
    }
}

- (void)showForwardAlert:(NSString *)name targetId:(NSString *)targetId talkType:(NSInteger)talkType {
    [self presentViewController:[DCTools actionSheet:@[[NSString stringWithFormat:@"确认转发给 %@ ",name]] complete:^(int idx) {
        __block NSString *ids = @"";
        [self.forwardMsgs enumerateObjectsUsingBlock:^(DCMessageContent * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *msgId;
            if (idx==0) {
                msgId = [NSString stringWithFormat:@"%@",obj.messageId];
            }else {
                msgId = [NSString stringWithFormat:@",%@",obj.messageId];
            }
            ids = [ids stringByAppendingFormat:@"%@",msgId];
        }];
        [self forwardMessage:ids targetId:targetId talkType:talkType];
    }] animated:YES completion:nil];
}

//MARK: - 转发消息
- (void)forwardMessage:(NSString *)ids targetId:(NSString *)toUid talkType:(NSInteger)talkType {
    NSString *targetId = toUid;
    if ([DCTools isGroupId:targetId]) {
        targetId = [targetId componentsSeparatedByString:@"_"].lastObject;
    }
    NSDictionary *parms = @{@"ids":ids,@"to_uid":targetId,@"talk_type":@(talkType),@"forward_type":@(self.forwardAction)};
    [[DCRequestManager sharedManager] requestWithMethod:@"POST" url:@"api/msgForward" parameters:parms success:^(id  _Nullable result) {
        [MBProgressHUD showTips:@"转发成功"];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self dismissViewControllerAnimated:YES completion:nil];
        });
    } failure:^(NSError * _Nonnull error) {
        
    }];
}


- (IBAction)closeClick:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (DCMsgForwardCheckHeader *)headerView {
    if (!_headerView) {
        _headerView = [DCMsgForwardCheckHeader xib];
        _headerView.delegate = self;
        
    }
    return _headerView;
}

- (NSMutableArray *)conversationDatas {
    if (!_conversationDatas) {
        _conversationDatas = [NSMutableArray array];
    }
    return _conversationDatas;
}


@end
