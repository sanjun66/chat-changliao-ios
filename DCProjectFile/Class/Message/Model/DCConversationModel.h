//
//  DCConversationModel.h
//  DCProjectFile
//
//  Created  on 2023/6/8.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DCConversationModel : NSObject
/*!
 会话类型
 */
@property (nonatomic, assign) DCConversationType conversationType;

/*!
 目标会话ID
 */
@property (nonatomic, copy) NSString *targetId;

/*!
 当前会话是否置顶
 */
@property (nonatomic, assign) BOOL isTop;

/*!
 会话中最后一条消息的内容
 */
@property (nonatomic, strong, nullable) DCMessageContent *lastMessage;

/*!
 会话中最后一条消息的发送时间（Unix时间戳、毫秒）
 */
@property (nonatomic, assign) long lastMsgTime;

/*!
 会话中最后一条消息的发送状态
 */
@property (nonatomic, assign) DCSentStatus sentStatus;

/// 是否有人@我
@property (nonatomic, assign) BOOL isMentionedMe;

@property (nonatomic, assign) NSInteger unReadMessageCount;

@property (nonatomic, strong, nullable) DCUserInfo *conversationInfo;

@property (nonatomic, assign) NSString *disturbState;
//自定义排序方法
- (NSComparisonResult)compareConversatonDatas:(DCConversationModel *)conversation;

@end

NS_ASSUME_NONNULL_END
