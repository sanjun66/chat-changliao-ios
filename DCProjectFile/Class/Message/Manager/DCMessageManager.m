//
//  DCMessageManager.m
//  DCProjectFile
//
//  Created  on 2023/6/8.
//

#import "DCMessageManager.h"

@implementation DCMessageManager
+ (instancetype)sharedManager {
    static DCMessageManager *manager = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

- (void)setUnReadMsgCount:(NSInteger)unReadMsgCount {
    _unReadMsgCount = unReadMsgCount;
    dispatch_async(dispatch_get_main_queue(), ^{
        DCTabBarController *tabbar = (DCTabBarController*)UIApplication.sharedApplication.keyWindow.rootViewController;
        tabbar.redBadge.text = [NSString stringWithFormat:@"%ld",unReadMsgCount];
        tabbar.redBadge.hidden = unReadMsgCount <= 0;
        [UIApplication sharedApplication].applicationIconBadgeNumber = unReadMsgCount;
    });
    
}
- (void)cleanConversationUnReadMessages:(NSString *)targetId {
    NSString * where = [NSString stringWithFormat:@"where %@=%@ ",bg_sqlKey(@"targetId"),bg_sqlValue(targetId)];
    NSArray *historyArray = [DCConversationModel bg_find:kConversationListTableName where:where];
    if (historyArray.count > 0) {
        DCConversationModel *model = historyArray.firstObject;
        [DCMessageManager sharedManager].unReadMsgCount -= model.unReadMessageCount;
        model.unReadMessageCount = 0;
        model.isMentionedMe = NO;
        [[NSNotificationCenter defaultCenter] postNotificationName:kCleanConversatonUnreadMsgNotification object:model];
        [model bg_saveOrUpdate];
    }
}

- (void)deleteConversation:(NSString *)targetId {
    NSString *where = [NSString stringWithFormat:@"where %@=%@",bg_sqlKey(@"targetId"),bg_sqlValue(targetId)];
    [DCConversationModel bg_deleteAsync:kConversationListTableName where:where complete:^(BOOL isSuccess) {
        NSLog(@"会话列表删除成功");
        [self requestForConversationDelete:targetId];
//        [[NSNotificationCenter defaultCenter] postNotificationName:kReloadConversationDatasNotification object:nil];
    }];
    [DCMessageContent bg_deleteAsync:kConversationMessageTableName where:where complete:^(BOOL isSuccess) {
        NSLog(@"会话消息删除成功");
    }];
}

- (void)requestForConversationDelete:(NSString *)targetId {
    NSString *requestId = targetId;
    NSString *talkType = @"1";
    if ([DCTools isGroupId:targetId]) {
        requestId = [targetId componentsSeparatedByString:@"_"].lastObject;
        talkType = @"2";
    }
    [[DCRequestManager sharedManager] requestWithMethod:@"POST" url:@"api/delMeeting" parameters:@{@"id":requestId , @"talk_type":talkType} success:^(id  _Nullable result) {
            
    } failure:^(NSError * _Nonnull error) {
        
    }];
    
}

- (void)deleteMessage:(NSString *)messageId {
    NSString *where = [NSString stringWithFormat:@"where %@=%@",bg_sqlKey(@"messageId"),bg_sqlValue(messageId)];
    [DCMessageContent bg_deleteAsync:kConversationMessageTableName where:where complete:^(BOOL isSuccess) {
        NSLog(@"消息删除成功");
    }];
    
}

- (void)checkConversationLastMsgWith:(DCMessageContent *)message saveMessage:(DCMessageContent *)saveMsg
//                            complete:(void(^)(BOOL same))block
{
    NSString *where = [NSString stringWithFormat:@"where %@=%@",bg_sqlKey(@"targetId"),bg_sqlValue(message.targetId)];
    [DCConversationModel bg_findAsync:kConversationListTableName where:where complete:^(NSArray * _Nullable array) {
        if (array.count>0) {
            DCConversationModel *model = array.firstObject;            
            if ([model.lastMessage.messageId isEqualToString:message.messageId]) {
                [self saveConversationLastMessage:saveMsg conversation:model];
            }
        }
    }];
    
}

- (void)saveConversationLastMessage:(DCMessageContent *)saveMsg conversation:(DCConversationModel *)model {
    NSDictionary *userInfo = nil;
    if (saveMsg) {
        model.lastMessage = saveMsg;
        model.lastMsgTime = saveMsg.timestamp;
        userInfo = @{@"message":saveMsg};
    }else {
        model.lastMessage.message = @"";
    }
    
    [model bg_saveOrUpdateAsync:^(BOOL isSuccess) {
        
    }];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kResetConversationLastMsgNotification object:model.targetId userInfo:userInfo];
}



//MARK: - 将会话中的@信息清空
- (void)cleanConversationMentionedInfo:(NSString *)targetId {
    NSString *sql = [NSString stringWithFormat:@"set %@=%@ where %@=%@ and %@=%@",bg_sqlKey(@"warn_users"),bg_sqlValue(@""),bg_sqlKey(@"targetId"),bg_sqlValue(targetId),bg_sqlKey(@"messageDirection"),bg_sqlValue(@(2))];
    [DCMessageContent bg_update:kConversationMessageTableName where:sql];
}

//MARK: - 将会话中收到的消息设为已读
- (void)setReceiveMessageRead:(NSString *)targetId {
    NSString *sql = [NSString stringWithFormat:@"set %@=%@ where %@=%@ and %@=%@",bg_sqlKey(@"is_read"),bg_sqlValue(@YES),bg_sqlKey(@"targetId"),bg_sqlValue(targetId),bg_sqlKey(@"messageDirection"),bg_sqlValue(@(2))];
    
    BOOL isOk = [DCMessageContent bg_update:kConversationMessageTableName where:sql];
    if (isOk) {
        DCLog(@"更新收到的消息为已读成功");
    }
}



//MARK: - 获取消息所在位置
- (void)messageIndexOfObject:(DCMessageContent *)model complete:(void(^)(NSInteger idx))complete {
    [MBProgressHUD showActivity];
    NSString* where = [NSString stringWithFormat:@"where %@=%@ order by %@ desc",bg_sqlKey(@"targetId"),bg_sqlValue(model.targetId),bg_sqlKey(@"timestamp")];
    
    [DCMessageContent bg_findAsync:kConversationMessageTableName where:where complete:^(NSArray * _Nullable array) {
        [array enumerateObjectsUsingBlock:^(DCMessageContent *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isEqual:model]) {
                *stop = YES;
                dispatch_async(dispatch_get_main_queue(), ^{
                    complete(idx);
                    [MBProgressHUD hideActivity];
                });
            }else {
                if (idx==array.count-1) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        complete(-1);
                        [MBProgressHUD hideActivity];
                    });
                }
            }
        }];
    }];
}
@end
