//
//  DCConversationListVC+Action.h
//  DCProjectFile
//
//  Created  on 2023/9/5.
//

#import "DCConversationListVC.h"

NS_ASSUME_NONNULL_BEGIN

@interface DCConversationListVC (Action)
///删除消息
- (void)deleteMessage:(DCMessageContent *)model;
/// 消息重发
- (void)resentMessage:(DCMessageContent *)model;
/// 发起音视频通话
- (void)makeCall:(QBRTCConferenceType)conferenceType;
/// 停止语音播放器
- (void)stopPlayingVoiceMessage;
/// 停止语音播放
- (void)stopVoiceMessageIfNeed:(DCMessageContent *)model;
/// 预览图片和视频
- (void)didTapVideoImageMessage:(DCMessageContent *)model;
/// 点击文件消息
- (void)didTapFileMsg:(DCMessageContent *)model;
/// 点击语音消息
- (void)didTapVoiceMessage:(DCMessageContent *)model;

@end

NS_ASSUME_NONNULL_END
