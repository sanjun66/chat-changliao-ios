

#import <Foundation/Foundation.h>

@protocol DCVoicePlayerObserver;

@interface DCVoicePlayer : NSObject

@property (nonatomic, readonly) BOOL isPlaying;
@property (nonatomic, copy) NSString* messageId;
@property (nonatomic, assign) DCConversationType conversationType;
@property (nonatomic, copy) NSString *targetId;

+ (DCVoicePlayer *)defaultPlayer;
- (BOOL)playVoice:(DCConversationType)conversationType
         targetId:(NSString *)targetId
        messageId:(NSString*)messageId
        direction:(DCMessageDirection)messageDirection
        voiceData:(NSData *)data
         observer:(id<DCVoicePlayerObserver>)observer;

- (void)stopPlayVoice;

- (void)resetPlayer;

@end

@protocol DCVoicePlayerObserver <NSObject>

- (void)PlayerDidFinishPlaying:(BOOL)isFinish;

- (void)audioPlayerDecodeErrorDidOccur:(NSError *)error;

@end
