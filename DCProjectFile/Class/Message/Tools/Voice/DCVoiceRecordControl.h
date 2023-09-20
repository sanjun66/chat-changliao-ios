
#import <Foundation/Foundation.h>


@protocol DCVoiceRecordControlDelegate;
@interface DCVoiceRecordControl : NSObject

@property (nonatomic, weak) id<DCVoiceRecordControlDelegate> delegate;

- (instancetype)initWithConversationType:(DCConversationType)conversationType;

- (void)onBeginRecordEvent;

- (void)onEndRecordEvent;

- (void)dragExitRecordEvent;

- (void)dragEnterRecordEvent;

- (void)onCancelRecordEvent;
@end

@protocol DCVoiceRecordControlDelegate <NSObject>

- (BOOL)recordWillBegin;
/*!
 开始录制语音消息
 */
- (void)voiceRecordControlDidBegin:(DCVoiceRecordControl *)voiceRecordControl;

/*!
 取消录制语音消息
 */
- (void)voiceRecordControlDidCancel:(DCVoiceRecordControl *)voiceRecordControl;

/*!
 结束录制语音消息
 */
- (void)voiceRecordControl:(DCVoiceRecordControl *)voiceRecordControl
                    didEnd:(NSData *)recordData
                  duration:(long)duration
                     error:(NSError *)error;
@end
