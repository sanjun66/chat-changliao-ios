//
//  DCDefineHeader.h
//  DCProjectFile
//
//  Created  on 2023/6/16.
//

#ifndef DCDefineHeader_h
#define DCDefineHeader_h

// 聊天会话列表名称
#define kConversationListTableName [NSString stringWithFormat:@"kConversationListTableName_%@",[DCUserManager sharedManager].userModel.uid]


/// 聊天消息表名称
#define kConversationMessageTableName [NSString stringWithFormat:@"kConversationMessageTableName_%@",[DCUserManager sharedManager].userModel.uid]


#define kFriendListTableName [NSString stringWithFormat:@"kFriendListTableName_%@",[DCUserManager sharedManager].userModel.uid]


#define kConversationUserInfoTableName @"kConversationUserInfoTableName"

/// 会话列表页面的新消息监听
#define kOnNewMessageWhenInConversationListPage @"kOnNewMessageWhenInConversationListPage"


/// 新消息监听
#define kOnNewMessageNotification @"kOnNewMessageNotification"

/// 本地插入一条自己发的消息的通知
#define kInsertSendingMessageNotification @"kInsertSendingMessageNotification"

/// 刷新自己发出的消息的通知
#define kReloadSendMessageNotification @"kReloadSendMessageNotification"

#define kMessageSentFailNotificaiton  @"kMessageSentFailNotificaiton"

/// 更新会话列表页面的最后一条消息的通知
#define kResetConversationLastMsgNotification  @"kResetConversationLastMsgNotification"

/// 视频上传进度发生变化的通知
#define kVideoUploadProgressChangedNotificaiton @"kVideoUploadProgressChangedNotificaiton"

/// 重置列表数据的通知
#define kReloadConversationDatasNotification @"kReloadConversationDatasNotification"

/// 网络状态发生变化后发出的通知
#define kNetworkReachabilityStatusNotification @"kNetworkReachabilityStatusNotification"


/// 清除会话未读消息数量的通知
#define kCleanConversatonUnreadMsgNotification @"kCleanConversatonUnreadMsgNotification"

/// 加好友通知
#define kOnReceiveFriendApplyNotification @"kOnReceiveFriendApplyNotification"

/// 消息被撤回的通知
#define kDidRevokeMessageNotification @"kDidRevokeMessageNotification"

/// 消息重发成功的通知
#define kResentMessageSuccessNotification @"kResentMessageSuccessNotification"

/// 消息已经被读的通知
#define kMessageReadAlsoNotification @"kMessageReadAlsoNotification"

/// 消息密码输入页面即将显示的通知
#define kMessagePswInputAlertWillShowNotification @"kMessagePswInputAlertWillShowNotification"
#define kMessagePswInputAlertDidRemoveNotification @"kMessagePswInputAlertDidRemoveNotification"


/// 好友在线状态发生变化时的通知
#define kUserOnlineStateDidChangeNotification @"kUserOnlineStateDidChangeNotification"



/// oss本地存储key
#define kOssConfigKey @"kOssConfigKey"

#endif /* DCDefineHeader_h */
