//
//  DCSearchUserVC.m
//  DCProjectFile
//
//  Created  on 2023/6/14.
//

#import "DCSearchUserVC.h"
#import "DCSearchUserCell.h"
#import "DCSearchUserModel.h"
#import "DCUserInfoVC.h"
#import "DCMessageListCell.h"
#import "DCSearchMsgResultVC.h"
#import "DCConversationListVC.h"
#import "DCMessagePswInputAlert.h"

@interface DCSearchUserVC ()<UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArray;

@end

@implementation DCSearchUserVC
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.dataArray = [NSMutableArray array];
    [self setupTableView];
    self.textField.placeholder = self.isSearchMsg?@"请输入关键词搜索":@"请输入对方账号";
}

- (void)setupTableView {
    LYEmptyView *emptyView = [LYEmptyView emptyViewWithImage:nil titleStr:nil detailStr:@"暂无搜索结果"];
    emptyView.detailLabFont = kFontSize(14);
    emptyView.detailLabTextColor = kTextSubColor;
    emptyView.autoShowEmptyView = NO;
    self.tableView.ly_emptyView = emptyView;
    [self.tableView ly_hideEmptyView];
    if (self.isSearchMsg) {
        [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([DCMessageListCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([DCMessageListCell class])];
    }else {
        [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([DCSearchUserCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([DCSearchUserCell class])];
    }
    
    
    
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.isSearchMsg) {
        DCMessageListCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([DCMessageListCell class]) forIndexPath:indexPath];
        cell.historyMsgs = self.dataArray[indexPath.row];
        return cell;
    }
    DCSearchUserCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([DCSearchUserCell class]) forIndexPath:indexPath];
    cell.model = self.dataArray[indexPath.row];
    cell.applyFriendBlock = ^(DCSearchUserModel * _Nonnull selModel) {
        [self applyFriendRequest:selModel];
    };
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.isSearchMsg) {
        NSArray *msgs = self.dataArray[indexPath.row];
        if (msgs.count==1) {
            DCMessageContent *model = msgs.firstObject;
            [[DCMessageManager sharedManager] messageIndexOfObject:model complete:^(NSInteger idx) {
                DCConversationListVC *chatVc = [[DCConversationListVC alloc]initWithConversationType:model.conversationType targetId:model.targetId];
                if (idx >= 0) {
                    chatVc.targetSelectModel = model;
                    chatVc.targetMessageIndex = idx;
                }
                [self.navigationController pushViewController:chatVc animated:YES];
            }];
            
        }else {
            DCSearchMsgResultVC *vc = [[DCSearchMsgResultVC alloc]init];
            vc.msgs = msgs;
            [self.navigationController pushViewController:vc animated:YES];
        }
    }else {
        DCSearchUserModel *model = self.dataArray.firstObject;
        if (!model.is_friend) {return;}
        DCUserInfoVC *vc = [[DCUserInfoVC alloc]init];
        vc.toUid = model.id;
        [self.navigationController pushViewController:vc animated:YES];
    }
    
}

- (void)applyFriendRequest:(DCSearchUserModel *)model {
    DCMessagePswInputAlert *alert = [DCMessagePswInputAlert xib];
    alert.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
    alert.actionType = 2;
    [[UIApplication sharedApplication].keyWindow.rootViewController.view addSubview:alert];
    [DCTools animationForView:alert.backView];
    [alert.sectetField becomeFirstResponder];
    alert.inputAlertComplete = ^(NSString * _Nullable text) {
        [[DCRequestManager sharedManager] requestWithMethod:@"POST" url:@"api/friendsApply" parameters:@{@"id":model.id , @"remark":text?text:@"" , @"notes":@""} success:^(id  _Nullable result) {
            [MBProgressHUD showTips:@"好友申请已发送"];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.navigationController popViewControllerAnimated:YES];
            });
        } failure:^(NSError * _Nonnull error) {
            
        }];
    };
    
    
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    if (self.isSearchMsg) {
        [self messageSearch:self.textField.text];
    }else {
        [self requestForSearchUser];
    }
    return YES;
}


- (void)requestForSearchUser {
    if ([DCTools isEmpty:self.textField.text]) {return;}
    
    [[DCRequestManager sharedManager] requestWithMethod:@"POST" url:@"api/searchFriends" parameters:@{@"keywords":self.textField.text} success:^(id  _Nullable result) {
        [self.dataArray removeAllObjects];
        NSDictionary *dict = (NSDictionary *)result;
        if ([dict[@"friend_list"] isKindOfClass:[NSArray class]]) {
            NSArray *array = dict[@"friend_list"];
            [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                DCSearchUserModel *model = [DCSearchUserModel modelWithDictionary:obj];
                [self.dataArray addObject:model];
            }];
        }
        [self.tableView reloadData];
        if (self.dataArray.count >0 ){
            [self.tableView ly_hideEmptyView];
        }else {
            [self.tableView ly_showEmptyView];
        }
    } failure:^(NSError * _Nonnull error) {
        
    }];
}


- (IBAction)cleanButtonClick:(id)sender {
    self.textField.text = @"";
    [self.dataArray removeAllObjects];
    [self.tableView reloadData];
    [self.tableView ly_hideEmptyView];
}
- (IBAction)cancelButtonClick:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
    
}

//MARK: - 消息搜索
- (void)messageSearch:(NSString *)keyward {
    [self.dataArray removeAllObjects];
    
    NSString * where = [NSString stringWithFormat:@"where %@ LIKE '%%%@%%' order by %@ desc",bg_sqlKey(@"message"),keyward,bg_sqlKey(@"timestamp")];
    [DCMessageContent bg_findAsync:kConversationMessageTableName where:where complete:^(NSArray * _Nullable array) {
        if (array.count<=0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
                [self.tableView ly_showEmptyView];
            });
        }
        NSMutableDictionary *conversationMsgDict = [NSMutableDictionary dictionary];
        [array enumerateObjectsUsingBlock:^(DCMessageContent *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([conversationMsgDict containsObjectForKey:obj.targetId]) {
                NSMutableArray *sameTargets = [conversationMsgDict objectForKey:obj.targetId];
                if (obj.message_type==1 ||
                    obj.message_type==2 ||
                    obj.message_type==3 ||
                    obj.message_type==10 ||
                    obj.message_type==11)
                {
                    [sameTargets addObject:obj];
                }
                [conversationMsgDict setObject:sameTargets forKey:obj.targetId];
            }else {
                NSMutableArray *sameTargets = [NSMutableArray array];
                if (obj.message_type==1 ||
                    obj.message_type==2 ||
                    obj.message_type==3 ||
                    obj.message_type==10 ||
                    obj.message_type==11)
                {
                    [sameTargets addObject:obj];
                }
                [conversationMsgDict setObject:sameTargets forKey:obj.targetId];
            }
        }];
        [self.dataArray addObjectsFromArray:conversationMsgDict.allValues];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
            [self.tableView ly_hideEmptyView];
        });
    }];
    
}
@end
