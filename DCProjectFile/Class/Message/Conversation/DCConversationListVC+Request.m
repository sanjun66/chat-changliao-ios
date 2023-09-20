//
//  DCConversationListVC+Request.m
//  DCProjectFile
//
//  Created  on 2023/9/5.
//

#import "DCConversationListVC+Request.h"

@implementation DCConversationListVC (Request)

//MARK: - 获取会话数据
- (void)requesetConversationInfo {
    self.navigationItem.title = self.conversationTitle;
    [[DCUserManager sharedManager] requesetConversationData:self.conversationType targerId:self.targetId completion:^(DCUserInfo * _Nonnull userInfo, DCGroupDataModel * _Nonnull groupData) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (groupData) {
                if (groupData.code != 422) {
                    NSString *titleName = [NSString stringWithFormat:@"%@(%ld)",userInfo.name,self.groupData.group_member.count];
                    if (![self.navigationItem.title isEqualToString:titleName]) {
                        self.navigationItem.title = titleName;
                    }
                    
                }
            }else {
                if (![self.navigationItem.title isEqualToString:userInfo.name]) {
                    self.navigationItem.title = userInfo.name;
                }
            }
        });
        self.groupData = groupData;
        self.toUserModel = userInfo;
        if (self.targetConversationInfoBlock) {
            self.targetConversationInfoBlock(userInfo);
        }
        if (groupData.code != 422) {
            self.inputBarControl.groupModel = groupData;
        }
    }];
}


/// 消息解密
- (void)requestSecretMessageDecrypt:(DCMessageContent *)msg pwd:(NSString *)pwd {
    [[DCRequestManager sharedManager] requestWithMethod:@"POST" url:@"api/msgDecrypt" parameters:@{@"id":msg.messageId , @"pwd":pwd} success:^(id  _Nullable result) {
        NSIndexPath *idxPath = [self findDataIndexFromMessageList:msg];
        DCMessageContent *content = [DCMessageContent modelWithDictionary:result];
        
        content.is_secret = NO;
        content.cellSize = CGSizeZero;
        [self.messageDatas replaceObjectAtIndex:idxPath.row withObject:content];
        [self.messageCollectionView reloadItemsAtIndexPaths:@[idxPath]];
        
        content.is_secret = YES;
        [content bg_saveOrUpdateAsync:^(BOOL isSuccess) {
        }];
        
    } failure:^(NSError * _Nonnull error) {
        
    }];
}

/// 发起音视频通话
- (void)requestPreCallCheck:(QBRTCConferenceType)conferenceType members:(NSArray*)members isMultit:(BOOL)isMultit toUids:(NSString *)touids {
    NSMutableDictionary *parms = @{}.mutableCopy;
    [parms setObject:self.conversationType==DC_ConversationType_GROUP?@(2):@(1) forKey:@"talk_type"];
    [parms setObject:touids forKey:@"id"];
    [parms setObject:self.conversationType==DC_ConversationType_GROUP?[self.targetId componentsSeparatedByString:@"_"].lastObject:@"" forKey:@"group_id"];
    [parms setObject:conferenceType==QBRTCConferenceTypeVideo?@(11):@(10) forKey:@"message_type"];
    
    [[DCRequestManager sharedManager] requestWithMethod:@"POST" url:@"api/checkParams" parameters:parms success:^(id  _Nullable result) {
        [DCCallManager sharedInstance].callUid = [NSString stringWithFormat:@"%@",result[@"id"]];
        [[DCCallManager sharedInstance] makeCall:conferenceType toUsers:members isGroup:isMultit];
    } failure:^(NSError * _Nonnull error) {
        
    }];
}

/// 上报消息已读
- (void)requestReportMessageRead:(NSString *)msgId {
    [[DCRequestManager sharedManager] requestWithMethod:@"POST" url:@"api/setMessageRead" parameters:@{@"message_id":msgId , @"talk_type":@(self.conversationType),@"member_id":kUser.uid} success:^(id  _Nullable result) {
            
    } failure:^(NSError * _Nonnull error) {
        
    }];
}

/// 获取云消息记录
- (void)requestCloudMessageList:(DCMessageContent*)model {
    NSString *convId = self.targetId;
    if ([DCTools isGroupId:convId]) {
        convId = [self.targetId componentsSeparatedByString:@"_"].lastObject;
    }
    NSString *lastMsgId = @"0";
    if (model) {
        lastMsgId = model.messageId;
    }
    NSDictionary *parms = @{@"id":convId , @"talk_type":[NSString stringWithFormat:@"%@",@(self.conversationType)] , @"messageId":lastMsgId};
    [[DCRequestManager sharedManager] requestWithMethod:@"POST" url:@"api/getChatMessage" parameters:parms success:^(id  _Nullable result) {
        if ([result isKindOfClass:[NSArray class]]) {
            NSArray *msgs = (NSArray *)result;
            [self.messageCollectionView.mj_footer endRefreshing];
            if (msgs.count > 0) {
                NSMutableArray *array = [NSMutableArray array];
                
                [msgs enumerateObjectsUsingBlock:^(NSDictionary *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    DCMessageContent *msg = [DCMessageContent modelWithDictionary:obj];
                    [array addObject:msg];
                }];
                
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
                [DCMessageContent bg_saveOrUpdateArrayAsync:array complete:^(BOOL isSuccess) {
                }];                
                [self.messageDatas addObjectsFromArray:array];
                [self.messageCollectionView reloadData];
            }
            
            if ([lastMsgId intValue]==0) {
                DCMessageContent *model = self.messageDatas.firstObject;
                NSString * where = [NSString stringWithFormat:@"where %@=%@ ",bg_sqlKey(@"targetId"),bg_sqlValue(model.targetId)];
                [DCConversationModel bg_findAsync:kConversationListTableName where:where complete:^(NSArray * _Nullable array) {
                    if (array.count==0) {
                        DCConversationModel *conversation = [[DCConversationModel alloc]init];
                        conversation.lastMessage = model;
                        conversation.targetId = model.targetId;
                        conversation.conversationType = model.talk_type;
                        conversation.lastMsgTime = model.timestamp;
                        conversation.unReadMessageCount = 0;
                        [conversation bg_saveAsync:^(BOOL isSuccess) {
                            [[NSNotificationCenter defaultCenter] postNotificationName:kReloadConversationDatasNotification object:nil];
                        }];
                    }
                }];
            }
        }
    } failure:^(NSError * _Nonnull error) {
        
    }];
}

/// 消息删除接口
- (void)requestForMessageDelete:(NSString *)msgId {
    [[DCRequestManager sharedManager] requestWithMethod:@"POST" url:@"api/delMsg" parameters:@{@"id":msgId} success:^(id  _Nullable result) {
            
    } failure:^(NSError * _Nonnull error) {
        
    }];
}

/// 获取用户在线状态
- (void)requestUserOnlineState {
    [[DCRequestManager sharedManager] requestWithMethod:@"POST" url:@"api/getUserOnline" parameters:@{@"id":self.targetId} success:^(id  _Nullable result) {
        self.onlineView.positionItem.selected = [result[@"online"] boolValue];
    } failure:^(NSError * _Nonnull error) {
        
    }];
}
@end
