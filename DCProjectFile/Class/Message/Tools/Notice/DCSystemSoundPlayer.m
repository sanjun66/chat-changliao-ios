//
//  DCSystemSoundPlayer.m
//  DCProjectFile
//
//  Created  on 2023/7/17.
//

#import "DCSystemSoundPlayer.h"
#define kPlayDuration 0.9

static DCSystemSoundPlayer *dcSystemSoundPlayerHandler = nil;

@interface DCSystemSoundPlayer ()

@property (nonatomic, assign) SystemSoundID soundId;
@property (nonatomic, copy) NSString *soundFilePath;

@property (nonatomic, copy) NSString *targetId;
@property (nonatomic, assign) DCConversationType conversationType;
@property (atomic) BOOL isPlaying;
@property (nonatomic, copy) DCSystemSoundPlayerCompletion completion;

@end

static void playSoundEnd(SystemSoundID mySSID, void *myself) {
    AudioServicesRemoveSystemSoundCompletion(mySSID);
    AudioServicesDisposeSystemSoundID(mySSID);

    //    CFRelease(myself);
    [DCSystemSoundPlayer defaultPlayer].isPlaying = NO;
}


@implementation DCSystemSoundPlayer
+ (DCSystemSoundPlayer *)defaultPlayer {

    @synchronized(self) {
        if (nil == dcSystemSoundPlayerHandler) {
            dcSystemSoundPlayerHandler = [[[self class] alloc] init];
            dcSystemSoundPlayerHandler.isPlaying = NO;
        }
    }

    return dcSystemSoundPlayerHandler;
}

- (void)setIgnoreConversationType:(DCConversationType)conversationType targetId:(NSString *)targetId {
    self.conversationType = conversationType;
    self.targetId = targetId;
}

- (void)resetIgnoreConversation {
    self.targetId = nil;
}

- (void)playSoundByMessage:(DCMessageContent *)dcMessage completeBlock:(DCSystemSoundPlayerCompletion)completion {
    if (dcMessage.conversationType == self.conversationType && [dcMessage.targetId isEqualToString:self.targetId]) {
        completion(NO);
    } else {
        self.completion = completion;
        [self needPlaySoundByMessage:dcMessage];
    }
}

- (void)needPlaySoundByMessage:(DCMessageContent *)dcMessage {
//    if (RCSDKRunningMode_Background == [RCCoreClient sharedCoreClient].sdkRunningMode) {
//        return;
//    }
    //如果来信消息时正在播放或录制语音消息
    if ([DCVoicePlayer defaultPlayer].isPlaying || [DCVoiceRecorder defaultVoiceRecorder].isRecording ||
        [DCVoiceRecorder hqVoiceRecorder].isRecording) {
        self.completion(NO);
        return;
    }

    // 播放小视频时接收新的消息应不响铃且小视频应不停止播放
    // 录制小视频时接收新的消息应不响铃
//    if ([RCKitUtility isCameraHolding] || [RCKitUtility isAudioHolding]) {
//        self.completion(NO);
//        return;
//    }
    BOOL isNeedMute = [[NSUserDefaults standardUserDefaults] boolForKey:@"kisNeedMute"];
    if (isNeedMute) {
        self.completion(NO);
        return;
    }
    
    if (self.isPlaying) {
        self.completion(NO);
        return;
    }

    AVAudioSession *audioSession = [AVAudioSession sharedInstance];

    NSError *err = nil;

#if __IPHONE_OS_VERSION_MAX_ALLOWED < __IPHONE_7_0
    //是否扬声器播放
    UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
    AudioSessionSetProperty(kAudioSessionProperty_OverrideAudioRoute, sizeof(audioRouteOverride), &audioRouteOverride);
#else
    [audioSession overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:nil];
#endif

    [audioSession setCategory:AVAudioSessionCategoryAmbient error:nil];

    [audioSession setActive:YES error:&err];
    

    if (nil != err) {
        DCLog(@"[RongIMKit]: Exception is thrown when setting audio session");
        self.completion(NO);
        return;
    }
    if (nil == _soundFilePath) {
        // no redefined path, use the default
//        _soundFilePath = [[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"RongCloud.bundle"]
//            stringByAppendingPathComponent:@"sms-received.caf"];
        _soundFilePath = [[NSBundle mainBundle] pathForResource:@"Doda" ofType:@"mp3"];
    }

    if (nil != _soundFilePath) {
        OSStatus error =
            AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:_soundFilePath], &_soundId);
        if (error != kAudioServicesNoError) { //获取的声音的时候，出现错误
            DCLog(@"[RongIMKit]: Exception is thrown when creating system sound ID");
            self.completion(NO);
            return;
        }

        self.isPlaying = YES;
        if (kiOS9Later) {
            AudioServicesPlaySystemSoundWithCompletion(_soundId, ^{
                self.isPlaying = NO;
                self.completion(YES);
                return;
            });
        } else {
            AudioServicesPlaySystemSound(_soundId);
            AudioServicesAddSystemSoundCompletion(_soundId, NULL, NULL, playSoundEnd, NULL);
            self.completion(YES);
            return;
        }
    } else {
        DCLog(@"[RongIMKit]: Not found the related sound resource file in RongCloud.bundle");
        self.completion(NO);
        return;
    }
}
@end
