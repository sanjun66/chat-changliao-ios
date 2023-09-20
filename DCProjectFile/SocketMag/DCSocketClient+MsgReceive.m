//
//  DCSocketClient+MsgReceive.m
//  DCProjectFile
//
//  Created  on 2023/6/19.
//

#import "DCSocketClient+MsgReceive.h"
#import "DCSocketClient+MsgSend.h"
#import "DCSystemSoundPlayer.h"
@implementation DCSocketClient (MsgReceive)
- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message {
    DCLog(@"%@",message);
    DCMessageModel *model = [DCMessageModel modelWithJSON:message];
    if (!model) {return;}
    if (!model.data && model.aesData) {
        NSString *dataString = model.aesData;
        NSString *jsonString = [DCTools AESDecrypt:dataString];
        DCMessageContent *msgContent = [DCMessageContent modelWithJSON:jsonString];
        model.data = msgContent;
    }
    
    [self checkMsgModelWith:model];
}

- (void)checkMsgModelWith:(DCMessageModel*)model {
    
    if (model.code != 200) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD showTips:model.message];
        });
        if (model.code == 402 || model.code==403) {
            [[DCUserManager sharedManager] cleanUser];
            [[DCUserManager sharedManager] resetRootVc];
        }else {
            [[NSNotificationCenter defaultCenter] postNotificationName:kMessageSentFailNotificaiton object:model.uuid];
        }
        
        return;
    }
    
    if ([model.event_name isEqualToString:@"system_message_notice"]){
        // [MBProgressHUD showTips:@"socket已连接"];
        
    }else if ([model.event_name isEqualToString:@"heartbeat"]) {
        
    }else if ([model.event_name isEqualToString:@"system_device_close"]) {
        [self reConnect];
        
    }else if ([model.event_name isEqualToString:@"online_state_change"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kUserOnlineStateDidChangeNotification object:model.data];
    }else if ([model.event_name isEqualToString:@"talk_revoke"]) {
        if (![model.data.from_uid isEqualToString:kUser.uid] || ![model.uuid hasPrefix:@"iOS"]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kDidRevokeMessageNotification object:model.data.messageId];
            [self onRevokeWithMsgId:model.data.messageId];
        }
    }else if ([model.event_name isEqualToString:@"talk_read"]) {
        if (!model.data) {return;}
        [self changeMessageState:model];
    }else if ([model.event_name isEqualToString:@"talk_message"]) {
        if (model.data.messageDirection == DC_MessageDirection_RECEIVE || (model.data.messageDirection==DC_MessageDirection_SEND && ![model.uuid hasPrefix:@"iOS"])) {
            DCMessageContent *message = model.data;
            message.msgSentStatus = DC_SentStatus_SENT;
            message.uuid = model.uuid;
            if (model.data.message_type == 9) {
                message.message = [self getGroupNoticeText:message];
            }
            if (model.data.message_type==12) {
                if (model.data.extra.state == 2) {
                    message.message=@"你们已经成为好友了~";
                }else {
                    return;
                }
            }
            if (model.data.message_type==7) {
                if ([model.data.to_uid isEqualToString:kUser.uid]) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:kOnReceiveFriendApplyNotification object:model.data];
                    return;
                }else {
                    return;
                }
            }
            if (model.data.talk_type==2 && (model.data.message_type==10||model.data.message_type==11)) {
                if (model.data.extra.state==0) {
                    message.message = [NSString stringWithFormat:@"%@ 发起了%@通话",model.data.extra.nickname , (model.data.message_type==10?@"语音":@"视频")];
                }else {
                    message.message = @"通话已结束";
                }
            }
            if (!self.isNeedHandleOfflineMsg) {
                [[NSNotificationCenter defaultCenter] postNotificationName:kOnNewMessageNotification object:message];
            }
            if (model.data.messageDirection == DC_MessageDirection_RECEIVE) {
                [self sentMsgReceipt:model.data.messageId];
            }
            [self saveOnlineMessage:message];
        }
        
        
    }else if ([model.event_name isEqualToString:@"talk_pull"]) {
        if (model.list.count == 0) {
            self.isNeedHandleOfflineMsg = NO;
            [DCSocketClient sharedInstance].kSocketStatus = KSocketDefaultStatus;
            return;
        }
        __block NSString *ids = @"";
        
        NSMutableDictionary *conversationMsgDict = [NSMutableDictionary dictionary];
        
        [model.list enumerateObjectsUsingBlock:^(DCMessageContent * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *msgId;
            if (idx==0) {
                msgId = [NSString stringWithFormat:@"%@",obj.messageId];
            }else {
                msgId = [NSString stringWithFormat:@",%@",obj.messageId];
            }
            ids = [ids stringByAppendingFormat:@"%@",msgId];
            if (obj.message_type == 9) {
                obj.message = [self getGroupNoticeText:obj];
            }
            if (obj.message_type==12) {
                if (obj.extra.state==2) {
                    obj.message = @"你们已经成为好友了~";
                }else {
                    obj.is_revoke = YES;
                }
            }
            if (obj.message_type==7) {
                obj.is_revoke = YES;
            }
            if (obj.talk_type==2 && (obj.message_type==10||obj.message_type==11)) {
                if (obj.extra.state==0) {
                    obj.message = [NSString stringWithFormat:@"%@ 发起了%@通话",obj.extra.nickname , (obj.message_type==10?@"语音":@"视频")];
                }else {
                    obj.message = @"通话已结束";
                }
            }
            if (!obj.is_revoke) {
                if ([conversationMsgDict containsObjectForKey:obj.targetId]) {
                    NSMutableArray *sameTargets = [conversationMsgDict objectForKey:obj.targetId];
                    [sameTargets addObject:obj];
                    [conversationMsgDict setObject:sameTargets forKey:obj.targetId];
                }else {
                    NSMutableArray *sameTargets = [NSMutableArray array];
                    [sameTargets addObject:obj];
                    [conversationMsgDict setObject:sameTargets forKey:obj.targetId];
                }
                [obj bg_saveOrUpdate];
            }
        }];
        [self reportOfflineMsgStateWithIds:ids];
        [self saveOfflineDatas:conversationMsgDict messageModel:model];
    }
    
}

/// 保存在线消息，更新会话
- (void)saveOnlineMessage:(DCMessageContent *)message {
    NSString * where = [NSString stringWithFormat:@"where %@=%@ ",bg_sqlKey(@"targetId"),bg_sqlValue(message.targetId)];
    NSArray *historyArray = [DCConversationModel bg_find:kConversationListTableName where:where];
    DCConversationModel *conversation;
    
    if (historyArray.count > 0) {
        conversation = historyArray.firstObject;
    }else {
        conversation = [[DCConversationModel alloc]init];
    }
    conversation.lastMessage = message;
    conversation.targetId = message.targetId;
    conversation.conversationType = message.talk_type;
    conversation.lastMsgTime = message.timestamp;
    
    conversation.isMentionedMe = [message.warn_users containsString:kUser.uid] || [message.warn_users isEqualToString:@"0"];
    if (message.messageDirection==DC_MessageDirection_RECEIVE) {
        conversation.unReadMessageCount += 1;
        [DCMessageManager sharedManager].unReadMsgCount += 1;
    }
    if (self.isNeedHandleOfflineMsg) {
        [conversation bg_saveOrUpdate];
        [message bg_save];
    }else {
        [message bg_saveOrUpdateAsync:^(BOOL isSuccess) {
        }];
        
        if ([DCTools isEmpty:conversation.disturbState]) {
            [[DCUserManager sharedManager]requestConversationDistrubState:conversation.conversationType targerId:conversation.targetId completion:^(NSString * _Nonnull state) {
                if ([state isEqualToString:@"0"]) {
                    [self playMsgVioce:message];
                }
                conversation.disturbState = state;
                [conversation bg_saveOrUpdateAsync:^(BOOL isSuccess) {
                }];
                [[NSNotificationCenter defaultCenter] postNotificationName:kOnNewMessageWhenInConversationListPage object:conversation];
            }];
        }else {
            if ([conversation.disturbState isEqualToString:@"0"]) {
                [self playMsgVioce:message];
            }
            [conversation bg_saveOrUpdateAsync:^(BOOL isSuccess) {
            }];
            [[NSNotificationCenter defaultCenter] postNotificationName:kOnNewMessageWhenInConversationListPage object:conversation];
        }
        
    }
}

//
- (void)playMsgVioce:(DCMessageContent *)message {
    [[DCSystemSoundPlayer defaultPlayer] playSoundByMessage:message completeBlock:^(BOOL complete) {
        if (complete) {
//                        [self setExclusiveSoundPlayer];
        }
    }];
}

- (void)onRevokeWithMsgId:(NSString *)msgId {
    NSString * where = [NSString stringWithFormat:@"where %@=%@ ",bg_sqlKey(@"messageId"),bg_sqlValue(msgId)];
    [DCMessageContent bg_findAsync:kConversationMessageTableName where:where complete:^(NSArray * _Nullable array) {
        if (array.count > 0) {
            DCMessageContent *revokeMsg = array.firstObject;
            revokeMsg.message_type = 101;
            revokeMsg.cellSize = CGSizeZero;
            if (revokeMsg.messageDirection==DC_MessageDirection_SEND) {
                revokeMsg.message = @"你 撤回了一条消息";
                [self checkRecoveComplete:revokeMsg];
            }else {
                if (revokeMsg.conversationType == DC_ConversationType_GROUP) {
                    if (revokeMsg.senderUser) {
                        revokeMsg.message = [NSString stringWithFormat:@"%@ 撤回了一条消息",revokeMsg.senderUser.name];
                        [self checkRecoveComplete:revokeMsg];
                    }else {
                        [[DCUserManager sharedManager] getConversationData:DC_ConversationType_PRIVATE targerId:revokeMsg.from_uid completion:^(DCUserInfo * _Nonnull userInfo) {
                            revokeMsg.message = [NSString stringWithFormat:@"%@ 撤回了一条消息",userInfo.name];
                            [self checkRecoveComplete:revokeMsg];
                            
                        }];
                    }
                }else {
                    revokeMsg.message = @"对方 撤回了一条消息";
                    [self checkRecoveComplete:revokeMsg];
                }
            }
            
        }
    }];
}

- (void)checkRecoveComplete:(DCMessageContent *)revokeMsg {
    [revokeMsg bg_saveOrUpdateAsync:^(BOOL isSuccess) {
//        bg_closeDB();
    }];
    
    NSString * where = [NSString stringWithFormat:@"where %@=%@ ",bg_sqlKey(@"targetId"),bg_sqlValue(revokeMsg.targetId)];
    [DCConversationModel bg_findAsync:kConversationListTableName where:where complete:^(NSArray * _Nullable array) {
        if (array.count > 0) {
            DCConversationModel *conv = array.firstObject;
            if ([conv.lastMessage.messageId isEqualToString:revokeMsg.messageId]) {
                conv.lastMessage.message = revokeMsg.message;
                [[NSNotificationCenter defaultCenter] postNotificationName:kOnNewMessageWhenInConversationListPage object:conv];
                [conv bg_saveOrUpdateAsync:^(BOOL isSuccess) {
                    
                }];
            }
        }
    }];
}

/// 上报已收到的离线消息
- (void)reportOfflineMsgStateWithIds:(NSString *)ids {
    if (![DCTools isEmpty:ids]) {
        [self receiveHistoryMessage:ids];
    }
}

/// 更新或保存会话、消息
- (void)saveOfflineDatas:(NSMutableDictionary *)conversationMsgDict messageModel:(DCMessageModel *)model {
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t queue = dispatch_queue_create("dcfile.handleofflinemsg.queue", DISPATCH_QUEUE_CONCURRENT);
    for (NSString *targetId in conversationMsgDict.allKeys) {
        dispatch_group_async(group, queue, ^{
            @autoreleasepool {
                NSArray *array = conversationMsgDict[targetId];
                __block BOOL isMentionedMe = NO;
                [array enumerateObjectsUsingBlock:^(DCMessageContent *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    if ([obj.warn_users containsString:kUser.uid] || [obj.warn_users isEqualToString:@"0"]) {
                        isMentionedMe = YES;
                        *stop = YES;
                    }
                }];
                DCMessageContent *message = array.lastObject;
                
                NSString * where = [NSString stringWithFormat:@"where %@=%@ ",bg_sqlKey(@"targetId"),bg_sqlValue(targetId)];
                NSArray *historyArray = [DCConversationModel bg_find:kConversationListTableName where:where];
                
                if (historyArray.count > 0) {
                    DCConversationModel *conversation = historyArray.firstObject;
                    conversation.lastMessage = message;
                    conversation.targetId = targetId;
                    conversation.conversationType = message.talk_type;
                    conversation.lastMsgTime = message.timestamp;
                    conversation.unReadMessageCount += array.count;
                    conversation.isMentionedMe = isMentionedMe;
                    [conversation bg_saveOrUpdate];
                }else {
                    DCConversationModel *conversation = [[DCConversationModel alloc]init];
                    conversation.lastMessage = message;
                    conversation.targetId = targetId;
                    conversation.conversationType = message.talk_type;
                    conversation.lastMsgTime = message.timestamp;
                    conversation.unReadMessageCount = array.count;
                    conversation.isMentionedMe = isMentionedMe;
                    [conversation bg_save];
                }
//                bg_closeDB();
            }
        });
    }
    dispatch_group_notify(group, queue, ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:kReloadConversationDatasNotification object:conversationMsgDict];
        self.isNeedHandleOfflineMsg = NO;
        [DCSocketClient sharedInstance].kSocketStatus = KSocketDefaultStatus;
        
//        [DCMessageContent bg_saveOrUpdateArrayAsync:model.list complete:^(BOOL isSuccess) {
//            NSLog(@"历史消息插入成功");
//            bg_closeDB();
//        }];
    });
}


- (NSString *)getGroupNoticeText:(DCMessageContent *)msg {
    if (msg.talk_type==2 && msg.message_type==9) {
        NSString *operateUser = msg.extra.operate_user_name;
        if ([msg.extra.operate_user_id isEqualToString:kUser.uid]) {
            operateUser = @"你";
        }
        __block NSString *content = @"";
        [msg.extra.users enumerateObjectsUsingBlock:^(NSDictionary *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *name;
            if (idx==0) {
                name = [NSString stringWithFormat:@"%@",[[NSString stringWithFormat:@"%@",obj[@"id"]] isEqualToString:kUser.uid]?@"你":obj[@"nick_name"]];
            }else {
                name = [NSString stringWithFormat:@"、%@",[[NSString stringWithFormat:@"%@",obj[@"id"]] isEqualToString:kUser.uid]?@"你":obj[@"nick_name"]];
            }
            content = [content stringByAppendingFormat:@"%@",name];
        }];
        NSString *subText = @"";
        switch (msg.extra.type) {
            case 1:
                subText = [NSString stringWithFormat:@"%@ 邀请了 %@ 进入群聊",operateUser,content];
                break;
                
            case 2:
                subText = [NSString stringWithFormat:@"%@ 已退出群聊",operateUser];
                break;
                
            case 3:
                subText = [NSString stringWithFormat:@"%@ 已被 %@ 踢出群聊",content,operateUser];
                break;
                
            default:
                subText = [NSString stringWithFormat:@"%@ 已解散群聊",operateUser];
                break;
        }
        
        return subText;
    }
    return @"";
}


//MARK: - 更新消息为已读状态
- (void)changeMessageState:(DCMessageModel *)model {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kMessageReadAlsoNotification object:model.data.targetId userInfo:@{@"msgIds":model.message_ids}];
        
        NSString *msgIds = [model.message_ids componentsJoinedByString:@","];
        NSString *where = [NSString stringWithFormat:@"set %@=%@ where %@ in (%@)",bg_sqlKey(@"is_read"),bg_sqlValue(@YES),bg_sqlKey(@"messageId"),msgIds];
        
        BOOL issuccess = [DCMessageContent bg_update:kConversationMessageTableName where:where];
        if (issuccess) {
            DCLog(@"数据库更新已读成功");
        }
    });
}
@end
