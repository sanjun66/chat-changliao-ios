//
//  DCConversationListVC+Notification.m
//  DCProjectFile
//
//  Created  on 2023/9/5.
//

#import "DCConversationListVC+Notification.h"
#import "DCConversationListVC+Request.h"
#import "DCConversationListVC+Action.h"

@implementation DCConversationListVC (Notification)
//MARK: - 通知
- (void)addNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onNewMessage:)
                                                 name:kOnNewMessageNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(resetConversationDatas:)
                                                 name:kReloadConversationDatasNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(insertGoingOutMessage:)
                                                 name:kInsertSendingMessageNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(resetGoingOutMessage:)
                                                 name:kReloadSendMessageNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onMessageSentFail:)
                                                 name:kMessageSentFailNotificaiton
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appWillResignActive:)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appDidBecomeActive:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onRevokeNotification:)
                                                 name:kDidRevokeMessageNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onResentMsgSuccessNotification:)
                                                 name:kResentMessageSuccessNotification
                                               object:nil];
 
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onMessageReadedNotification:)
                                                 name:kMessageReadAlsoNotification
                                               object:nil];
    
    if (self.conversationType==DC_ConversationType_PRIVATE) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(userOnlineStateDidChanged:)
                                                     name:kUserOnlineStateDidChangeNotification
                                                   object:nil];
    }
}
- (void)onNewMessage:(NSNotification *)aNotification {
    DCMessageContent *message = aNotification.object;
    if ([message.targetId isEqualToString:self.targetId]) {
        if (message.messageDirection==DC_MessageDirection_RECEIVE) {
            [self requestReportMessageRead:message.messageId];
        }else {
            self.sendMsgAndNeedScrollToBottom = YES;
        }
        __weak typeof(self) ws = self;
        [self.appendMessageQueue addOperationWithBlock:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                @autoreleasepool {
                    if ([ws appendMessageModel:message]) {
                        [self.cachedReloadMessages addObject:message];
                        ws.throttleReloadAction();
                    }
                }
            });
            [NSThread sleepForTimeInterval:0.01];
        }];
        
    }
}

- (BOOL)appendMessageModel:(DCMessageContent *)model {
    NSString * newId = model.messageId;

    NSMutableArray *array = [NSMutableArray arrayWithArray:self.messageDatas];
    if (self.cachedReloadMessages.count) {
        [array addObjectsFromArray:self.cachedReloadMessages];
    }
    for (DCMessageContent *__item in array) {

        if ([newId isEqualToString: __item.messageId]) {
            return NO;
        }
    }
    
    if (self.messageDatas.count == 0) {
        model.isDisplayMsgTime = YES;
    }else {
        DCMessageContent *nextMsg = self.messageDatas[0];
        model.isDisplayMsgTime = model.timestamp - nextMsg.timestamp >= 180 * 1000;
    }
    
    return YES;
}

- (void)resetConversationDatas:(NSNotification *)aNotification {
    NSDictionary *conversationMsgDict = aNotification.object;
    if ([conversationMsgDict.allKeys containsObject:self.targetId]) {
        [self getConversationMessages:0 pageSize:20 isAppend:NO targetIdx:nil];
    }
    [self getMentionedMeLocation];
}

- (void)insertGoingOutMessage:(NSNotification *)aNotification {
    
}

- (void)resetGoingOutMessage:(NSNotification *)aNotification {
    DCMessageContent *message = aNotification.object;
    __block BOOL contains = NO;
    [self.messageDatas enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(DCMessageContent *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.uuid isEqualToString:message.uuid]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                message.isDisplayMsgTime = obj.isDisplayMsgTime;
                message.cellSize = CGSizeZero;
                [self.messageDatas replaceObjectAtIndex:idx withObject:message];
                [self.messageCollectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:idx inSection:0]]];
            });
            contains = YES;
            *stop = YES;
        }
    }];
//
//    if (!contains) {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [self.messageDatas insertObject:message atIndex:0];
//            [self.messageCollectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:0 inSection:0]]];
//            [self scrollToBottomAnimated:YES];
//        });
//    }
}

- (void)onMessageSentFail:(NSNotification *)aNotification {
    NSString *uuid = aNotification.object;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.messageDatas enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(DCMessageContent *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.uuid isEqualToString:uuid]) {
                obj.msgSentStatus = DC_SentStatus_FAILED;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.messageCollectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:idx inSection:0]]];
                });
                *stop = YES;
            }
        }];
    });
}


- (void)appWillResignActive:(id)sender {
    [[DCMessageManager sharedManager] cleanConversationUnReadMessages:self.targetId];
    [self stopPlayingVoiceMessage];
    // 将数据库中收到的消息设置为已读
    [[DCMessageManager sharedManager] setReceiveMessageRead:self.targetId];
}

- (void)appDidBecomeActive:(id)sender {
    [self requestUserOnlineState];
}

- (void)onRevokeNotification:(NSNotification *)aNotification {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *msgId = aNotification.object;
        
        __block DCMessageContent *revokeMsg;
        if ([msgId isEqualToString:self.currentRevokeModel.messageId]) {
            revokeMsg = self.currentRevokeModel;
        }else {
            [self.messageDatas enumerateObjectsUsingBlock:^(DCMessageContent *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj.messageId isEqualToString:msgId]) {
                    revokeMsg = obj;
                    *stop = YES;
                }
            }];
        }
        
        if (!revokeMsg) return;
        [self stopVoiceMessageIfNeed:revokeMsg];
        NSIndexPath *idxPath = [self findDataIndexFromMessageList:revokeMsg];
        
        revokeMsg.message_type = 101;
        revokeMsg.cellSize = CGSizeZero;
        NSString *preText = @"";
        if (revokeMsg.messageDirection==DC_MessageDirection_SEND) {
            preText = @"你";
        }else {
            if (revokeMsg.conversationType == DC_ConversationType_GROUP) {
                preText = revokeMsg.senderUser.name;
            }else {
                preText = @"对方";
            }
        }
        revokeMsg.message = [NSString stringWithFormat:@"%@ 撤回了一条消息",preText];
        
        if (idxPath) {
            [self.messageCollectionView reloadData];
        }else {
            [self.messageCollectionView reloadItemsAtIndexPaths:@[idxPath]];
        }
    });
    
}

- (void)onResentMsgSuccessNotification:(NSNotification *)aNotification {
    DCMessageContent *message = aNotification.object;
    [self.messageDatas enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(DCMessageContent *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.uuid isEqualToString:message.uuid]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSIndexPath *idxPath = [NSIndexPath indexPathForRow:idx inSection:0];
                NSIndexPath *targetIdxPath = [NSIndexPath indexPathForRow:0 inSection:0];
                [self.messageCollectionView moveItemAtIndexPath:idxPath toIndexPath:targetIdxPath];
                [self.messageDatas removeObject:obj];
                [self.messageDatas insertObject:message atIndex:0];
                [self.messageCollectionView reloadItemsAtIndexPaths:@[targetIdxPath]];
                [self scrollToBottomAnimated:NO];
            });
            *stop = YES;
        }
    }];
    
    
}

- (void)onMessageReadedNotification:(NSNotification *)aNotification {
    NSString *targetId = aNotification.object;
    if (![targetId isEqualToString:self.targetId]) {return;}
    
    NSArray *msgIds = [aNotification.userInfo objectForKey:@"msgIds"];
    NSString *idString = [msgIds componentsJoinedByString:@","];
    NSMutableArray *idxPaths = [NSMutableArray array];
    [self.messageDatas enumerateObjectsUsingBlock:^(DCMessageContent *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([idString containsString:obj.messageId]) {
            obj.is_read = YES;
            NSIndexPath *idxPath = [NSIndexPath indexPathForRow:idx inSection:0];
            [idxPaths addObject:idxPath];
        }
    }];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.messageCollectionView reloadItemsAtIndexPaths:idxPaths.copy];
    });
}

- (void)userOnlineStateDidChanged:(NSNotification *)aNotification {
    DCMessageContent *msg = aNotification.object;
    if ([msg.from_uid isEqualToString:self.targetId]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.onlineView.positionItem.selected = msg.extra.type==1;
        });
    }
}

@end
