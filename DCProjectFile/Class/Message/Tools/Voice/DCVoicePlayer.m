
#import "DCVoicePlayer.h"
#import <AVFoundation/AVFoundation.h>

NSString *const kNotificationStopVoicePlayer = @"kNotificationStopVoicePlayer";

static BOOL bSensorStateStart = YES;
static DCVoicePlayer *DCVoicePlayerHandler = nil;

@interface DCVoicePlayer () <AVAudioPlayerDelegate>

@property (nonatomic, strong) AVAudioPlayer *audioPlayer;
@property (nonatomic) BOOL isPlaying;
@property (nonatomic, weak) id<DCVoicePlayerObserver> voicePlayerObserver;
@property (nonatomic) DCMessageDirection messageDirection;
@property (nonatomic) NSString *playerCategory;
- (void)enableSystemProperties;
- (void)setDefaultAudioSession:(NSString *)category;
- (void)disableSystemProperties;
- (BOOL)startPlayVoice:(NSData *)data;
@end

@implementation DCVoicePlayer

+ (DCVoicePlayer *)defaultPlayer {
    @synchronized(self) {
        if (nil == DCVoicePlayerHandler) {
            DCVoicePlayerHandler = [[[self class] alloc] init];
            DCVoicePlayerHandler.playerCategory = AVAudioSessionCategoryPlayback;
        }
    }
    return DCVoicePlayerHandler;
}
- (void)setDefaultAudioSession:(NSString *)category {
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    DCLog(@"[RongIMKit]: [audioSession category ] %@", [audioSession category]);
    //    //默认情况下扬声器播放，如果当前audioSession状态是AVAudioSessionCategoryRecord，证明正在录音，不要设置category
    //    if(![[audioSession category ] isEqualToString:AVAudioSessionCategoryRecord])
    [audioSession setCategory:category
                        error:nil]; // 2016-12-05,edit by dulizhao ,设置category，在手机静音的情况下也可播放声音。
    [audioSession setActive:YES error:nil];
}

//处理监听触发事件
- (void)sensorStateChange:(NSNotification *)notification {
    if (bSensorStateStart) {
        bSensorStateStart = NO;

        dispatch_async(dispatch_get_main_queue(), ^{
            if ([[UIDevice currentDevice] proximityState] == YES) {
                self.playerCategory = AVAudioSessionCategoryPlayAndRecord;
                DCLog(@"[RongIMKit]: Device is close to user");
                [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
            } else {
                DCLog(@"[RongIMKit]: Device is not close to user");
                self.playerCategory = AVAudioSessionCategoryPlayback;
                [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
            }
            bSensorStateStart = YES;
        });
    }
}

- (BOOL)playVoice:(DCConversationType)conversationType
         targetId:(NSString *)targetId
        messageId:(NSString*)messageId
        direction:(DCMessageDirection)messageDirection
        voiceData:(NSData *)data
         observer:(id<DCVoicePlayerObserver>)observer {

    if (self.isPlaying) {
        [self resetPlayer];
    }

    self.voicePlayerObserver = observer;
    self.messageId = messageId;
    self.conversationType = conversationType;
    self.targetId = targetId;
    [self enableSystemProperties];
    [self setDefaultAudioSession:_playerCategory];

    self.messageDirection = messageDirection;

    return [self startPlayVoice:data];
}

//停止播放
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    DCLog(@"%s", __FUNCTION__);

    self.isPlaying = self.audioPlayer.playing;
    [self disableSystemProperties];

    // notify at the end
    if ([self.voicePlayerObserver respondsToSelector:@selector(PlayerDidFinishPlaying:)]) {
        [self.voicePlayerObserver PlayerDidFinishPlaying:flag];
    }

    // set the observer to nil
    self.voicePlayerObserver = nil;
    self.audioPlayer = nil;
    if (![DCMessageManager sharedManager].isExclusiveSoundPlayer) {
        [[AVAudioSession sharedInstance] setActive:NO
                                       withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation
                                             error:nil];
    } else {
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        [audioSession setCategory:AVAudioSessionCategoryAmbient error:nil];
        [audioSession setActive:YES error:nil];
    }

    [self sendPlayFinishNotification];
    [self sendContinuousPlayNotification];
}

- (void)sendContinuousPlayNotification {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"RCContinuousPlayNotification"
                                                        object:self.messageId
                                                      userInfo:@{
                                                          @"conversationType" : @(self.conversationType),
                                                          @"targetId" : self.targetId
                                                      }];
}

- (void)sendPlayStartNotification {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"kNotificationPlayVoice"
                                                        object:self.messageId
                                                      userInfo:@{
                                                          @"conversationType" : @(self.conversationType),
                                                          @"targetId" : self.targetId
                                                      }];
}

- (void)sendPlayFinishNotification {
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationStopVoicePlayer
                                                        object:self.messageId
                                                      userInfo:@{
                                                          @"conversationType" : @(self.conversationType),
                                                          @"targetId" : self.targetId
                                                      }];
}
//播放错误
- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error {
    DCLog(@"%s", __FUNCTION__);
    // do something
    self.isPlaying = self.audioPlayer.playing;
    [self disableSystemProperties];

    // notify at the end
    if ([self.voicePlayerObserver respondsToSelector:@selector(audioPlayerDecodeErrorDidOccur:)]) {
        [self.voicePlayerObserver audioPlayerDecodeErrorDidOccur:error];
    }
    self.voicePlayerObserver = nil;
    self.audioPlayer = nil;
    if (![DCMessageManager sharedManager].isExclusiveSoundPlayer) {
        [[AVAudioSession sharedInstance] setActive:NO
                                       withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation
                                             error:nil];
    } else {
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        [audioSession setCategory:AVAudioSessionCategoryAmbient error:nil];
        [audioSession setActive:YES error:nil];
    }
    [self sendPlayFinishNotification];
}

- (BOOL)startPlayVoice:(NSData *)data {
    NSError *error = nil;

    self.audioPlayer = [[AVAudioPlayer alloc] initWithData:data error:&error];
    self.audioPlayer.delegate = self;
    self.audioPlayer.volume = 1.0;

    BOOL ready = NO;
    if (!error) {

        DCLog(@"[RongIMKit]: init AudioPlayer %@", error);

        ready = [self.audioPlayer prepareToPlay];
        DCLog(@"[RongIMKit]: prepare audio player %@", ready ? @"success" : @"failed");
        ready = [self.audioPlayer play];
        DCLog(@"[RongIMKit]: async play is %@", ready ? @"success" : @"failed");
        if (ready) {
            [self sendPlayStartNotification];
        }
    }
    self.isPlaying = self.audioPlayer.playing;
    DCLog(@"self.isPlaying > %d", self.isPlaying);
    DCLog(@"[RongIMKit]: [audioSession category ] %@", [[AVAudioSession sharedInstance] category]);
    return ready;
}

- (void)stopPlayVoice {
    [self resetPlayer];
    if (![DCMessageManager sharedManager].isExclusiveSoundPlayer) {
        [[AVAudioSession sharedInstance] setActive:NO
                                       withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation
                                             error:nil];
    } else {
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        [audioSession setCategory:AVAudioSessionCategoryAmbient error:nil];
        [audioSession setActive:YES error:nil];
    }
}

- (void)resetPlayer {
    if (nil != self.audioPlayer && self.audioPlayer.playing) {
        [self.audioPlayer stop];
        self.audioPlayer = nil;

        [self sendPlayFinishNotification];
        [self disableSystemProperties];
    }
    self.isPlaying = self.audioPlayer.playing;
    self.voicePlayerObserver = nil;
}

- (void)enableSystemProperties {
    [[UIDevice currentDevice]
        setProximityMonitoringEnabled:YES]; //建议在播放之前设置yes，播放结束设置NO，这个功能是开启红外感应
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIDeviceProximityStateDidChangeNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(sensorStateChange:)
                                                 name:UIDeviceProximityStateDidChangeNotification
                                               object:nil];
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
}
- (void)disableSystemProperties {
    dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC));
    dispatch_after(time, dispatch_get_main_queue(), ^(void) {
        if (!self.isPlaying) {
            self.playerCategory = AVAudioSessionCategoryPlayback;
            [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
            [[NSNotificationCenter defaultCenter] removeObserver:self
                                                            name:UIDeviceProximityStateDidChangeNotification
                                                          object:nil];
        }
    });
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
}

@end
