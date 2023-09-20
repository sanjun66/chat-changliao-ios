

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol DCVoiceRecorderDelegate;

@interface DCVoiceRecorder : NSObject

+ (DCVoiceRecorder *)defaultVoiceRecorder;

+ (DCVoiceRecorder *)hqVoiceRecorder;

@property (nonatomic, readonly) BOOL isRecording;

- (BOOL)startRecordWithObserver:(id<DCVoiceRecorderDelegate>)observer;

- (BOOL)cancelRecord;

- (void)stopRecord:(void (^)(NSData *wavData, NSTimeInterval secs))compeletion;

- (CGFloat)updateMeters;

@end

@protocol DCVoiceRecorderDelegate <NSObject>

- (void)RCVoiceAudioRecorderDidFinishRecording:(BOOL)success;
- (void)RCVoiceAudioRecorderEncodeErrorDidOccur:(NSError *)error;

@end
