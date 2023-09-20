
#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>
@protocol DCVoiceCaptureControlDelegate <NSObject>
- (void)DCVoiceCaptureControlTimeout:(double)duration;

@optional
- (void)DCVoiceCaptureControlTimeUpdate:(double)duration;
@end

@interface DCVoiceCaptureControl : UIView

@property (nonatomic, weak) id<DCVoiceCaptureControlDelegate> delegate;

@property (nonatomic, readonly, copy) NSData *stopRecord;

@property (nonatomic, readonly, assign) double duration;

//客服会话不识别高音质语音消息，需要 RCConversationType 做判断
- (instancetype)initWithFrame:(CGRect)frame conversationType:(DCConversationType)type;

- (void)startRecord;

- (void)cancelRecord;

- (void)showCancelView;

- (void)hideCancelView;

- (void)showViewWithErrorMsg:(NSString *)errorMsg;

- (void)stopTimer;
@end
