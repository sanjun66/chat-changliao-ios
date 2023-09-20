//
//  DCConversationListVC.h
//  DCProjectFile
//
//  Created  on 2023/6/6.
//

#import "DCBaseViewController.h"
#import "DCMsgInputBarControl.h"
#import "DCStatusDefine.h"
#import "DCUserOnlineStateView.h"
NS_ASSUME_NONNULL_BEGIN

@interface DCConversationListVC : DCBaseViewController
- (id)initWithConversationType:(DCConversationType)conversationType targetId:(NSString *)targetId;
/// 会话id
@property (nonatomic, copy) NSString *targetId;
/// 会话标题
@property (nonatomic, copy) NSString *conversationTitle;
/// 会话类型
@property (nonatomic, assign) DCConversationType conversationType;
/// 底部输入框
@property (nonatomic, strong) DCMsgInputBarControl *inputBarControl;
/// 消息缓存数据
@property (nonatomic, strong) NSMutableArray *cachedReloadMessages;
/// 消息数据
@property (nonatomic, strong) NSMutableArray *messageDatas;
/// 消息列表
@property (nonatomic, strong) UICollectionView *messageCollectionView;
/// 群组信息
@property (nonatomic, strong) DCGroupDataModel *groupData;
/// 对方信息
@property (nonatomic, strong) DCUserInfo *toUserModel;
/// 当前撤回的消息数据
@property (nonatomic, strong) DCMessageContent *currentRevokeModel;
/// 用户在线状态的view
@property (nonatomic, strong) DCUserOnlineStateView *onlineView;

/// 目标消息数据
@property (nonatomic, strong) DCMessageContent *targetSelectModel;
@property (nonatomic, assign) NSInteger targetMessageIndex;

@property (nonatomic, assign) BOOL sendMsgAndNeedScrollToBottom;
@property (nonatomic, copy) void(^throttleReloadAction)(void);
@property (nonatomic, strong) NSOperationQueue *appendMessageQueue;

@property (nonatomic, copy) void(^targetConversationInfoBlock)(DCUserInfo*conversationInfo);
/// 滑动到底部
- (void)scrollToBottomAnimated:(BOOL)animated;

/// 执行刷新
- (void (^)(void))throttleReloadAction;

- (void)getMentionedMeLocation;

/// 当前消息数据所在位置
- (NSIndexPath *)findDataIndexFromMessageList:(DCMessageContent *)model;


- (void)getConversationMessages:(NSInteger)from pageSize:(NSInteger)pageSize isAppend:(BOOL)isAppend targetIdx:(nullable NSNumber*)targetIdx;

@end

NS_ASSUME_NONNULL_END
