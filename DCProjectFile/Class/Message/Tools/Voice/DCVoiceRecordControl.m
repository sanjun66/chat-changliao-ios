
#import "DCVoiceRecordControl.h"

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreTelephony/CTCallCenter.h>

#import "DCVoiceCaptureControl.h"


@interface DCVoiceRecordControl () <DCVoiceCaptureControlDelegate>
@property (nonatomic, assign) DCConversationType conversationType;
@property (nonatomic, strong) DCVoiceCaptureControl *voiceCaptureControl;
@property (nonatomic, assign) BOOL isAudioRecoderTimeOut;
@end

@implementation DCVoiceRecordControl
- (instancetype)initWithConversationType:(DCConversationType)conversationType {
    self = [super init];
    if (self) {
        self.conversationType = conversationType;
        self.isAudioRecoderTimeOut = NO;
        [self registerNotification];
    }
    return self;
}

//语音消息开始录音
- (void)onBeginRecordEvent {
    CTCallCenter *center = [[CTCallCenter alloc] init];
    if (center.currentCalls.count > 0) {
        NSString *alertMessage = @"声音通道正被占用，请稍后再试";
        [MBProgressHUD showTips:alertMessage];
        return;
    }
    if (self.voiceCaptureControl) {
        return;
    }
    
    if ([self.delegate respondsToSelector:@selector(recordWillBegin)]) {
        if (![self.delegate recordWillBegin]) {
            return;
        }
    }

    if ([DCCallManager sharedInstance].isCallBusy) {
        NSString *alertMessage = @"声音通道正被占用，请稍后再试";
        [MBProgressHUD showTips:alertMessage];
        return;
    }

    [self checkRecordPermission:^{
        self.voiceCaptureControl =
            [[DCVoiceCaptureControl alloc] initWithFrame:CGRectMake(0, 20, [UIScreen mainScreen].bounds.size.width,
                                                                    [UIScreen mainScreen].bounds.size.height)
                                        conversationType:self.conversationType];
        self.voiceCaptureControl.delegate = self;
        if ([DCVoicePlayer defaultPlayer].isPlaying) {
            [[DCVoicePlayer defaultPlayer] resetPlayer];
        }
        [self.voiceCaptureControl startRecord];
        if ([self.delegate respondsToSelector:@selector(voiceRecordControlDidBegin:)]) {
            [self.delegate voiceRecordControlDidBegin:self];
        }
    }];
}

//语音消息录音结束
- (void)onEndRecordEvent {
    if (!self.voiceCaptureControl) {
        return;
    }

    NSData *recordData = [self.voiceCaptureControl stopRecord];
    if (recordData.length == 0) {
        // 录制失败 
        [self.voiceCaptureControl showViewWithErrorMsg:@"录音失败，请稍后重试"];
        [self performSelector:@selector(destroyVoiceCaptureControl) withObject:nil afterDelay:1.0f];
        if ([self.delegate respondsToSelector:@selector(voiceRecordControlDidCancel:)]) {
            [self.delegate voiceRecordControlDidCancel:self];
        }
        return;
    }
    
    if (self.voiceCaptureControl.duration > 1.0f) {
        if ([self.delegate respondsToSelector:@selector(voiceRecordControl:didEnd:duration:error:)]) {
            [self.delegate voiceRecordControl:self
                                       didEnd:recordData
                                     duration:self.voiceCaptureControl.duration
                                        error:nil];
        }
        [self destroyVoiceCaptureControl];
    } else {
        // message too short
        if (!self.isAudioRecoderTimeOut) {
            self.isAudioRecoderTimeOut = NO;
            [self.voiceCaptureControl showViewWithErrorMsg:@"录音时间太短"];
            [self performSelector:@selector(destroyVoiceCaptureControl) withObject:nil afterDelay:1.0f];
            if ([self.delegate respondsToSelector:@selector(voiceRecordControlDidCancel:)]) {
                [self.delegate voiceRecordControlDidCancel:self];
            }
        }
    }
}

//滑出显示
- (void)dragExitRecordEvent {
    [self.voiceCaptureControl showCancelView];
}

- (void)dragEnterRecordEvent {
    [self.voiceCaptureControl hideCancelView];
}

- (void)onCancelRecordEvent {
    if (self.voiceCaptureControl) {
        if ([self.delegate respondsToSelector:@selector(voiceRecordControlDidCancel:)]) {
            [self.delegate voiceRecordControlDidCancel:self];
        }
        [self.voiceCaptureControl cancelRecord];
        [self destroyVoiceCaptureControl];
    }
}

#pragma mark - DCVoiceCaptureControlDelegate
- (void)DCVoiceCaptureControlTimeout:(double)duration {
    self.isAudioRecoderTimeOut = YES;
    [self onEndRecordEvent];
}

- (void)DCVoiceCaptureControlTimeUpdate:(double)duration {
}

#pragma mark - Notification
- (void)registerNotification{
    [[NSNotificationCenter defaultCenter] addObserver:self
    selector:@selector(audioSessionInterrupted:)
        name:AVAudioSessionInterruptionNotification
      object:nil];
}

- (void)audioSessionInterrupted:(NSNotification *)notification {
    NSDictionary *info = notification.userInfo;
    AVAudioSessionInterruptionType interruptionType = [info[AVAudioSessionInterruptionTypeKey] unsignedIntegerValue];
    switch (interruptionType) {
    case AVAudioSessionInterruptionTypeBegan: {
        [self onEndRecordEvent];
    } break;
    default:
        break;
    }
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Private
- (void)destroyVoiceCaptureControl {
    [self.voiceCaptureControl stopTimer];
    [self.voiceCaptureControl removeFromSuperview];
    self.voiceCaptureControl = nil;
    self.isAudioRecoderTimeOut = NO;
}

- (void)checkRecordPermission:(void (^)(void))successBlock {
    if ([[AVAudioSession sharedInstance] respondsToSelector:@selector(requestRecordPermission:)]) {
        if ([[AVAudioSession sharedInstance] respondsToSelector:@selector(recordPermission)]) {
            if ([AVAudioSession sharedInstance].recordPermission == AVAudioSessionRecordPermissionGranted) {
                successBlock();
            } else if ([AVAudioSession sharedInstance].recordPermission == AVAudioSessionRecordPermissionDenied) {
                [self alertRecordPermissionDenied];
            } else if ([AVAudioSession sharedInstance].recordPermission == AVAudioSessionRecordPermissionUndetermined) {
                [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
                    if (!granted) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self alertRecordPermissionDenied];
                        });
                    };
                }];
            }
        }
    } else {
        successBlock();
    }
}

- (void)alertRecordPermissionDenied {
    [MBProgressHUD showTips:@"没有麦克风访问权限"];
}
@end
