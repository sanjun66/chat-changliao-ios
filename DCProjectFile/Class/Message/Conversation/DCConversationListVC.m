//
//  DCConversationListVC.m
//  DCProjectFile
//
//  Created  on 2023/6/6.
//

#import "DCConversationListVC.h"

#import "DCTextMessageCell.h"
#import "DCImageMessageCell.h"
#import "DCVoiceMessageCell.h"
#import "DCVideoMessageCell.h"
#import "DCFileMessageCell.h"
#import "DCReminderMessageCell.h"
#import "DCSecretMessageCell.h"
#import "DCCallMessageCell.h"
#import "DCForwardMessageCell.h"
#import "DCMsgPositionedView.h"
#import "DCGroupInfoVC.h"
#import "DCIMThreadLock.h"
#import "DCUserInfoVC.h"
#import "DCGroupCreateVC.h"

#import "DCSystemSoundPlayer.h"
#import "DCMsgForwardCheckVC.h"
#import "DCNavigationController.h"
#import "DCMsgForwardBottomView.h"
#import "DCMsgForwardListVC.h"

#import "DCConversationListVC+Notification.h"
#import "DCConversationListVC+Request.h"
#import "DCConversationListVC+Action.h"

@interface DCConversationListVC ()
<
UICollectionViewDelegate,
UICollectionViewDataSource,
UICollectionViewDelegateFlowLayout,
DCMsgInputBarControlDelegate,
DCMessageCellDelegate,
UIDocumentInteractionControllerDelegate,
DCMsgPositionedViewDelegate
>


@property (nonatomic, strong) NSMutableDictionary *cellMsgDict;
@property (nonatomic, strong) UITapGestureRecognizer *resetBottomTapGesture;
@property (nonatomic, strong) DCMessageContent *currentSelectedModel;
@property (nonatomic, strong) NSMutableArray *selectMsgArray;
@property (nonatomic, assign) BOOL isCollectionViewEditing;
@property (nonatomic, strong) DCMsgPositionedView *positionedView;
@property (nonatomic, strong) DCIMThreadLock *threadLock;
@property (nonatomic, strong) UIDocumentInteractionController * document;
@property (nonatomic, strong) DCMsgForwardBottomView *forwardView;
@property (nonatomic, strong) NSMutableArray *mentionedMeArray;

@end

@implementation DCConversationListVC

//MARK: - Life Cycle
- (id)initWithConversationType:(DCConversationType)conversationType targetId:(NSString *)targetId {
    self = [super init];
    if (self) {
        self.conversationType = conversationType;
        self.targetId = targetId;
        [DCSocketClient sharedInstance].conversationType = conversationType;
    }
    return self;
}
- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self dcinit];
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self dcinit];
    }
    return self;
}
- (void)dcinit {
    self.threadLock = [DCIMThreadLock new];
    self.cellMsgDict = [[NSMutableDictionary alloc] init];
    self.cachedReloadMessages = [NSMutableArray new];
    self.appendMessageQueue = [NSOperationQueue new];
    self.mentionedMeArray = [[NSMutableArray alloc]init];
    self.appendMessageQueue.maxConcurrentOperationCount = 1;
    self.appendMessageQueue.name = @"cn.dcfile.appendMessageQueue";
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self requesetConversationInfo];
    [IQKeyboardManager sharedManager].enable = NO;
    [self.messageCollectionView addGestureRecognizer:self.resetBottomTapGesture];
}

- (void)viewWillDisappear:(BOOL)animated {
    [IQKeyboardManager sharedManager].enable = YES;
    [self.messageCollectionView addGestureRecognizer:self.resetBottomTapGesture];
    [self.inputBarControl cancelVoiceRecord];
    [self stopPlayingVoiceMessage];
    [[DCMessageManager sharedManager] cleanConversationUnReadMessages:self.targetId];
    // 将数据库中收到的消息设置为已读
    [[DCMessageManager sharedManager] setReceiveMessageRead:self.targetId];
}
- (void)dealloc {
    [[DCSystemSoundPlayer defaultPlayer] resetIgnoreConversation];
    [DCSocketClient sharedInstance].secretPsw = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [[DCSystemSoundPlayer defaultPlayer] setIgnoreConversationType:self.conversationType targetId:self.targetId];
    [self rightBarButtonItemWithString:@"msg_more"];
    [self.view addSubview:self.messageCollectionView];
    [self.view addSubview:self.inputBarControl];
    [self setUpCollectionView];
    if (self.conversationType==DC_ConversationType_PRIVATE) {
        [self.view addSubview:self.onlineView];
        [self requestUserOnlineState];
    }
    
    [self registerClass:[DCTextMessageCell class]];
    [self registerClass:[DCImageMessageCell class]];
    [self registerClass:[DCVoiceMessageCell class]];
    [self registerClass:[DCVideoMessageCell class]];
    [self registerClass:[DCFileMessageCell class]];
    [self registerClass:[DCReminderMessageCell class]];
    [self registerClass:[DCSecretMessageCell class]];
    [self registerClass:[DCCallMessageCell class]];
    [self registerClass:[DCForwardMessageCell class]];
    
    if (self.targetSelectModel) {
        NSInteger totalSize = ceilf(self.targetMessageIndex/20.f) * 20;
        [self getConversationMessages:0 pageSize:totalSize isAppend:NO targetIdx:@(self.targetMessageIndex)];
    }else {
        [self getConversationMessages:0 pageSize:20 isAppend:NO targetIdx:nil];
    }
    
    [self addNotification];
    
    [self getMentionedMeLocation];
    
}


- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
}

- (void (^)(void))throttleReloadAction {
    if (!_throttleReloadAction) {
        __weak typeof(self) ws = self;
        _throttleReloadAction = [self getThrottleActionWithTimeInteval:0.3 action:^{
            if(ws.cachedReloadMessages.count <= 0) {
                return;
            }
            for (int i=0; i<ws.cachedReloadMessages.count; i++) {
                [ws.messageDatas insertObject:ws.cachedReloadMessages[i] atIndex:0];
            }
            NSInteger itemsCount = [ws.messageCollectionView numberOfItemsInSection:0];
            NSInteger differenceValue = ws.messageDatas.count - itemsCount;
        
            // 符合insert条件才执行
            if (itemsCount > 0 && ws.cachedReloadMessages.count == differenceValue) {
                NSMutableArray *reloadIndexPaths = [NSMutableArray new];
                for (int i=0 ; i<ws.cachedReloadMessages.count ; i++) {
                    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
                    [reloadIndexPaths insertObject:indexPath atIndex:0];
                }
                [ws.messageCollectionView insertItemsAtIndexPaths:reloadIndexPaths];
                [ws.messageCollectionView reloadItemsAtIndexPaths:reloadIndexPaths];
            } else {
                [ws.messageCollectionView reloadData];
            }

            [ws.cachedReloadMessages removeAllObjects];
            if (ws.sendMsgAndNeedScrollToBottom || [ws isAtTheBottomOfTableView]) {
                [ws scrollToBottomAnimated:YES];
                ws.sendMsgAndNeedScrollToBottom = NO;
            }
        }];
    }
    return _throttleReloadAction;
}

- (void(^)(void))getThrottleActionWithTimeInteval:(double)timeInteval action:(void(^)(void))action {
    __block BOOL canAction = NO;
    __weak typeof(self) weakSelf = self;
    return ^{
        if (weakSelf.sendMsgAndNeedScrollToBottom) {
            canAction = NO;
            dispatch_main_async_safe(^{
                action();
            });
            return;
        }else if (canAction == NO) {
            canAction = YES;
        } else {
            return;
        }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(timeInteval * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (!canAction) {
                return;
            }
            canAction = NO;
            action();
        });
    };
}
- (BOOL)isAtTheBottomOfTableView {
    return [self.messageCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]] != nil;;
}
- (void)scrollToBottomAnimated:(BOOL)animated {
    if ([self.messageCollectionView numberOfSections] == 0) {
        return;
    }
    NSInteger count = [self.messageCollectionView numberOfItemsInSection:0];
    if (count <= 0) {
        return;
    }
//    NSUInteger finalRow = count - 1;
    NSUInteger finalRow = 0;
    NSIndexPath *finalIndexPath = [NSIndexPath indexPathForItem:finalRow inSection:0];
    [self.messageCollectionView scrollToItemAtIndexPath:finalIndexPath
                                                   atScrollPosition:UICollectionViewScrollPositionTop
                                                           animated:animated];
}

- (void)registerClass:(Class)cellClass {
    [self.messageCollectionView registerClass:cellClass
                               forCellWithReuseIdentifier:NSStringFromClass(cellClass)];
    [self.cellMsgDict setObject:cellClass forKey:NSStringFromClass(cellClass)];
}

//MARK: - msgDatas
- (void)getConversationMessages:(NSInteger)from pageSize:(NSInteger)pageSize isAppend:(BOOL)isAppend targetIdx:(nullable NSNumber*)targetIdx {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSInteger total = [DCMessageContent bg_count:kConversationMessageTableName where:[NSString stringWithFormat:@"where %@=%@",bg_sqlKey(@"targetId"),bg_sqlValue(self.targetId)]];
        DCLog(@"total = %ld",total);
        
        NSString* where = [NSString stringWithFormat:@"where %@=%@ order by %@ desc limit %ld,%ld",bg_sqlKey(@"targetId"),bg_sqlValue(self.targetId),bg_sqlKey(@"timestamp"),from,pageSize];
        
        DCLog(@"%@",where);
        
        [DCMessageContent bg_findAsync:kConversationMessageTableName where:where complete:^(NSArray * _Nullable array) {
            if (array.count == 0) {
                dispatch_async(dispatch_get_main_queue(), ^{
//                    [self.messageCollectionView.mj_footer endRefreshing];
                    DCMessageContent *lastModel = nil;
                    if (self.messageDatas.count > 0) {
                        lastModel = self.messageDatas.lastObject;
                    }
                    [self requestCloudMessageList:lastModel];
                });
                return;
            }
            dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
            [array enumerateObjectsUsingBlock:^(DCMessageContent *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                DCMessageContent *nextModel;
                if (idx + 1 < array.count) {
                    nextModel = array[idx + 1];
                }
                if (nextModel) {
                    obj.isDisplayMsgTime = obj.timestamp - nextModel.timestamp >= 180 * 1000;
                }
                
                if (idx == array.count - 1) {
                    obj.isDisplayMsgTime = YES;
                }
                
                if (idx == 0 && self.messageDatas.count > 0) {
                    DCMessageContent *lastModel = self.messageDatas.lastObject;
                    if (lastModel.isDisplayMsgTime && lastModel.timestamp - obj.timestamp < 180 * 1000) {
                        if (lastModel.cellSize.height > 0) {
                            CGSize size = lastModel.cellSize;
                            size.height = lastModel.cellSize.height - 20;
                            lastModel.cellSize = size;
                        }
                    }
                    lastModel.isDisplayMsgTime = lastModel.timestamp - obj.timestamp >= 180 * 1000;
                }
                
                obj.cellSize = CGSizeZero;
            }];
            if (isAppend){
                [self.messageDatas addObjectsFromArray:array];
            }else {
                [self.messageDatas removeAllObjects];
                [self.messageDatas addObjectsFromArray:array];
//                [self.messageDatas sortUsingSelector:@selector(compareMessageDatas:)];
            }
            
            dispatch_semaphore_signal(semaphore);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.messageCollectionView.mj_footer endRefreshing];
                [self.messageCollectionView reloadData];
                if (targetIdx) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [MBProgressHUD hideActivity];
                        NSIndexPath *targetIdxPath = [NSIndexPath indexPathForRow:targetIdx.integerValue inSection:0];
                        
                        [self.messageCollectionView scrollToItemAtIndexPath:targetIdxPath atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:NO];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            DCMessageContent *targetMsg = self.messageDatas[targetIdx.integerValue];
                            targetMsg.isHighlighted = YES;
                            [self.messageCollectionView reloadItemsAtIndexPaths:@[targetIdxPath]];
                            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                targetMsg.isHighlighted = NO;
                                [self.messageCollectionView reloadItemsAtIndexPaths:@[targetIdxPath]];
                            });
                        });
                    });
                }
            });
        }];
        
    });
}
- (NSInteger)idxWithObject:(DCMessageContent *)model {
    NSString* where = [NSString stringWithFormat:@"where %@=%@ order by %@ desc",bg_sqlKey(@"targetId"),bg_sqlValue(self.targetId),bg_sqlKey(@"timestamp")];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block NSInteger selIdx = 0;
    [DCMessageContent bg_findAsync:kConversationMessageTableName where:where complete:^(NSArray * _Nullable array) {
        [array enumerateObjectsUsingBlock:^(DCMessageContent *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isEqual:model]) {
                selIdx = idx;
                *stop = YES;
                dispatch_semaphore_signal(semaphore);
            }
        }];
    }];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    return selIdx;
    
}
- (void)tap4ResetDefaultBottomBarStatus:(UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        [self resetChatInputBarStatus];
    }
}

- (void)resetChatInputBarStatus {
    if (self.inputBarControl.currentBottomBarStatus==KBottomBarKeyboardStatus) {
        [self.inputBarControl.inputTextView resignFirstResponder];
    }
    if (self.inputBarControl.currentBottomBarStatus==KBottomBarEmojiStatus) {
        [self.inputBarControl animationLayoutBottomBarWithStatus:KBottomBarDefaultStatus animated:YES];
        self.inputBarControl.emojiButton.selected = NO;
    }
    if (self.inputBarControl.currentBottomBarStatus==KBottomBarPluginStatus) {
        [self.inputBarControl animationLayoutBottomBarWithStatus:KBottomBarDefaultStatus animated:YES];
    }
}


//MARK: - DCMsgInputBarControlDelegate
- (void)chatInputBar:(DCMsgInputBarControl *)chatInputBar shouldChangeFrame:(CGRect)frame {
    CGRect collectionViewRect = self.messageCollectionView.frame;
    collectionViewRect.size.height = CGRectGetMinY(frame) - collectionViewRect.origin.y;
    [self.messageCollectionView setFrame:collectionViewRect];
    [self scrollToBottomAnimated:NO];
}

- (void)chatInputBar:(DCMsgInputBarControl *)chatInputBar didSendMessage:(NSString *)message mentionedUserIds:(NSString *)uids {
    [[DCSocketClient sharedInstance] createTextMsg:self.targetId content:message mentionedUserIds:uids];
}

- (void)chatInputBar:(DCMsgInputBarControl *)chatInputBar sendCall:(QBRTCConferenceType)conferenceType {
    [self makeCall:conferenceType];
}

- (void)chatInputBar:(DCMsgInputBarControl *)chatInputBar onMentionedUser:(void (^)(NSArray * _Nonnull))complete {
    DCGroupCreateVC *vc = [[DCGroupCreateVC alloc]init];
    vc.isMentionedUser = YES;
    vc.members = self.groupData.group_member;
    vc.createGroupBlock = ^(NSArray * _Nonnull selItems) {
        if (selItems.count <= 0) {return;}
        complete(selItems);
    };
    [self presentViewController:vc animated:YES completion:nil];
    
}
//MARK: - DCMessageCellDelegate
- (void)didTapCellPortrait:(NSString *)userId {
    if (self.inputBarControl.currentBottomBarStatus==KBottomBarKeyboardStatus) {
        [self.inputBarControl.inputTextView resignFirstResponder];
        return;
    }
    if (self.inputBarControl.currentBottomBarStatus==KBottomBarEmojiStatus) {
        [self.inputBarControl animationLayoutBottomBarWithStatus:KBottomBarDefaultStatus animated:YES];
        self.inputBarControl.emojiButton.selected = NO;
        return;
    }
    if (self.inputBarControl.currentBottomBarStatus==KBottomBarPluginStatus) {
        [self.inputBarControl animationLayoutBottomBarWithStatus:KBottomBarDefaultStatus animated:YES];
        return;
    }
    
    DCUserInfoVC *vc = [[DCUserInfoVC alloc]init];
    vc.toUid = userId;
    vc.isFromPriveteChat = self.conversationType==DC_ConversationType_PRIVATE;
    vc.isFromGroupChat = self.conversationType==DC_ConversationType_GROUP;
    if (self.conversationType==DC_ConversationType_GROUP) {
        vc.role = self.groupData.group_info.role;
    }
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)didLongPressCellPortrait:(NSString *)userId {
    if (!self.inputBarControl.isMentionedEnabled ||
        [userId isEqualToString:kUser.uid]) {
        return;
    }
    [[DCUserManager sharedManager]getConversationData:DC_ConversationType_PRIVATE targerId:userId completion:^(DCUserInfo * _Nonnull userInfo) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.inputBarControl addMentionedUser:userInfo];
            [self.inputBarControl.inputTextView becomeFirstResponder];
        });
    }];
    
}


- (void)didTapMessageCell:(DCMessageContent *)model {
    if (self.isCollectionViewEditing) {
        [self onCheckMessage:model isSelect:!model.isSelected];
        return;
    }
    // 文本消息无点击
    if (model.message_type==1) {return;}
    // 图片视频预览，文件跳转，语音播放
    if (model.message_type==2) {
        if (model.extra.type==1) {
            [self didTapVideoImageMessage:model];
        }else if (model.extra.type==2) {
            [self didTapVideoImageMessage:model];
        }else if (model.extra.type==3) {
            [self didTapFileMsg:model];
        }else if (model.extra.type==4) {
            [self didTapVoiceMessage:model];
        }
    }
    // 转发消息
    if (model.message_type==3) {
        DCMsgForwardListVC *vc = [[DCMsgForwardListVC alloc]init];
        vc.model = model;
        [self.navigationController pushViewController:vc animated:YES];
    }
    if (model.message_type==10||model.message_type==11) {
        QBRTCConferenceType conferenceType = model.message_type==10?QBRTCConferenceTypeAudio:QBRTCConferenceTypeVideo;
        [self makeCall:conferenceType];
    }
}

- (void)didLongTouchMessageCell:(DCMessageContent *)model inView:(UIView *)view {
    if (self.isCollectionViewEditing) {return;}
    UIMenuItem *copyItem = [[UIMenuItem alloc] initWithTitle:@"复制"
                                                      action:@selector(onCopyMessage:)];
    UIMenuItem *deleteItem =
        [[UIMenuItem alloc] initWithTitle:@"删除"
                                   action:@selector(onDeleteMessage:)];
    NSMutableArray *items = [NSMutableArray array];
    
    [items addObject:deleteItem];
    if (model.message_type == 1 && !model.is_secret) {
        [items insertObject:copyItem atIndex:0];
    }
    
    if (model.extra.type==3 && !model.is_secret) {
        UIMenuItem *saveItem =
            [[UIMenuItem alloc] initWithTitle:@"分享"
                                       action:@selector(onSaveMessageFile:)];
        [items addObject:saveItem];
    }
    
    
    if (model.msgSentStatus == DC_SentStatus_SENT && model.messageDirection == DC_MessageDirection_SEND && (model.message_type==1||model.message_type==2||model.message_type==3)) {
            UIMenuItem *revokeItem =
                [[UIMenuItem alloc] initWithTitle:@"撤回"
                                           action:@selector(onRevokeMessage:)];
            [items addObject:revokeItem];
    }
    
    if ([self messageSelectEnable:model] || model.message_type==3){
        UIMenuItem *revokeItem =
            [[UIMenuItem alloc] initWithTitle:@"转发"
                                       action:@selector(onForwardMessage:)];
        [items addObject:revokeItem];
    }
    
    UIMenuItem *revokeItem =
        [[UIMenuItem alloc] initWithTitle:@"多选"
                                   action:@selector(onMultipleChoiceMessage:)];
    [items addObject:revokeItem];
    
    
    self.currentSelectedModel = model;
    if (![self.inputBarControl.inputTextView isFirstResponder]) {
        [self becomeFirstResponder];
    }
    CGRect rect = [self.view convertRect:view.frame fromView:view.superview];

    UIMenuController *menu = [UIMenuController sharedMenuController];
    [menu setMenuItems:items];
    if (@available(iOS 13.0, *)) {
        [menu showMenuFromView:self.view rect:rect];
    } else {
        [menu setTargetRect:rect inView:self.view];
        [menu setMenuVisible:YES animated:YES];
    }
    
}
//删除消息内容
- (void)onDeleteMessage:(id)sender {
    //删除消息时如果是当前播放的消息就停止播放
    if ([DCVoicePlayer defaultPlayer].isPlaying && [[DCVoicePlayer defaultPlayer].messageId isEqualToString:self.currentSelectedModel.messageId]) {
        [[DCVoicePlayer defaultPlayer] stopPlayVoice];
    }
    [self deleteMessage: self.currentSelectedModel];
    [self requestForMessageDelete:self.currentSelectedModel.messageId];
}

- (NSIndexPath *)findDataIndexFromMessageList:(DCMessageContent *)model {
    NSIndexPath *indexPath;
    for (int i = 0; i < self.messageDatas.count; i++) {
        DCMessageContent *msg = (self.messageDatas)[i];
        if ([msg.messageId isEqualToString:model.messageId]) {
            indexPath = [NSIndexPath indexPathForItem:i inSection:0];
            break;
        }
    }
    return indexPath;
}
//复制消息内容
- (void)onCopyMessage:(id)sender {
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    [pasteboard setString:self.currentSelectedModel.message];
}

// 文件消息分享
- (void)onSaveMessageFile:(id)sender {
    NSString *fileName = [DCFileManager fileName:self.currentSelectedModel.extra.path];
    NSString *filePath = [[DCFileManager getMessageFileCachePath] stringByAppendingPathComponent:fileName];
    if ([DCFileManager isExistsAtPath:filePath]) {
        [self showShareAlert:filePath];
    }else {
        [MBProgressHUD showActivity];
        [[DCRequestManager sharedManager] downloadWithUrl:self.currentSelectedModel.extra.url filePath:filePath success:^(id  _Nullable result) {
            [MBProgressHUD hideActivity];
            [self onSaveMessageFile:nil];
        }];
    }
    
}

- (void)showShareAlert:(NSString *)filePath {
    NSURL *urlPath = [NSURL fileURLWithPath:filePath];
    _document = [UIDocumentInteractionController interactionControllerWithURL:urlPath];
    _document.delegate =  (id)self;
    [_document presentOpenInMenuFromRect:self.view.bounds inView:self.view animated:YES];
}
- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller {
    return self;
}

// 撤回消息
- (void)onRevokeMessage:(id)sender {
    self.currentRevokeModel = self.currentSelectedModel;
    [[DCSocketClient sharedInstance] revokeMessage:self.currentSelectedModel];
}

// 消息重发
- (void)didTapmessageFailedStatusViewForResend:(DCMessageContent *)model {
    [self resentMessage:model];
}

// 消息解密
- (void)didTapSecretMessage:(DCMessageContent *)model inputPwd:(NSString *)pwd {
    if (![DCTools isEmpty:model.pwd]) {
        if ([pwd isEqualToString:model.pwd]) {
            NSIndexPath *idxPath = [self findDataIndexFromMessageList:model];
            model.is_secret = NO;
            model.cellSize = CGSizeZero;
            [self.messageCollectionView reloadItemsAtIndexPaths:@[idxPath]];
        }else {
            [MBProgressHUD showTips:@"密码不正确"];
        }
    }else {
        [self requestSecretMessageDecrypt:model pwd:pwd];
    }
    
}


// 消息转发
- (void)onForwardMessage:(id)sender {
    DCMsgForwardCheckVC *vc = [[DCMsgForwardCheckVC alloc]init];
    vc.forwardMsgs = @[self.currentSelectedModel];
    vc.forwardAction = 1;
    DCNavigationController *nav = [[DCNavigationController alloc]initWithRootViewController:vc];
    nav.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:nav animated:YES completion:nil];
}

// 消息多选
- (void)onMultipleChoiceMessage:(id)sender {
    [self resetChatInputBarStatus];
    [self.view addSubview:self.forwardView];
    self.isCollectionViewEditing = YES;
    [self rightBarButtonItemWithString:@"取消"];
    if ([self messageSelectEnable:self.currentSelectedModel]) {
        self.currentSelectedModel.isSelected = YES;
        [self.selectMsgArray addObject:self.currentSelectedModel];
        self.forwardView.forwardItem.selected = YES;
    }
    [self.messageCollectionView reloadData];
}

- (void)onCheckMessage:(DCMessageContent *)model isSelect:(BOOL)isSelect {
    if (![self messageSelectEnable:model]) {return;}
    
    if (self.selectMsgArray.count>=50) {
        [MBProgressHUD showTips:@"最多选择50条"];
        return;
    }
    if (isSelect) {
        [self.selectMsgArray addObject:model];
    }else {
        [self.selectMsgArray removeObject:model];
    }
    NSIndexPath *indexPath = [self findDataIndexFromMessageList:model];
    model.isSelected = isSelect;
    [self.messageCollectionView reloadItemsAtIndexPaths:@[indexPath]];
    
    self.forwardView.forwardItem.selected = self.selectMsgArray.count>0;
}

- (BOOL)messageSelectEnable:(DCMessageContent *)model {
    if ((model.message_type==1 || (model.message_type==2 && model.extra.type != 4)) && !model.is_secret) {
        if (model.messageDirection==DC_MessageDirection_RECEIVE ||
            (model.messageDirection==DC_MessageDirection_SEND && model.msgSentStatus==DC_SentStatus_SENT)) {
            return YES;
        }
    }
    return NO;
}

//MARK: - UICollectionViewDelegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.messageDatas.count;
}


- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    DCMessageContent *model = self.messageDatas[indexPath.row];
    
    DCMessageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[self cellIdentifier:model] forIndexPath:indexPath];
    if (![cell isKindOfClass:[DCReminderMessageCell class]]) {
        cell.delegate = self;
        cell.isEditing = self.isCollectionViewEditing;
    }
    [cell setDataModel:model];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    DCMessageContent *model = self.messageDatas[indexPath.row];
    if (model.cellSize.height > 0) {
        return model.cellSize;
    }
    Class cls = [self.cellMsgDict objectForKey:[self cellIdentifier:model]];
    CGFloat extraHeight = 20;
    if ([cls isKindOfClass:[DCReminderMessageCell class]]) {
        extraHeight = 0;
    }
    CGSize size = [cls sizeForMessageModel:model withCollectionViewWidth:kScreenWidth referenceExtraHeight:extraHeight];
    model.cellSize = size;
    return size;
    
}
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return self.isCollectionViewEditing;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    DCMessageContent *model = self.messageDatas[indexPath.row];
    if (self.isCollectionViewEditing) {
        [self onCheckMessage:model isSelect:!model.isSelected];
    }
}

//MARK: - DCMsgPositionedViewDelegate
- (void)positionMessageLocaltionWithActionType:(NSInteger)actionType {
//    [MBProgressHUD showActivity];
//    NSInteger targerIdx = [self idxWithObject];
//    NSInteger pageIdx = targerIdx/20;
//    NSInteger fromIdx = pageIdx*20;
//    if (self.messageDatas.count >= targerIdx) {
//        NSIndexPath *targetIdxPath = [NSIndexPath indexPathForRow:targerIdx inSection:0];
//        [MBProgressHUD hideActivity];
//        [self.messageCollectionView scrollToItemAtIndexPath:targetIdxPath atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:YES];
//        return;
//    }
//    [self getConversationMessages:self.messageDatas.count pageSize:fromIdx isAppend:YES targetIdx:@(targerIdx)];
}
//MARK: - action

- (void)getMentionedMeLocation {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSString* where = [NSString stringWithFormat:@"where %@=%@ and %@=%@ and %@=%@ order by %@ desc",bg_sqlKey(@"targetId"),bg_sqlValue(self.targetId),bg_sqlKey(@"messageDirection"),bg_sqlValue(@(2)),bg_sqlKey(@"is_read"),bg_sqlValue(@(0)),bg_sqlKey(@"timestamp")];
        
        
        [DCMessageContent bg_findAsync:kConversationMessageTableName where:where complete:^(NSArray * _Nullable array) {
            [array enumerateObjectsUsingBlock:^(DCMessageContent *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                NSLog(@"%@",obj.message);
                if (idx==0) {
                    [self requestReportMessageRead:obj.messageId];
                }
                if ([obj.warn_users containsString:kUser.uid] || [obj.warn_users isEqualToString:@"0"]) {
                    [self.mentionedMeArray addObject:@(idx)];
                }
            }];
            
            if (self.mentionedMeArray.count > 0) {
                [[DCMessageManager sharedManager] cleanConversationMentionedInfo:self.targetId];
//                self.positionedView.noticeString = [NSString stringWithFormat:@"您有%ld条@消息",self.mentionedMeArray.count];
//                [self.view addSubview:self.positionedView];
            }
        }];
    });
}

- (void)rightBarButtonAction {
    if ([((UIButton *)self.navigationItem.rightBarButtonItem.customView).titleLabel.text isEqualToString:@"取消"]) {
        self.isCollectionViewEditing = NO;
        [self.forwardView.forwardItem removeTarget:self action:@selector(multipleChoiceItemClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.forwardView removeFromSuperview];
        self.forwardView = nil;
        
        [self.selectMsgArray enumerateObjectsUsingBlock:^(DCMessageContent *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            obj.isSelected = NO;
        }];
        [self.selectMsgArray removeAllObjects];
        [self.messageCollectionView reloadData];
        [self rightBarButtonItemWithString:@"msg_more"];
        return;
    }
    if (self.conversationType == DC_ConversationType_GROUP) {
        if (self.groupData.code==422) {
            [MBProgressHUD showTips:@"您未加入此群聊"];
            return;
        }
        DCGroupInfoVC *groupVc = [[DCGroupInfoVC alloc]init];
        groupVc.groupId = self.targetId;
        groupVc.groupData = self.groupData;
        [self.navigationController pushViewController:groupVc animated:YES];
    }else {
        DCUserInfoVC *vc = [[DCUserInfoVC alloc]init];
        vc.toUid = self.targetId;
        vc.isFromPriveteChat = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }
    
}

- (void)multipleChoiceItemClick:(UIButton *)sender {
    if (!sender.isSelected) {return;}
    [self presentViewController:[DCTools actionSheet:@[@"逐条转发",@"合并转发"] complete:^(int idx) {
        DCMsgForwardCheckVC *vc = [[DCMsgForwardCheckVC alloc]init];
        vc.forwardMsgs = self.selectMsgArray.copy;
        vc.forwardAction = idx + 1;
        DCNavigationController *nav = [[DCNavigationController alloc]initWithRootViewController:vc];
        nav.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:nav animated:YES completion:^{
            [self rightBarButtonAction];
        }];
    }] animated:YES completion:nil];
    
}

//MARK: - pravite method
- (NSString *)cellIdentifier:(DCMessageContent *)model {
    NSString *key = @"";
    if (model.is_secret) {
        key = NSStringFromClass([DCSecretMessageCell class]);
    }else {
        if (model.message_type == 1) {
            key = NSStringFromClass([DCTextMessageCell class]);
        }else if (model.message_type == 2){
            if (model.extra.type == 1) {
                key = NSStringFromClass([DCImageMessageCell class]);
            }else if (model.extra.type == 2) {
                key = NSStringFromClass([DCVideoMessageCell class]);
            }else if (model.extra.type == 3) {
                key = NSStringFromClass([DCFileMessageCell class]);
            }else if (model.extra.type == 4) {
                key = NSStringFromClass([DCVoiceMessageCell class]);
            }
        }else if (model.message_type==3) {
            key = NSStringFromClass([DCForwardMessageCell class]);
        }else if (model.message_type == 9||model.message_type==12) {
            key = NSStringFromClass([DCReminderMessageCell class]);
        }else if (model.message_type == 10 || model.message_type == 11) {
            if (model.talk_type==1) {
                key = NSStringFromClass([DCCallMessageCell class]);
            }else {
                key = NSStringFromClass([DCReminderMessageCell class]);
            }
        }else if (model.message_type == 101 ) {
            key = NSStringFromClass([DCReminderMessageCell class]);
        }
    }
    
    return key;
}
//MARK: - Seter&Geter
- (void)setUpCollectionView {
    self.messageCollectionView.backgroundColor = kBackgroundColor;
    self.messageCollectionView.transform = CGAffineTransformMakeRotation(-M_PI);
    self.messageCollectionView.scrollIndicatorInsets = UIEdgeInsetsMake(0.0, 0.0, 0.0, self.messageCollectionView.bounds.size.width - 8.0);
    __weak typeof(self) weakSelf = self;
    MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        __strong typeof(weakSelf)self = weakSelf;
        [self getConversationMessages:self.messageDatas.count pageSize:20 isAppend:YES targetIdx:nil];
    }];
    footer.refreshingTitleHidden = YES;
    footer.stateLabel.hidden = YES;
    self.messageCollectionView.mj_footer = footer;
}

- (NSMutableArray *)messageDatas {
    if (!_messageDatas) {
        _messageDatas = [NSMutableArray array];
    }
    return _messageDatas;
}
- (DCMsgInputBarControl *)inputBarControl {
    if (!_inputBarControl) {
        _inputBarControl = [[DCMsgInputBarControl alloc]initWithFrame:CGRectMake(0, kScreenHeight-kNavHeight-kBottomSafe-40, kScreenWidth, 40) conversationType:self.conversationType];
        _inputBarControl.delegate = self;
        _inputBarControl.targetId = self.targetId;
    }
    return _inputBarControl;
}

- (UICollectionView *)messageCollectionView {
    if (!_messageCollectionView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc]init];
        flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
        
        _messageCollectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight-kNavHeight-kBottomSafe-40) collectionViewLayout:flowLayout];
        _messageCollectionView.backgroundColor = kWhiteColor;
        _messageCollectionView.delegate = self;
        _messageCollectionView.dataSource = self;
        _messageCollectionView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
    }
    return _messageCollectionView;
}


- (UITapGestureRecognizer *)resetBottomTapGesture {
    if (!_resetBottomTapGesture) {
        _resetBottomTapGesture =
            [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap4ResetDefaultBottomBarStatus:)];
        _resetBottomTapGesture.cancelsTouchesInView = NO;
        _resetBottomTapGesture.delaysTouchesEnded = NO;
    }
    return _resetBottomTapGesture;
}

- (DCMsgPositionedView *)positionedView {
    if (!_positionedView) {
        _positionedView = [[DCMsgPositionedView alloc]initWithFrame:CGRectMake(kScreenWidth-130, 20, 130, 46)];
        _positionedView.delegate = self;
    }
    return _positionedView;
}

- (NSMutableArray *)selectMsgArray {
    if (!_selectMsgArray) {
        _selectMsgArray = [NSMutableArray array];
    }
    return _selectMsgArray;
}

- (DCMsgForwardBottomView *)forwardView {
    if (!_forwardView) {
        _forwardView = [DCMsgForwardBottomView xib];
        
        _forwardView.frame = CGRectMake(0, kScreenHeight-kNavHeight-kTabBarHeight, kScreenWidth, kTabBarHeight);
        [_forwardView.forwardItem addTarget:self action:@selector(multipleChoiceItemClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _forwardView;
}

- (DCUserOnlineStateView *)onlineView {
    if (!_onlineView) {
        _onlineView = [[DCUserOnlineStateView alloc]initWithFrame:CGRectMake(16, 10, 70, 36)];
        
    }
    return _onlineView;
}
@end
