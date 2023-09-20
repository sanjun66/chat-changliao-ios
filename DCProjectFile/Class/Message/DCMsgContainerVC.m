//
//  DCMsgContainerVC.m
//  DCProjectFile
//
//  Created  on 2023/6/6.
//

#import "DCMsgContainerVC.h"
#import "DCMessageListCell.h"
#import "DCConversationListVC.h"
#import "DCMessageTitleStatusView.h"
#import "DCMessageDisonnectView.h"
#import "DCSearchUserVC.h"
#import "YBPopupMenu.h"
#import "DCGroupCreateVC.h"
#import "DCFriendListModel.h"
#import "DCFriendApplyVC.h"
#import "SCQRCodeVC.h"
#import "DCMsgSearchHeaderView.h"
#import "DCCloudConversationDataModel.h"

@interface DCMsgContainerVC ()<UITableViewDelegate,UITableViewDataSource,YBPopupMenuDelegate,UITextFieldDelegate>
@property (nonatomic, strong) NSMutableArray *conversationDatas;
@property (nonatomic, strong) DCMessageTitleStatusView *statusView;
@property (nonatomic, strong) DCMessageDisonnectView *disconnectView;
@property (nonatomic, strong) DCMsgSearchHeaderView *searchHeaderView;

@property (weak, nonatomic) IBOutlet UITableView *conversationListTableView;

@end

@implementation DCMsgContainerVC

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self handleTapPushNotification];
}
- (void)dealloc {
    [[DCSocketClient sharedInstance] removeObserver:self forKeyPath:@"kSocketStatus"];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"消息";
    self.navigationItem.titleView = self.statusView;
    [self rightBarButtonItemWithString:@"msg_conv_add"];
    
    [self setUpTableView];
    [self getConversationDatas];
    [self addNotification];
    [[DCSocketClient sharedInstance] addObserver:self forKeyPath:@"kSocketStatus" options:NSKeyValueObservingOptionNew context:nil];
    
    [[DCSocketClient sharedInstance] connect];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidBecomeActiveNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        [self handleTapPushNotification];
    }];
}
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    
    if ([keyPath isEqualToString:@"kSocketStatus"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.statusView.status = (KSocketStatus)[change[@"new"] intValue];
            if (self.statusView.status==KSocketUnknowFailStatus||self.statusView.status==KSocketNetworkFailStatus) {
                self.conversationListTableView.tableHeaderView = self.disconnectView;
            }else {
                self.conversationListTableView.tableHeaderView = nil;
            }
        });
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.disconnectView.frame = CGRectMake(0, 0, kScreenWidth, 50);
}

//MARK: - 通知方法
- (void)addNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onConversationChanged:)
                                                 name:kOnNewMessageWhenInConversationListPage
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(resetConversationDatas:)
                                                 name:kReloadConversationDatasNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(cleanConversationUnreadMsg:)
                                                 name:kCleanConversatonUnreadMsgNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(resetConversationLastMsg:)
                                                 name:kResetConversationLastMsgNotification
                                               object:nil];
}

- (void)onConversationChanged:(NSNotification *)aNotification {
    DCConversationModel *conversation = aNotification.object;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        __block BOOL contains = NO;
        __block NSUInteger selIndex = 0;
        
        [self.conversationDatas enumerateObjectsUsingBlock:^(DCConversationModel *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.targetId isEqualToString:conversation.targetId]) {
                selIndex = idx;
                [self.conversationDatas replaceObjectAtIndex:idx withObject:conversation];
                [self.conversationListTableView reloadRowAtIndexPath:[NSIndexPath indexPathForRow:idx inSection:0] withRowAnimation:UITableViewRowAnimationNone];
                contains = YES;
                *stop = YES;
            }
        }];
        
        if (!contains) {
            [self.conversationDatas insertObject:conversation atIndex:0];
            [self.conversationListTableView reloadData];
        }else {
            if (selIndex != 0) {
                NSIndexPath *sourceIndexPath = [NSIndexPath indexPathForRow:selIndex inSection:0];
                NSIndexPath *destinationIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                [self.conversationListTableView moveRowAtIndexPath:sourceIndexPath toIndexPath:destinationIndexPath];
                [self.conversationDatas sortUsingSelector:@selector(compareConversatonDatas:)];
            }
        }
    });
}

- (void)resetConversationDatas:(NSNotification *)aNotification {
    [self getConversationDatas];
}

- (void)cleanConversationUnreadMsg:(NSNotification *)aNotification {
    DCConversationModel *conversation = aNotification.object;
    [self.conversationDatas enumerateObjectsUsingBlock:^(DCConversationModel *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.targetId isEqualToString:conversation.targetId]) {
            [self.conversationDatas replaceObjectAtIndex:idx withObject:conversation];
            [self.conversationListTableView reloadRowAtIndexPath:[NSIndexPath indexPathForRow:idx inSection:0] withRowAnimation:UITableViewRowAnimationNone];
            *stop = YES;
        }
    }];
}

- (void)resetConversationLastMsg:(NSNotification *)aNotification {
    NSString *targetId = aNotification.object;
    DCMessageContent *lastMsg = aNotification.userInfo ? ([aNotification.userInfo objectForKey:@"message"]) : nil;
    
    [self.conversationDatas enumerateObjectsUsingBlock:^(DCConversationModel *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.targetId isEqualToString:targetId]) {
             
            if (lastMsg) {
                obj.lastMessage = lastMsg;
                obj.lastMsgTime = lastMsg.timestamp;
            }else {
                obj.lastMessage.message = @"";
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.conversationListTableView reloadRowAtIndexPath:[NSIndexPath indexPathForRow:idx inSection:0] withRowAnimation:UITableViewRowAnimationNone];
            });
            *stop = YES;
        }
    }];
}
//MARK: - TableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.conversationDatas.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DCMessageListCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([DCMessageListCell class]) forIndexPath:indexPath];
    cell.dataModel = self.conversationDatas[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    DCConversationModel *model = self.conversationDatas[indexPath.row];
    DCConversationListVC *chatVc = [[DCConversationListVC alloc]initWithConversationType:model.conversationType targetId:model.targetId];
    chatVc.conversationTitle = model.conversationInfo.name;
    [self.navigationController pushViewController:chatVc animated:YES];
    chatVc.targetConversationInfoBlock = ^(DCUserInfo * _Nonnull conversationInfo) {
        if (![conversationInfo isEqual:model.conversationInfo]) {
            model.conversationInfo = conversationInfo;
            [self.conversationListTableView reloadRowAtIndexPath:indexPath withRowAnimation:UITableViewRowAnimationNone];
            [model bg_saveOrUpdateAsync:nil];
        }
    };
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
        [tableView beginUpdates];
        DCConversationModel *conv = self.conversationDatas[indexPath.row];
        [DCMessageManager sharedManager].unReadMsgCount -= conv.unReadMessageCount;
        [self.conversationDatas removeObject:conv];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationNone];
        [tableView endUpdates];
        if (self.conversationDatas.count==0) {
            [self.conversationListTableView ly_showEmptyView];
        }
        [[DCMessageManager sharedManager] deleteConversation:conv.targetId];
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return self.searchHeaderView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 50;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    [self presentViewController:[DCTools actionSheet:@[@"搜索好友",@"搜索聊天记录"] complete:^(int idx) {
        DCSearchUserVC *vc = [[DCSearchUserVC alloc]init];
        vc.isSearchMsg = idx==1;
        [self.navigationController pushViewController:vc animated:YES];
    }] animated:YES completion:nil];
    return NO;
}

//MARK: - user action
- (void)rightBarButtonAction {
    [YBPopupMenu showRelyOnView:self.navigationItem.rightBarButtonItem.customView titles:@[@"发起聊天",@"创建群组",@"添加好友",@"扫一扫"] icons:@[@"seal_ic_pop_chat",@"seal_ic_pop_group",@"seal_ic_pop_add",@"seal_ic_pop_scan"] menuWidth:120 otherSettings:^(YBPopupMenu *popupMenu) {
        popupMenu.backColor = kWhiteColor;
        popupMenu.textColor = kTextTitColor;
        popupMenu.font = kNameSize(@"PingFangSC-Medium", 12);
        popupMenu.maxVisibleCount = 4;
//        popupMenu.showMaskView = NO;
        popupMenu.isShowShadow = NO;
        popupMenu.cornerRadius = 3;
        popupMenu.height = 200;
        popupMenu.animationManager.style = YBPopupMenuAnimationStyleScale;
        popupMenu.arrowWidth = 0;
        popupMenu.arrowHeight = 0;
        popupMenu.offset = 16;
        popupMenu.itemHeight = 50;
        popupMenu.delegate = self;
        popupMenu.animationManager.style = YBPopupMenuAnimationStyleNone;
    }];
}
- (void)ybPopupMenu:(YBPopupMenu *)ybPopupMenu didSelectedAtIndex:(NSInteger)index {
    if (index == 0 || index==1) {
        DCGroupCreateVC *vc = [[DCGroupCreateVC alloc]init];
        vc.createGroupBlock = ^(NSArray * _Nonnull selItems) {
            [self creatChatWith:selItems];
        };
        [self presentViewController:vc animated:YES completion:nil];
    }
    if (index == 2) {
        DCSearchUserVC *vc = [[DCSearchUserVC alloc]init];
        [self.navigationController pushViewController:vc animated:YES];
    }
    if (index == 3) {
        SCQRCodeVC *vc = [[SCQRCodeVC alloc]init];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

//MARK: - 处理点击推送进入
- (void)handleTapPushNotification {
    if ([DCUserManager sharedManager].pushUserInfo) {
        NSDictionary *userInfo = [DCUserManager sharedManager].pushUserInfo;
        [DCUserManager sharedManager].pushUserInfo = nil;
        
        NSInteger jump_type = [[userInfo objectForKey:@"jump_type"] integerValue];
        NSString *target_uid = [NSString stringWithFormat:@"%@",[userInfo objectForKey:@"target_uid"]];
        
        if (jump_type==0 || jump_type==1) {
            NSString *targetId = target_uid;
            DCConversationType conversationType = DC_ConversationType_PRIVATE;
            
            if (jump_type==1) {
                targetId = [NSString stringWithFormat:@"group_%@",target_uid];
                conversationType = DC_ConversationType_GROUP;
            }
            
            if ([[DCTools topViewController] isKindOfClass:[DCConversationListVC class]]) {
                DCConversationListVC *vc = (DCConversationListVC *)[DCTools topViewController];
                if ([vc.targetId isEqualToString:targetId]) {
                    return;
                }
            }
            for (UIViewController *vc in [DCTools navigationViewController].childViewControllers) {
                NSString *className = [NSString stringWithUTF8String:object_getClassName(vc)];
                if ([className isEqualToString:NSStringFromClass([DCConversationListVC class])]) {
                    DCConversationListVC *cVc = (DCConversationListVC *)vc;
                    if ([cVc.targetId isEqualToString:target_uid]) {
                        [[DCTools navigationViewController] popToViewController:cVc animated:YES];
                        return;
                    }
                }
            }
            
            DCConversationListVC *chatVc = [[DCConversationListVC alloc]initWithConversationType:conversationType targetId:targetId];
            [[DCTools navigationViewController] pushViewController:chatVc animated:YES];
            
        }else {
            for (UIViewController *vc in [DCTools navigationViewController].childViewControllers) {
                NSString *className = [NSString stringWithUTF8String:object_getClassName(vc)];
                if ([className isEqualToString:NSStringFromClass([DCFriendApplyVC class])]) {
                    DCFriendApplyVC *fVc = (DCFriendApplyVC *)vc;
                    fVc.needReload = YES;
                    [[DCTools navigationViewController] popToViewController:fVc animated:YES];
                    return;
                }
            }
            DCFriendApplyVC *friendVc = [[DCFriendApplyVC alloc]init];
            [[DCTools navigationViewController] pushViewController:friendVc animated:YES];
        }
    }
    
}

//MARK: - 发起聊天
- (void)creatChatWith:(NSArray *)selItems {
    if (selItems.count == 1) {
        DCFriendItem *item = selItems.firstObject;
        DCConversationListVC *chatVc = [[DCConversationListVC alloc]initWithConversationType:DC_ConversationType_PRIVATE targetId:item.friend_id];
        [self.navigationController pushViewController:chatVc animated:YES];
    }else {
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
        [self requestGroupCreate:ids];
    }
}

- (void)requestGroupCreate:(NSString *)ids{
    NSMutableDictionary *parms = [NSMutableDictionary dictionary];
    [parms setObject:ids forKey:@"member_id"];
    
    [[DCRequestManager sharedManager] requestWithMethod:@"POST" url:@"api/createGroup" parameters:parms success:^(id  _Nullable result) {
            
    } failure:^(NSError * _Nonnull error) {
            
    }];
}
//MARK: - setter & getter & add
- (void)setUpTableView {
    self.conversationListTableView.ly_emptyView = [LYEmptyView emptyViewWithImage:nil titleStr:@"暂无消息" detailStr:nil];
    [self.conversationListTableView registerNib:[UINib nibWithNibName:NSStringFromClass([DCMessageListCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([DCMessageListCell class])];
}



- (void)getConversationDatas {
    if (![DCConversationModel bg_isExistForTableName:kConversationListTableName]) {
        [self requestHistoryConversationDatas];
        return;
    }
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSString* where = [NSString stringWithFormat:@"order by %@ desc",bg_sqlKey(@"lastMsgTime")];
        [DCConversationModel bg_findAsync:kConversationListTableName where:where complete:^(NSArray * _Nullable array) {
            if (array.count == 0) {
                [self requestHistoryConversationDatas];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [DCMessageManager sharedManager].unReadMsgCount = 0;
                    [self.conversationDatas removeAllObjects];
                    [self.conversationListTableView reloadData];
                    [self.conversationListTableView ly_showEmptyView];
                });
            }else {
                dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);
                dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
                [self.conversationDatas removeAllObjects];
                __block NSInteger unRead = 0;
                [array enumerateObjectsUsingBlock:^(DCConversationModel *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    if (obj.targetId) {
                        [self.conversationDatas addObject:obj];
                        unRead += obj.unReadMessageCount;
                    }
                }];
                [DCMessageManager sharedManager].unReadMsgCount = unRead;
                dispatch_semaphore_signal(semaphore);
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.conversationListTableView reloadData];
                });
            }
        }];
    });
}


- (void)requestHistoryConversationDatas {
    [[DCRequestManager sharedManager] requestWithMethod:@"POST" url:@"api/getTalkList" parameters:nil success:^(id  _Nullable result) {
        [self.conversationDatas removeAllObjects];
        if ([result isKindOfClass:[NSArray class]]) {
            NSArray *convs = (NSArray *)result;
            if (convs.count > 0) {
                [convs enumerateObjectsUsingBlock:^(NSDictionary *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    DCCloudConversationDataModel *dataModel = [DCCloudConversationDataModel modelWithDictionary:obj];
                    
                    DCMessageContent *msg = [[DCMessageContent alloc]init];
                    msg.message = dataModel.message;
                    msg.is_secret = dataModel.is_pwd;
                    msg.messageId = dataModel.msg_id;
                    msg.message_type = dataModel.message_type;
                    
                    DCUserInfo *convInfo = [[DCUserInfo alloc]initWithUserId:dataModel.targetId name:dataModel.name portrait:dataModel.avatar];
                    
                    DCConversationModel *model = [[DCConversationModel alloc]init];
                    model.conversationInfo = convInfo;
                    model.lastMessage = msg;
                    model.lastMsgTime = dataModel.timestamp;
                    model.conversationType = dataModel.talk_type;
                    model.targetId = dataModel.targetId;
                    model.disturbState = @(dataModel.is_disturb).stringValue;
                    [self.conversationDatas addObject:model];
                    DCLog(@"%@",model.targetId);
                    
                }];
                
                [DCConversationModel bg_saveOrUpdateArrayAsync:self.conversationDatas complete:^(BOOL isSuccess) {
                }];
            }
        }
        [self.conversationListTableView reloadData];
        if (self.conversationDatas.count<=0) {
            [self.conversationListTableView ly_showEmptyView];
        }
        
    } failure:^(NSError * _Nonnull error) {
        
    }];
}

- (NSMutableArray *)conversationDatas {
    if (!_conversationDatas) {
        _conversationDatas = [NSMutableArray array];
    }
    return _conversationDatas;
}


- (DCMessageTitleStatusView *)statusView {
    if (!_statusView) {
        _statusView = [DCMessageTitleStatusView xib];
        _statusView.frame = CGRectMake(0, 0, kScreenWidth, 44);
    }
    return _statusView;
}


- (DCMessageDisonnectView *)disconnectView {
    if (!_disconnectView) {
        _disconnectView = [DCMessageDisonnectView xib];
    }
    return _disconnectView;
}
- (void)reconnectSocket {
    [[DCSocketClient sharedInstance] reConnect];
}

- (DCMsgSearchHeaderView *)searchHeaderView {
    if (!_searchHeaderView) {
        _searchHeaderView = [DCMsgSearchHeaderView xib];
        _searchHeaderView.textField.delegate = self;
        _searchHeaderView.frame = CGRectMake(0, 0, kScreenWidth, 50);
    }
    return _searchHeaderView;
}
@end
