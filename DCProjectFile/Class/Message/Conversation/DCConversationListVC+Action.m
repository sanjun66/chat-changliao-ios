//
//  DCConversationListVC+Action.m
//  DCProjectFile
//
//  Created  on 2023/9/5.
//

#import "DCConversationListVC+Action.h"
#import "DCConversationListVC+Request.h"
#import "DCGroupCreateVC.h"
#import "DCFriendListModel.h"
#import "DCVoiceMessageCell.h"
#import "DCImageMessageCell.h"
#import "DCVideoMessageCell.h"

@implementation DCConversationListVC (Action)

///删除消息
- (void)deleteMessage:(DCMessageContent *)model {
    if (self.messageDatas.count == 0) {
        return;
    }
    [self stopVoiceMessageIfNeed:model];
    
    NSIndexPath *indexPath = [self findDataIndexFromMessageList:model];
    if (!indexPath) {
        return;
    } else{
        //如果要删除的消息是显示时间的，且下一条消息又没有显示时间，则删除消息之后，下一条消息需要显示时间
        DCMessageContent *msgModel = self.messageDatas[indexPath.row];
        if (msgModel.isDisplayMsgTime) {
            int nextIndex = (int)indexPath.row-1;
            if(nextIndex < self.messageDatas.count && nextIndex >= 0){
                DCMessageContent *nextModel = self.messageDatas[nextIndex];
                if (nextModel && !nextModel.isDisplayMsgTime) {
                    nextModel.isDisplayMsgTime = YES;
                    nextModel.cellSize = CGSizeZero;
                    [self.messageCollectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:nextIndex inSection:0]]];
                }
            }
        }
    }

    NSString * msgId = model.messageId;
    
    [[DCMessageManager sharedManager] deleteMessage:msgId];
    [self.messageDatas removeObjectAtIndex:indexPath.item];
    
//    if (indexPath.row == 0) {
        [[DCMessageManager sharedManager] checkConversationLastMsgWith:model saveMessage:(self.messageDatas.count > 0 ? self.messageDatas.firstObject : nil)];
//    }
    

    if (indexPath.row < [self.messageCollectionView numberOfItemsInSection:0]) {
        [self.messageCollectionView deleteItemsAtIndexPaths:[NSArray arrayWithObject:indexPath]];
    }
    
    if (model.msgSentStatus == DC_SentStatus_SENDING) {
        id dataTask = [[DCFileUploadManager sharedManager].dataTaskDictionary objectForKey:model.uuid];
        if ([dataTask isKindOfClass:[NSURLSessionDataTask class]]) {
            [((NSURLSessionDataTask *)dataTask) cancel];
        }
        if ([dataTask isKindOfClass:[AWSS3TransferUtilityUploadTask class]]) {
            [((AWSS3TransferUtilityUploadTask*)dataTask) cancel];
        }
    }
}

// 消息重发
- (void)resentMessage:(DCMessageContent *)model {
    NSIndexPath *idxPath = [self findDataIndexFromMessageList:model];
    model.msgSentStatus = DC_SentStatus_SENDING;
    [self.messageCollectionView reloadItemsAtIndexPaths:@[idxPath]];
    
    NSDictionary *dict = [DCTools dictionaryWithJsonString:[model modelToJSONString]];

    NSMutableDictionary *parms = [NSMutableDictionary dictionary];
    [parms setObject:dict[@"to_uid"] forKey:@"to_uid"];
    [parms setObject:dict[@"message"] forKey:@"message"];
    [parms setObject:dict[@"talk_type"] forKey:@"talk_type"];
    [parms setObject:dict[@"message_type"] forKey:@"message_type"];
    [parms setObject:dict[@"quote_id"] forKey:@"quote_id"];
    [parms setObject:dict[@"warn_users"] forKey:@"warn_users"];
    [parms setObject:dict[@"uuid"] forKey:@"uuid"];
    if (model.is_secret) {
        [parms setObject:dict[@"pwd"] forKey:@"pwd"];
        [parms setObject:@(1) forKey:@"is_secret"];
    }
    if (model.message_type==1) {
        [[DCSocketClient sharedInstance] sentMsgRequestWithParms:parms uuid:model.uuid messageContent:nil isResent:YES];
        return;
    }

    NSDictionary *tmp = nil;
    if (model.message_type==2) {
        tmp = [DCTools dictionaryWithJsonString:[model.extra modelToJSONString]];
    }

    if (tmp) {
        NSMutableDictionary *extra = [NSMutableDictionary dictionary];
        [extra setObject:tmp[@"suffix"] forKey:@"suffix"];
        [extra setObject:tmp[@"type"] forKey:@"type"];
        [extra setObject:tmp[@"size"] forKey:@"size"];
        [extra setObject:tmp[@"path"] forKey:@"path"];
        [extra setObject:tmp[@"height"] forKey:@"height"];
        [extra setObject:tmp[@"weight"] forKey:@"weight"];
        [extra setObject:tmp[@"duration"] forKey:@"duration"];
        if (tmp[@"cover"]) {
            [extra setObject:tmp[@"cover"] forKey:@"cover"];
        }
        if (![DCTools isEmpty:model.extra.url]) {
            [extra setObject:tmp[@"url"] forKey:@"url"];
            [extra setObject:tmp[@"driver"] forKey:@"driver"];
            [extra setObject:tmp[@"original_name"] forKey:@"original_name"];

            NSString *json = [DCTools jsonString:extra];
            [parms setObject:json forKey:@"extra"];
            [[DCSocketClient sharedInstance] sentMsgRequestWithParms:parms uuid:model.uuid messageContent:nil isResent:YES];
        }else {
            NSData *data = [DCFileManager getMessageFileData:model.extra.path];
            [[DCSocketClient sharedInstance] upLoadMsgData:data parms:parms extra:extra uuid:model.uuid messageContent:nil isResent:YES];
        }
    }
}

/// 发起音视频通话
- (void)makeCall:(QBRTCConferenceType)conferenceType {
    if (self.conversationType==DC_ConversationType_PRIVATE) {
        if (!self.toUserModel) {
            return;
        }
        [self requestPreCallCheck:conferenceType members:@[self.toUserModel] isMultit:NO toUids:self.targetId];
    }else {
        DCGroupCreateVC *vc = [[DCGroupCreateVC alloc]init];
        vc.members = self.groupData.group_member;
        vc.isCallInvited = YES;
        vc.createGroupBlock = ^(NSArray * _Nonnull selItems) {
            if (selItems.count <= 0) {return;}
            NSMutableArray *users = [NSMutableArray array];
            NSMutableArray *uidArr = [NSMutableArray array];
            [selItems enumerateObjectsUsingBlock:^(DCFriendItem *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                DCUserInfo *user = [[DCUserInfo alloc]init];
                user.name = obj.remark;
                user.userId = obj.friend_id;
                user.portraitUri = obj.avatar;
                user.quickbloxId = obj.quickblox_id;
                [users addObject:user];
                [uidArr addObject:obj.friend_id];
            }];
            
            NSString *uids = [uidArr componentsJoinedByString:@","];
            
            [self requestPreCallCheck:conferenceType members:users isMultit:YES toUids:uids];
            
        };
        [self presentViewController:vc animated:YES completion:nil];
    }
}

/// 停止语音的播放
- (void)stopPlayingVoiceMessage {
    if ([DCVoicePlayer defaultPlayer].isPlaying) {
        [[DCVoicePlayer defaultPlayer] stopPlayVoice];
    }
}

- (void)stopVoiceMessageIfNeed:(DCMessageContent *)model {
    NSIndexPath *indexPath = [self findDataIndexFromMessageList:model];
    if (!indexPath) {
        return;
    }
    //如果是语音消息则停止播放
    if (model.extra.type == 4) {
        DCVoiceMessageCell *cell =
            (DCVoiceMessageCell *)[self.messageCollectionView cellForItemAtIndexPath:indexPath];
        [cell stopPlayingVoice];
    }
}

// 预览图片视频
- (void)didTapVideoImageMessage:(DCMessageContent *)model {
    [[DCPreviewPhotoManager sharedManager] showPreview:self.messageDatas selectModel:model compele:^UIView * _Nonnull(DCMessageContent * _Nonnull curModel) {
        NSIndexPath *indexPath = [self findDataIndexFromMessageList:curModel];
        UIImageView *imageView;
        if (curModel.extra.type==1) {
            DCImageMessageCell *cell = (DCImageMessageCell *)[self.messageCollectionView cellForItemAtIndexPath:indexPath];
            if (![self.messageCollectionView.visibleCells containsObject:cell]) {
                imageView = nil;
            }else {
                imageView = cell.pictureView;
            }
        }else {
            DCVideoMessageCell *cell = (DCVideoMessageCell *)[self.messageCollectionView cellForItemAtIndexPath:indexPath];
            if (![self.messageCollectionView.visibleCells containsObject:cell]) {
                imageView = nil;
            }else {
                imageView = cell.pictureView;
            }
        }
        return imageView;
    }];
}

// 点击文件消息
- (void)didTapFileMsg:(DCMessageContent *)model {
    if (model.msgSentStatus == DC_SentStatus_SENDING) {return;}
    NSString *fileName = [DCFileManager fileName:model.extra.path];
    NSString *filePath = [[DCFileManager getMessageFileCachePath] stringByAppendingPathComponent:fileName];
    
    if ([DCFileManager isExistsAtPath:filePath]) {
        DCWebKitVC *wVc = [[DCWebKitVC alloc]init];
        // [[self.model.extra.path lastPathComponent] stringByDeletingPathExtension])
        wVc.titleStr = [model.extra.path lastPathComponent];
        wVc.localPath = filePath;
        [self.navigationController pushViewController:wVc animated:YES];
    }else {
        [MBProgressHUD showActivity];
        [[DCRequestManager sharedManager] downloadWithUrl:model.extra.url filePath:filePath success:^(id  _Nullable result) {
            [MBProgressHUD hideActivity];
            DCWebKitVC *wVc = [[DCWebKitVC alloc]init];
            wVc.titleStr = [model.extra.path lastPathComponent];
            wVc.localPath = filePath;
            [[DCTools navigationViewController] pushViewController:wVc animated:YES];
        }];
    }
}

// 点击语音消息
- (void)didTapVoiceMessage:(DCMessageContent *)model {
    if (model.msgSentStatus == DC_SentStatus_SENDING) {return;}
    NSIndexPath *indexPath = [self findDataIndexFromMessageList:model];
    DCVoiceMessageCell *cell = (DCVoiceMessageCell *)[self.messageCollectionView cellForItemAtIndexPath:indexPath];
    [cell playVoice];
}
@end
