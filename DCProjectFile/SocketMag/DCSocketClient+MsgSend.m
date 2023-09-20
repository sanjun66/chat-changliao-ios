//
//  DCSocketClient+MsgSend.m
//  DCProjectFile
//
//  Created  on 2023/6/19.
//

#import "DCSocketClient+MsgSend.h"
#define kTextMsgFlag @"文本消息"
@implementation DCSocketClient (MsgSend)

- (void)createTextMsg:(NSString *)toUid content:(NSString *)connect mentionedUserIds:(nullable NSString *)uids{
    NSString *uuid = [DCTools uniquelyIdentifies];
    if (self.conversationType==DC_ConversationType_GROUP) {
        toUid = [toUid componentsSeparatedByString:@"_"].lastObject;
    }
    NSMutableDictionary *parms = [NSMutableDictionary dictionary];
    [parms setObject:toUid forKey:@"to_uid"];
    [parms setObject:connect forKey:@"message"];
    [parms setObject:@(self.conversationType) forKey:@"talk_type"];
    [parms setObject:@"1" forKey:@"message_type"];
    [parms setObject:@(0) forKey:@"quote_id"];
    [parms setObject:uids?uids:@"" forKey:@"warn_users"];
    [parms setObject:uuid forKey:@"uuid"];
    [self createMessageModel:parms extra:nil fileData:nil uuid:uuid coverImage:nil];
}

- (void)createImageMsg:(NSString*)toUid image:(UIImage*)image {
    if (self.conversationType==DC_ConversationType_GROUP) {
        toUid = [toUid componentsSeparatedByString:@"_"].lastObject;
    }
    NSData *data = [UIImage lubanCompressImage:image];
    NSString *uuid = [DCTools uniquelyIdentifies];
    NSString *imageName = [NSString stringWithFormat:@"image_%@.png",uuid];
    NSString *filePath = [DCFileManager saveMessageFile:data fileName:imageName];
    
    NSMutableDictionary *parms = [NSMutableDictionary dictionary];
    [parms setObject:toUid forKey:@"to_uid"];
    [parms setObject:@"[图片]" forKey:@"message"];
    [parms setObject:@(self.conversationType) forKey:@"talk_type"];
    [parms setObject:@"2" forKey:@"message_type"];
    [parms setObject:@(0) forKey:@"quote_id"];
    [parms setObject:@"" forKey:@"warn_users"];
    [parms setObject:uuid forKey:@"uuid"];
    
    
    NSMutableDictionary *extra = [NSMutableDictionary dictionary];
    [extra setObject:@"png" forKey:@"suffix"];
    [extra setObject:@(1) forKey:@"type"];
    [extra setObject:@(0) forKey:@"size"];
    [extra setObject:@(0) forKey:@"duration"];
    [extra setObject:@(image.size.width) forKey:@"weight"];
    [extra setObject:@(image.size.height) forKey:@"height"];
    [extra setObject:filePath forKey:@"path"];
    
    [self createMessageModel:parms extra:extra fileData:data uuid:uuid coverImage:nil];
}
- (void)createVoiceMsg:(NSString *)toUid voiceData:(NSData *)data duration:(long)duration {
    if (self.conversationType==DC_ConversationType_GROUP) {
        toUid = [toUid componentsSeparatedByString:@"_"].lastObject;
    }
    NSString *uuid = [DCTools uniquelyIdentifies];
    NSString *fileName = [NSString stringWithFormat:@"voice_%@.m4a",uuid];
    NSString *filePath = [DCFileManager saveMessageFile:data fileName:fileName];
    
    NSMutableDictionary *parms = [NSMutableDictionary dictionary];
    [parms setObject:toUid forKey:@"to_uid"];
    [parms setObject:@"[语音]" forKey:@"message"];
    [parms setObject:@(self.conversationType) forKey:@"talk_type"];
    [parms setObject:@"2" forKey:@"message_type"];
    [parms setObject:@(0) forKey:@"quote_id"];
    [parms setObject:@"" forKey:@"warn_users"];
    [parms setObject:uuid forKey:@"uuid"];
    
    NSMutableDictionary *extra = [NSMutableDictionary dictionary];
    [extra setObject:@"wav" forKey:@"suffix"];
    [extra setObject:@(4) forKey:@"type"];
    [extra setObject:@(0) forKey:@"size"];
    [extra setObject:@(duration) forKey:@"duration"];
    [extra setObject:@(0) forKey:@"weight"];
    [extra setObject:@(0) forKey:@"height"];
    [extra setObject:filePath forKey:@"path"];
    
    [self createMessageModel:parms extra:extra fileData:data uuid:uuid coverImage:nil];
    
}

- (void)createVideoMsg:(NSString *)toUid localPath:(NSString *)path videoSize:(CGSize)size duration:(int)duration thumbPhoto:(UIImage *)thumbPhoto {
    NSString *uuid = [DCTools uniquelyIdentifies];
    if (self.conversationType==DC_ConversationType_GROUP) {
        toUid = [toUid componentsSeparatedByString:@"_"].lastObject;
    }
    NSMutableDictionary *parms = [NSMutableDictionary dictionary];
    [parms setObject:toUid forKey:@"to_uid"];
    [parms setObject:@"[视频]" forKey:@"message"];
    [parms setObject:@(self.conversationType) forKey:@"talk_type"];
    [parms setObject:@"2" forKey:@"message_type"];
    [parms setObject:@(0) forKey:@"quote_id"];
    [parms setObject:@"" forKey:@"warn_users"];
    [parms setObject:uuid forKey:@"uuid"];
    
    NSData *data = [NSData dataWithContentsOfFile:path];
    
    NSMutableDictionary *extra = [NSMutableDictionary dictionary];
    [extra setObject:@"mp4" forKey:@"suffix"];
    [extra setObject:@(2) forKey:@"type"];
    [extra setObject:@(0) forKey:@"size"];
    [extra setObject:@(duration) forKey:@"duration"];
    [extra setObject:@(size.width) forKey:@"weight"];
    [extra setObject:@(size.height) forKey:@"height"];
    [extra setObject:path forKey:@"path"];
    [self createMessageModel:parms extra:extra fileData:data uuid:uuid coverImage:thumbPhoto];
    
    
}


- (void)createFileMsg:(NSString *)toUid localPath:(NSString *)path size:(CGFloat)size {
    NSString *uuid = [DCTools uniquelyIdentifies];
    if (self.conversationType==DC_ConversationType_GROUP) {
        toUid = [toUid componentsSeparatedByString:@"_"].lastObject;
    }
    NSMutableDictionary *parms = [NSMutableDictionary dictionary];
    [parms setObject:toUid forKey:@"to_uid"];
    [parms setObject:@"[文件]" forKey:@"message"];
    [parms setObject:@(self.conversationType) forKey:@"talk_type"];
    [parms setObject:@"2" forKey:@"message_type"];
    [parms setObject:@(0) forKey:@"quote_id"];
    [parms setObject:@"" forKey:@"warn_users"];
    [parms setObject:uuid forKey:@"uuid"];
    
    NSData *data = [NSData dataWithContentsOfFile:path];
    NSString *ext = [path pathExtension];
    
    
    NSMutableDictionary *extra = [NSMutableDictionary dictionary];
    [extra setObject:ext forKey:@"suffix"];
    [extra setObject:@(3) forKey:@"type"];
    [extra setObject:@(size) forKey:@"size"];
    [extra setObject:@(0) forKey:@"duration"];
    [extra setObject:@(0) forKey:@"weight"];
    [extra setObject:@(0) forKey:@"height"];
    [extra setObject:path forKey:@"path"];
    [self createMessageModel:parms extra:extra fileData:data uuid:uuid coverImage:nil];
    
}


- (void)createMessageModel:(NSMutableDictionary *)parms extra:(NSMutableDictionary *)extra fileData:(NSData *)data uuid:(NSString *)uuid coverImage:(nullable UIImage *)coverImage {
    if (self.secretPsw) {
        [parms setObject:self.secretPsw forKey:@"pwd"];
        [parms setObject:@(1) forKey:@"is_secret"];
    }
    DCMessageExtra *extraModel = [DCMessageExtra modelWithDictionary:extra];
    DCMessageContent *msg = [DCMessageContent modelWithDictionary:parms];
    long sentTime = [[DCTools getCurrentTimestamp] longValue];
    
    msg.msgSentStatus = DC_SentStatus_SENDING;
    msg.from_uid = [[DCUserManager sharedManager] userModel].uid;
    msg.created_at = sentTime/1000;
    msg.timestamp = sentTime;
    msg.senderUser = [DCUserManager sharedManager].currentUserInfo;
    msg.messageDirection = DC_MessageDirection_SEND;
    msg.extra = extraModel;
    msg.messageId = uuid;
    
    [self insertSendingMessage:msg];
    
    if ([DCReachabilityManager sharedManager].isNetworkOK) {
        if (coverImage) {
            [self uploadVideoCover:coverImage complete:^(NSString *cover) {
                [extra setObject:cover forKey:@"cover"];
                [self upLoadMsgData:data parms:parms extra:extra uuid:uuid messageContent:msg isResent:NO];
            }];
        }else {
            [self upLoadMsgData:data parms:parms extra:extra uuid:uuid messageContent:msg isResent:NO];
        }
        
    }else {
        [self saveLocalFainMsg:msg uuid:uuid];
    }
    
    
//    [self sentMsgRequest:ext parms:parms fileData:data uuid:uuid messageContent:msg];
}

-(void)upLoadMsgData:(NSData *)data
               parms:(NSMutableDictionary *)parms
               extra:(NSMutableDictionary *)extra
                uuid:(NSString *)uuid
      messageContent:(DCMessageContent *)localMsg
            isResent:(BOOL)resent
{
    if (!data) {
        [self sentMsgRequestWithParms:parms uuid:uuid messageContent:localMsg isResent:resent];
    }else {
        NSString *suffix = [extra objectForKey:@"suffix"];
        NSString *namePre = [DCTools uploadFileNamePre];
        NSString *fileName = [NSString stringWithFormat:@"%@.%@",namePre,suffix];
        
        [[DCFileUploadManager sharedManager] upload:data name:fileName uniquelyIdentifies:uuid success:^(NSString * _Nonnull result) {
            [extra setObject:result forKey:@"url"];
            [extra setObject:[DCUserManager sharedManager].ossModel.oss_status forKey:@"driver"];
            [extra setObject:[fileName componentsSeparatedByString:@"/"].lastObject forKey:@"original_name"];
            localMsg.extra = [DCMessageExtra modelWithDictionary:extra];
            
            NSString *json = [DCTools jsonString:extra];
            [parms setObject:json forKey:@"extra"];
            [self sentMsgRequestWithParms:parms uuid:uuid messageContent:localMsg isResent:resent];
            
        } failure:^(id  _Nonnull error) {
            if ([error isKindOfClass:[NSError class]]) {
                NSError *aError = (NSError *)error;
                if ([aError.localizedDescription isEqualToString:@"已取消"]) {
                    return;
                }
            }
            [self saveLocalFainMsg:localMsg uuid:uuid];
        }];
    }
    
}

- (void)uploadVideoCover:(UIImage *)image complete:(void(^)(NSString *cover))complete {
    NSData *data = [UIImage lubanCompressImage:[UIImage imageCompressForWidth:image targetWidth:200]];
    NSString *namePre = [DCTools uploadFileNamePre];
    NSString *fileName = [NSString stringWithFormat:@"%@.png",namePre];
    [[DCFileUploadManager sharedManager] upload:data name:fileName uniquelyIdentifies:nil success:^(NSString * _Nonnull result) {
        complete(result);
    } failure:^(id  _Nonnull nullable) {
        complete(@"");
    }];
    
}

- (void)sentMsgRequestWithParms:(NSDictionary *)parms uuid:(NSString *)uuid messageContent:(DCMessageContent *)localMsg isResent:(BOOL)resent{
    NSString *url = @"api/msgSend";
    
    NSString *requestUrl = [NSString stringWithFormat:@"%@%@",kUrlPre,url];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    NSMutableDictionary *headers = [NSMutableDictionary dictionary];
    [headers setObject:[NSString stringWithFormat:@"Bearer %@",[[DCUserManager sharedManager] userModel].token] forKey:@"Authorization"];
    if (SECRET) {
        [headers setObject:@"0" forKey:@"app-encrypt"];
    }
    NSDictionary *finalParms = parms;
    if (SECRET) {
        NSString *jsonParms = [DCTools jsonString:parms];
        NSString *aesParms = [DCTools AESEncrypt:jsonParms];
        finalParms = @{@"params_body":aesParms};
    }
    NSURLSessionDataTask *dataTask = [manager POST:requestUrl parameters:finalParms headers:headers constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            NSDictionary *result = (NSDictionary *)responseObject;
            DCMessageModel *model = [DCMessageModel modelWithDictionary:result];
            
            if (model.code != 200) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [MBProgressHUD showTips:[NSString stringWithFormat:@"%@",[result valueForKey:@"message"]]];
                });
                [self saveLocalFainMsg:localMsg uuid:uuid];
            }else {
                DCMessageContent *message;
                if (SECRET) {
                    NSString *data = result[@"data"];
                    NSString *jsonString = [DCTools AESDecrypt:data];
                    message = [DCMessageContent modelWithJSON:jsonString];
                }else {
                    message = model.data;
                }
                message.msgSentStatus = DC_SentStatus_SENT;
                
                if (!resent) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:kReloadSendMessageNotification object:message];
                }else {
                    [[NSNotificationCenter defaultCenter] postNotificationName:kResentMessageSuccessNotification object:message];
                    [[DCMessageManager sharedManager] deleteMessage:uuid];
                }
                [self saveMessageAndConversation:message];
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if ([error.localizedDescription isEqualToString:@"已取消"]) {
            
        }else {
            [self saveLocalFainMsg:localMsg uuid:uuid];
        }
        
    }];
    [dataTask resume];
}

- (void)saveLocalFainMsg:(DCMessageContent *)localMsg uuid:(NSString *)uuid{
    [[NSNotificationCenter defaultCenter] postNotificationName:kMessageSentFailNotificaiton object:uuid];
    if (!localMsg) {return;}
    localMsg.msgSentStatus = DC_SentStatus_FAILED;
    [self saveMessageAndConversation:localMsg];
}
/// 保存自己发送的信息
- (void)saveMessageAndConversation:(DCMessageContent *)message {
    [message bg_saveAsync:^(BOOL isSuccess) {
//        bg_closeDB();
    }];
    
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
    [conversation bg_saveOrUpdateAsync:^(BOOL isSuccess) {
//        bg_closeDB();
    }];
    [[NSNotificationCenter defaultCenter] postNotificationName:kOnNewMessageWhenInConversationListPage object:conversation];
}

/**
KVO回调方法
*/
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    //获取观察的新值
    CGFloat value = [change[NSKeyValueChangeNewKey] doubleValue];
    //打印
    DCLog(@"fractionCompleted --- %f", value);
}


- (void)insertSendingMessage:(DCMessageContent *)message {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:kOnNewMessageNotification object:message];
    });
    
}

- (void)sendHeartBeat {
    NSMutableDictionary *msg = [NSMutableDictionary dictionary];
    [msg setObject:@"heartbeat" forKey:@"event_name"];
    NSString *json = [DCTools jsonString:msg];
    NSError *error = nil;
    [self.webSocket sendString:json error:&error];
}


- (void)receiveHistoryMessage:(NSString * _Nullable )ids {
    NSMutableDictionary *msg = [NSMutableDictionary dictionary];
    [msg setObject:@"talk_pull" forKey:@"event_name"];
    if (ids) {
        [msg setObject:ids forKey:@"ids"];
    }else {
        self.isNeedHandleOfflineMsg = YES;
        [DCSocketClient sharedInstance].kSocketStatus = KSocketReceivingStatus;
        [self.webSocket sendString:[DCTools jsonString:@{@"event_name":@"talk_read"}] error:nil];
    }
    NSString *json = [DCTools jsonString:msg];
    NSError *error = nil;
    [self.webSocket sendString:json error:&error];
}

- (void)sentMsgReceipt:(NSString *)msgId {
    NSMutableDictionary *msg = [NSMutableDictionary dictionary];
    [msg setObject:@"msgReceipt" forKey:@"event_name"];
    [msg setObject:msgId forKey:@"msg_id"];
    NSString *json = [DCTools jsonString:msg];
    NSError *error = nil;
    [self.webSocket sendString:json error:&error];
    
}

//MARK: - 消息撤回
- (void)revokeMessage:(DCMessageContent *)message {
    [[DCRequestManager sharedManager] requestWithMethod:@"POST" url:@"api/msgRevoke" parameters:@{@"id":message.messageId,@"uuid":[DCTools uniquelyIdentifies]} success:^(id  _Nullable result) {
        if ([result isKindOfClass:[NSDictionary class]]) {
            NSString *msgId = [NSString stringWithFormat:@"%@",result[@"id"]];
            [[DCSocketClient sharedInstance] onRevokeWithMsgId:msgId];
            [[NSNotificationCenter defaultCenter] postNotificationName:kDidRevokeMessageNotification object:msgId];
        }
        
    } failure:^(NSError * _Nonnull error) {
        
    }];
}

@end
