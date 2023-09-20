

#import "DCVoiceRecorder.h"
#import <AVFoundation/AVFoundation.h>

static DCVoiceRecorder *DCVoiceRecorderHandler = nil;
static DCVoiceRecorder *rcHQVoiceRecorderHandler = nil;

@interface DCVoiceRecorder () <AVAudioRecorderDelegate>

@property (nonatomic, strong) NSDictionary *recordSettings;
@property (nonatomic, strong) NSURL *recordTempFileURL;
@property (nonatomic) BOOL isRecording;
@property (nonatomic, strong) AVAudioRecorder *recorder;
@property (nonatomic, weak) id<DCVoiceRecorderDelegate> voiceRecorderDelegate;
@end

@implementation DCVoiceRecorder
#pragma mark - Public Methods
+ (DCVoiceRecorder *)defaultVoiceRecorder {
    @synchronized(self) {
        if (nil == DCVoiceRecorderHandler) {
            DCVoiceRecorderHandler = [[[self class] alloc] init];
            NSInteger sample = 8000.00f;
//#pragma clang diagnostic push
//#pragma clang diagnostic ignored "-Wdeprecated-declarations"
//            switch ([RCCoreClient sharedCoreClient].sampleRate) {
//#pragma clang diagnostic pop
//            case RCSample_Rate_8000:
//                sample = 8000.00f;
//                break;
//            case RCSample_Rate_16000:
//                sample = 16000.00f;
//                break;
//            default:
//                sample =
//                break;
//            }
            DCVoiceRecorderHandler.recordSettings = @{
                AVFormatIDKey : @(kAudioFormatLinearPCM),
                AVSampleRateKey : @(sample),
                AVNumberOfChannelsKey : @1,
                AVLinearPCMIsNonInterleaved : @NO,
                AVLinearPCMIsFloatKey : @NO,
                AVLinearPCMIsBigEndianKey : @NO
            };

            DCVoiceRecorderHandler.recordTempFileURL =
                [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:@"tempAC.wav"]];
            DCLog(@"[RongExtensionKit]: Using File called: %@", DCVoiceRecorderHandler.recordTempFileURL);
        }
        return DCVoiceRecorderHandler;
    }
}

+ (DCVoiceRecorder *)hqVoiceRecorder {
    @synchronized(self) {
        if (nil == rcHQVoiceRecorderHandler) {
            rcHQVoiceRecorderHandler = [[[self class] alloc] init];
            rcHQVoiceRecorderHandler.recordSettings = @{
                AVFormatIDKey : @(kAudioFormatMPEG4AAC_HE),
                AVNumberOfChannelsKey : @1,
                AVEncoderBitRateKey : @(32000)
            };
            rcHQVoiceRecorderHandler.recordTempFileURL =
                [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:@"HQTempAC.m4a"]];
            DCLog(@"[RongExtensionKit]: Using File called: %@", rcHQVoiceRecorderHandler.recordTempFileURL);
        }
        return rcHQVoiceRecorderHandler;
    }
}

- (BOOL)startRecordWithObserver:(id<DCVoiceRecorderDelegate>)observer {
    self.voiceRecorderDelegate = observer;

    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    [audioSession setActive:YES error:nil];

    NSError *error = nil;

    if (nil == self.recorder) {
        self.recorder =
            [[AVAudioRecorder alloc] initWithURL:self.recordTempFileURL settings:self.recordSettings error:&error];
        self.recorder.delegate = self;
        self.recorder.meteringEnabled = YES;
    }

    BOOL isRecord = NO;
    isRecord = [self.recorder prepareToRecord];
    DCLog(@"[RongExtensionKit]: prepareToRecord is %@", isRecord ? @"success" : @"failed");

    isRecord = [self.recorder record];
    DCLog(@"[RongExtensionKit]: record is %@", isRecord ? @"success" : @"failed");
    self.isRecording = self.recorder.isRecording;
    return isRecord;
}

- (BOOL)cancelRecord {
    self.voiceRecorderDelegate = nil;
    if (nil != self.recorder && [self.recorder isRecording] &&
        [[NSFileManager defaultManager] fileExistsAtPath:self.recorder.url.path]) {
        [self.recorder stop];
        [self.recorder deleteRecording];
        self.recorder = nil;
        self.isRecording = self.recorder.isRecording;
        if (![DCMessageManager sharedManager].isExclusiveSoundPlayer) {
            [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
            [[AVAudioSession sharedInstance] setActive:NO
                                           withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation
                                                 error:nil];
        } else {
            AVAudioSession *audioSession = [AVAudioSession sharedInstance];
            [audioSession setCategory:AVAudioSessionCategoryAmbient error:nil];
            [audioSession setActive:YES error:nil];
        }
        return YES;
    }
    if (![DCMessageManager sharedManager].isExclusiveSoundPlayer) {
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
        [[AVAudioSession sharedInstance] setActive:NO
                                       withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation
                                             error:nil];
    } else {
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        [audioSession setCategory:AVAudioSessionCategoryAmbient error:nil];
        [audioSession setActive:YES error:nil];
    }
    return NO;
}
- (void)stopRecord:(void (^)(NSData *, NSTimeInterval))compeletion {
    if (!self.recorder.url) {
        if (compeletion) {
            compeletion(nil, 0);
        }
        return;
    }
    if (!self.recorder.isRecording) {
        if (compeletion) {
            compeletion(nil, 0);
        }
        return;
    }
    NSURL *url = [[NSURL alloc] initWithString:self.recorder.url.absoluteString];
    NSTimeInterval audioLength = self.recorder.currentTime;
    [self.recorder stop];
    NSData *currentRecordData = [NSData dataWithContentsOfURL:url];
    self.isRecording = self.recorder.isRecording;
    self.recorder = nil;
    //非独占式播放音频需要释放AVAudioSession
    if (![DCMessageManager sharedManager].isExclusiveSoundPlayer) {
        [[AVAudioSession sharedInstance] setActive:NO
                                       withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation
                                             error:nil];
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryAmbient error:nil];

    } else {
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        [audioSession setCategory:AVAudioSessionCategoryAmbient error:nil];
        [audioSession setActive:YES error:nil];
    }
    if (compeletion) {
        compeletion(currentRecordData, audioLength);
    }
}
- (CGFloat)updateMeters {
    if (nil != self.recorder) {
        [self.recorder updateMeters];
    }

    float peakPower = [self.recorder averagePowerForChannel:0];
    CGFloat power = (1.0 / 160.0) * (peakPower + 160.0);
    return power;
}
#pragma mark - AVAudioRecorderDelegate
- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag {
    if ([self.voiceRecorderDelegate respondsToSelector:@selector(RCVoiceAudioRecorderDidFinishRecording:)]) {
        [self.voiceRecorderDelegate RCVoiceAudioRecorderDidFinishRecording:flag];
    }
    self.voiceRecorderDelegate = nil;
    self.isRecording = self.recorder.isRecording;
}

- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError *)error {
    if ([self.voiceRecorderDelegate respondsToSelector:@selector(RCVoiceAudioRecorderEncodeErrorDidOccur:)]) {
        [self.voiceRecorderDelegate RCVoiceAudioRecorderEncodeErrorDidOccur:error];
    }

    self.voiceRecorderDelegate = nil;
    self.isRecording = self.recorder.isRecording;
}
@end
