//
//  DCVoiceMessageCell.m
//  DCProjectFile
//
//  Created  on 2023/6/27.
//

#import "DCVoiceMessageCell.h"

#define Voice_Height 40
#define voice_Unread_View_Width 8
#define Play_Voice_View_Width 16

#define kAudioBubbleMinWidth 85
#define kAudioBubbleMaxWidth 180
#define kMessageContentViewHeight 36


NSString *const kNotificationPlayVoice = @"kNotificationPlayVoice";

static NSTimer *s_previousAnimationTimer = nil;
static UIImageView *s_previousPlayVoiceImageView = nil;
static DCMessageDirection s_previousMessageDirection;
static NSString* s_messageId = @"0";

@interface DCVoiceMessageCell ()<DCVoicePlayerObserver>

@property (nonatomic) long duration;

@property (nonatomic) CGSize voiceViewSize;

@property (nonatomic) int animationIndex;

@property (nonatomic, strong) NSTimer *animationTimer;

@property (nonatomic, strong) DCVoicePlayer *voicePlayer;

@end



@implementation DCVoiceMessageCell

#pragma mark - Life Cycle
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)dealloc {
    [self disableCurrentAnimationTimer];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Public Methods

- (void)playVoice {
    if (self.voiceUnreadTagView) {
        self.voiceUnreadTagView.hidden = YES;
        [self.voiceUnreadTagView removeFromSuperview];
        self.voiceUnreadTagView = nil;
        self.model.is_read = 1;
        [self.model bg_saveOrUpdateAsync:^(BOOL isSuccess) {
            
        }];
    }
    [self disablePreviousAnimationTimer];

    if ([self.model.messageId isEqualToString:s_messageId]) {
        if (self.voicePlayer.isPlaying) {
            [self.voicePlayer stopPlayVoice];
        } else {
            [self startPlayingVoiceData];
        }
    } else {
        [self startPlayingVoiceData];
    }
}

- (void)stopPlayingVoice {
    if ([self.model.messageId isEqualToString:s_messageId]) {
        if (self.voicePlayer.isPlaying) {
            [self stopPlayingVoiceData];
            [self disableCurrentAnimationTimer];
        }
    }
}

#pragma mark - Super Methods

+ (CGSize)sizeForMessageModel:(DCMessageContent *)model withCollectionViewWidth:(CGFloat)collectionViewWidth referenceExtraHeight:(CGFloat)extraHeight {
    CGFloat __messagecontentview_height = Voice_Height;
    __messagecontentview_height += extraHeight;
    return CGSizeMake(collectionViewWidth, __messagecontentview_height + (model.isDisplayMsgTime?20:0) +((model.conversationType==DC_ConversationType_GROUP && model.messageDirection==DC_MessageDirection_RECEIVE)?20:0));
}

- (void)resetAnimationTimer{
    if ([s_messageId isEqualToString:self.model.messageId]) {
        if ((self.voicePlayer.isPlaying)) {
            [self disableCurrentAnimationTimer];
            [self enableCurrentAnimationTimer];
        }
    } else {
        [self disableCurrentAnimationTimer];
    }
}
- (void)setMessageInfo:(DCMessageContent *)voiceMessage{
    if (voiceMessage) {
        self.voiceDurationLabel.text = [NSString stringWithFormat:@"%d''", voiceMessage.extra.duration];
    } else {
        DCLog(@"[RongIMKit]: RCMessageModel.content is NOT RCHQVoiceMessage object");
    }
}

- (CGFloat)getBubbleWidth:(long)duration{
    CGFloat audioBubbleWidth =
        kAudioBubbleMinWidth +
        (kAudioBubbleMaxWidth - kAudioBubbleMinWidth) * duration / 60;
    
    audioBubbleWidth = audioBubbleWidth > kAudioBubbleMaxWidth ? kAudioBubbleMaxWidth : audioBubbleWidth;
    
    return audioBubbleWidth;
}

- (void)updateSubViewsLayout:(DCMessageContent *)voiceMessage{
    self.nicknameLabel.hidden = (self.model.conversationType==DC_ConversationType_PRIVATE || self.model.messageDirection == DC_MessageDirection_SEND);
    
    CGFloat audioBubbleWidth = [self getBubbleWidth:voiceMessage.extra.duration];
    
    CGRect rect = self.messageContentView.frame;
    rect.size.width = audioBubbleWidth;
    rect.size.height = Voice_Height;
    self.messageContentView.frame = rect;
    
    self.bubbleBackgroundView.frame = self.messageContentView.bounds;
    
    if (self.model.messageDirection == DC_MessageDirection_SEND) {
        self.bubbleBackgroundView.image = [UIImage imageNamed:@"msg_bubble_sent"];
         self.voiceDurationLabel.textAlignment = NSTextAlignmentRight;
         self.playVoiceView.frame = CGRectMake(self.messageContentView.frame.size.width-18-Play_Voice_View_Width, (Voice_Height - Play_Voice_View_Width)/2, Play_Voice_View_Width, Play_Voice_View_Width);
        self.voiceDurationLabel.frame = CGRectMake(12, 0, CGRectGetMinX(self.playVoiceView.frame) - 20, Voice_Height);
        [self.voiceDurationLabel setTextColor:kWhiteColor];
        self.playVoiceView.image = [UIImage imageNamed:@"to_voice_3"];
    }else{
        self.bubbleBackgroundView.image = [UIImage imageNamed:@"msg_bubble_receive"];
        self.playVoiceView.image = [UIImage imageNamed:@"from_voice_3"];
        [self.voiceDurationLabel setTextColor:HEXCOLOR(0x111f2c)];
         self.voiceDurationLabel.textAlignment = NSTextAlignmentLeft;
         self.playVoiceView.frame = CGRectMake(18, (Voice_Height - Play_Voice_View_Width)/2, Play_Voice_View_Width, Play_Voice_View_Width);
         self.voiceDurationLabel.frame = CGRectMake(CGRectGetMaxX(self.playVoiceView.frame) + 8, 0, audioBubbleWidth - (CGRectGetMaxX(self.playVoiceView.frame) + 8), Voice_Height);
     }
    UIImage *image = self.bubbleBackgroundView.image;
    self.bubbleBackgroundView.image = [self.bubbleBackgroundView.image
        resizableImageWithCapInsets:UIEdgeInsetsMake(image.size.height * 0.5, image.size.width * 0.5,
                                                     image.size.height * 0.5, image.size.width * 0.5)];
    
    [self addVoiceUnreadTagView];
    [self setCellAutoLayout];
    
}

- (void)addVoiceUnreadTagView{
    [self.voiceUnreadTagView removeFromSuperview];
    self.voiceUnreadTagView.image = nil;
    [self.voiceUnreadTagView setHidden:YES];
    if (DC_MessageDirection_RECEIVE == self.model.messageDirection) {
        CGFloat x = CGRectGetMaxX(self.messageContentView.frame) + 8;
        if (!self.model.is_read) {
            self.voiceUnreadTagView = [[UIImageView alloc] initWithFrame:CGRectMake(x, self.messageContentView.frame.origin.y + (Voice_Height-voice_Unread_View_Width)/2, voice_Unread_View_Width, voice_Unread_View_Width)];
            [self.voiceUnreadTagView setHidden:NO];
            [self.contentView addSubview:self.voiceUnreadTagView];
            self.voiceUnreadTagView.image = [UIImage imageNamed:@"voice_unread"];
        }
    }
}

- (void)setDataModel:(DCMessageContent *)model {
    [super setDataModel:model];
    [self resetAnimationTimer];

    [self setMessageInfo:model];
    [self updateSubViewsLayout:model];
}

#pragma mark - RCVoicePlayerObserver
- (void)PlayerDidFinishPlaying:(BOOL)isFinish {
    if (isFinish) {
        [self disableCurrentAnimationTimer];
    }
}

- (void)audioPlayerDecodeErrorDidOccur:(NSError *)error {
    [self disableCurrentAnimationTimer];
}

#pragma mark - Notification

- (void)registerNotification{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(resetActiveEventInBackgroundMode)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(resetByExtensionModelEvents)
                                                 name:@"RCKitExtensionModelResetVoicePlayingNotification"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(stopPlayingVoiceDataIfNeed:)
                                                 name:@"kNotificationStopVoicePlayer"
                                               object:nil];
}

- (void)playVoiceNotification:(NSNotification *)notification {
    NSString * messageId = [NSString stringWithFormat:@"%@",notification.object];
    if ([messageId isEqualToString:self.model.messageId]) {
        [self playVoice];
    }
}

// todo cyenux
- (void)resetByExtensionModelEvents {
    [self stopPlayingVoiceData];
    [self disableCurrentAnimationTimer];
}

// stop and disable timer during background mode.
- (void)resetActiveEventInBackgroundMode {
    [self stopPlayingVoiceData];
    [self disableCurrentAnimationTimer];
}

#pragma mark - Private Methods

- (void)initialize {
    [self showBubbleBackgroundView:YES];
    [self.messageContentView addSubview:self.playVoiceView];
    [self.messageContentView addSubview:self.voiceDurationLabel];

    self.voicePlayer = [DCVoicePlayer defaultPlayer];
    [self registerNotification];
    
}

- (void)stopPlayingVoiceDataIfNeed:(NSNotification *)notification {
    NSString * messageId = [NSString stringWithFormat:@"%@",notification.object];
    if ([messageId isEqualToString:self.model.messageId]) {
        [self disableCurrentAnimationTimer];
    }
}

- (void)startPlayingVoiceData {

    NSData *wavAudioData = [DCFileManager getMessageFileData:self.model.extra.path];
    if (wavAudioData) {
        BOOL bPlay = [self.voicePlayer playVoice:DC_ConversationType_PRIVATE
                                        targetId:self.model.targetId
                                       messageId:self.model.messageId
                                       direction:self.model.messageDirection
                                       voiceData:wavAudioData
                                        observer:self];
        // if failed to play the voice message, reset all indicator.
        if (!bPlay) {
            [self stopPlayingVoiceData];
            [self disableCurrentAnimationTimer];
        } else {
            [self enableCurrentAnimationTimer];
        }
        s_messageId = self.model.messageId;
    } else {
        NSString * urlStr = self.model.extra.url;
        NSString *fileName = [DCFileManager fileName:self.model.extra.path];
        NSString *path = [DCFileManager getMessageFileCachePath];
        NSString *filePath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@",fileName]];
        [[DCRequestManager sharedManager] downloadWithUrl:urlStr filePath:filePath success:^(id  _Nullable result) {
            if (result) {
                [self startPlayingVoiceData];
            }else {
                [MBProgressHUD showTips:@"播放失败"];
            }
        }];
    }
}


- (void)stopPlayingVoiceData {
    if (self.voicePlayer.isPlaying) {
        [self.voicePlayer stopPlayVoice];
    }
}
- (void)enableCurrentAnimationTimer {
    self.animationTimer = [NSTimer scheduledTimerWithTimeInterval:0.5
                                                           target:self
                                                         selector:@selector(scheduleAnimationOperation)
                                                         userInfo:nil
                                                          repeats:YES];
    [self.animationTimer fire];

    s_previousAnimationTimer = self.animationTimer;
    s_previousPlayVoiceImageView = self.playVoiceView;
    s_previousMessageDirection = self.model.messageDirection;
}

- (void)scheduleAnimationOperation {

    self.animationIndex++;
    NSString *playingIndicatorIndex;
    if (DC_MessageDirection_SEND == self.model.messageDirection) {
        playingIndicatorIndex = [NSString stringWithFormat:@"to_voice_%d", (self.animationIndex % 4)];
    } else {
        playingIndicatorIndex = [NSString stringWithFormat:@"from_voice_%d", (self.animationIndex % 4)];
    }
    UIImage *image = [UIImage imageNamed:playingIndicatorIndex];;
    
    self.playVoiceView.image = image;
}

- (void)disableCurrentAnimationTimer {
    if (self.animationTimer && [self.animationTimer isValid]) {
        [self.animationTimer invalidate];
        self.animationTimer = nil;
        self.animationIndex = 0;
    }
    if (DC_MessageDirection_SEND == self.model.messageDirection) {
        self.playVoiceView.image = [UIImage imageNamed:@"to_voice_3"];
    } else {
        self.playVoiceView.image = [UIImage imageNamed:@"from_voice_3"];
    }
}

- (void)disablePreviousAnimationTimer {
    if (s_previousAnimationTimer && [s_previousAnimationTimer isValid]) {
        [s_previousAnimationTimer invalidate];
        s_previousAnimationTimer = nil;

        /**
         *  reset the previous playVoiceView indicator image
         */
        if (s_previousPlayVoiceImageView) {
            if (DC_MessageDirection_SEND == self.model.messageDirection) {
                s_previousPlayVoiceImageView.image = [UIImage imageNamed:@"to_voice_3"];
            } else {
                s_previousPlayVoiceImageView.image = [UIImage imageNamed:@"from_voice_3"];
            }
            s_previousPlayVoiceImageView = nil;
            s_previousMessageDirection = 0;
        }
    }
}


#pragma mark - Getter

- (DCVoicePlayer *)voicePlayer{
    if (!_voicePlayer) {
        _voicePlayer = [DCVoicePlayer defaultPlayer];
    }
    return _voicePlayer;
}

- (UIImageView *)playVoiceView{
    if (!_playVoiceView) {
        _playVoiceView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _playVoiceView.image = [UIImage imageNamed:@"play_voice"];

    }
    return _playVoiceView;
}

- (UILabel *)voiceDurationLabel{
    if (!_voiceDurationLabel) {
        _voiceDurationLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _voiceDurationLabel.textAlignment = NSTextAlignmentLeft;
        _voiceDurationLabel.font = [UIFont systemFontOfSize:15];
    }
    return _voiceDurationLabel;
}
@end
