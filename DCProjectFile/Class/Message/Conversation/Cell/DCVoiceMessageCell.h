//
//  DCVoiceMessageCell.h
//  DCProjectFile
//
//  Created  on 2023/6/27.
//

#import "DCMessageCell.h"

/*!
 开始语音播放的Notification
 */
UIKIT_EXTERN NSString * _Nullable const kNotificationPlayVoice;

/*!
 语音消息播放停止的Notification
 */
UIKIT_EXTERN NSString * _Nullable const kNotificationStopVoicePlayer;


NS_ASSUME_NONNULL_BEGIN

@interface DCVoiceMessageCell : DCMessageCell
@property (nonatomic, strong) UIImageView *playVoiceView;
@property (nonatomic, strong, nullable) UIImageView *voiceUnreadTagView;
@property (nonatomic, strong) UILabel *voiceDurationLabel;

/*!
 播放语音
 */
- (void)playVoice;

/*!
 停止播放语音
 */
- (void)stopPlayingVoice;

@end

NS_ASSUME_NONNULL_END
