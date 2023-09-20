//
//  DCMessageManager.h
//  DCProjectFile
//
//  Created  on 2023/6/8.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DCMessageManager : NSObject
@property (nonatomic, assign) BOOL isExclusiveSoundPlayer;
@property (nonatomic, assign) NSInteger unReadMsgCount;

+ (instancetype)sharedManager;

/// 清除会话未读消息
- (void)cleanConversationUnReadMessages:(NSString *)targetId;

/// 删除会话以及属于该会话的消息
- (void)deleteConversation:(NSString *)targetId;

/// 删除消息
- (void)deleteMessage:(NSString *)messageId;

- (void)checkConversationLastMsgWith:(DCMessageContent *)message saveMessage:(DCMessageContent *)saveMsg;

- (void)saveConversationLastMessage:(DCMessageContent *)saveMsg conversation:(DCConversationModel *)model;

/// 将会话中的@信息清空
- (void)cleanConversationMentionedInfo:(NSString *)targetId;

/// 将会话中收到的消息设为已读
- (void)setReceiveMessageRead:(NSString *)targetId;

- (void)messageIndexOfObject:(DCMessageContent *)model complete:(void(^)(NSInteger idx))complete;

@end

NS_ASSUME_NONNULL_END
