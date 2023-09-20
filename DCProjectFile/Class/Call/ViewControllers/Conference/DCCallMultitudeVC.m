//
//  DCCallMultitudeVC.m
//  DCProjectFile
//
//  Created  on 2023/8/1.
//

#import "DCCallMultitudeVC.h"
#import "DCLocalTrackView.h"
#import "DCRemoteTrackView.h"


#define kItemW (kScreenWidth/2)
#define kItemH (kItemW*4/3)

@interface DCCallMultitudeVC ()<
DCCallManagerDelegate,
DCInCallBottomViewDelegate,
DCInCallTopViewDelegate,
DCCallWaitingViewDelegate>

@property (nonatomic, strong) UIImageView *backgroundImageView;

@property (assign, nonatomic) CallDirection direction;
@property (strong, nonatomic) DCLocalTrackView *localView;

@property (strong, nonatomic) DCInCallBottomView *botView;
@property (strong, nonatomic) DCInCallTopView *topView;

@property (strong, nonatomic) DCCallWaitingView *waitingView;

@property (strong, nonatomic) DCInCallAudioSmallView *smlView;

@property (nonatomic, assign) CGFloat callDuration;

@property (nonatomic, strong) YYTimer *timer;

@property (nonatomic, strong) NSMutableDictionary <NSNumber* , UIView*>*trackViewDict;
@property (nonatomic, assign) NSInteger mainViewId;
@property (nonatomic, assign) CGFloat bottomViewHeight;

@end

@implementation DCCallMultitudeVC
- (instancetype)initWithSession:(QBRTCSession *)session callDirection:(CallDirection)direction {
    if (self = [super init]) {
        self.session = session;
        self.direction = direction;
        self.bottomViewHeight = 150 + kBottomSafe;
        if (self.session.conferenceType==QBRTCConferenceTypeAudio) {
            self.bottomViewHeight = 90 + kBottomSafe;
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupBackground];
    [[DCCallManager sharedInstance] playSound];
    [DCCallManager sharedInstance].delegate = self;
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    
    if (self.session.conferenceType == QBRTCConferenceTypeVideo) {
        [self rctInit];
    }
    
    [self updateAudioSessionConfiguration:self.session.conferenceType == QBRTCConferenceTypeVideo];

}
//MARK: - 承载画面创建
- (void)createRemoteViews:(NSArray<DCUserInfo*> *)userArray {
    
    [userArray enumerateObjectsUsingBlock:^(DCUserInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.userId isEqualToString:kUser.uid]) {
            [self.view addSubview:self.localView];
            [self.trackViewDict setObject:self.localView forKey:@(kUser.quickblox_id)];
            if (self.session.conferenceType==QBRTCConferenceTypeAudio) {
                self.localView.avatar.hidden = NO;
                [self.localView.avatar sd_setImageWithURL:[NSURL URLWithString:[DCUserManager sharedManager].currentUserInfo.portraitUri]];
            }
        }else {
            QBRTCConnectionState state = [self.session connectionStateForUser:@(obj.quickbloxId)];
            if (state==QBRTCConnectionStateUnknown ||
                state==QBRTCConnectionStateNew ||
                state==QBRTCConnectionStatePending ||
                state==QBRTCConnectionStateConnecting ||
                state==QBRTCConnectionStateChecking ||
                state==QBRTCConnectionStateConnected) {
                DCRemoteTrackView *trackView = [[DCRemoteTrackView alloc]initWithFrame:CGRectZero];
                trackView.dragEnable = NO;
                trackView.userID = obj.quickbloxId;
                trackView.backgroundColor = kBlackColor;
                [self.view addSubview:trackView];
                [self.trackViewDict setObject:trackView forKey:@(obj.quickbloxId)];
                trackView.clickRemoteVideoViewBlock = ^(DCRemoteTrackView * _Nonnull selView) {
//                    [self onTapTrackView:selView];
                };
                trackView.avatar.hidden = NO;
                trackView.lodingView.hidden = state==QBRTCConnectionStateConnected;
                [[DCUserManager sharedManager] getConversationData:DC_ConversationType_PRIVATE targerId:obj.userId completion:^(DCUserInfo * _Nonnull userInfo) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [trackView.avatar sd_setImageWithURL:[NSURL URLWithString:userInfo.portraitUri]];
                    });
                }];
            }
            
        }
    }];
    NSLog(@"哈哈哈===%@",self.trackViewDict);
    [self.view addSubview:self.topView];
    [self.view addSubview:self.botView];
    [self.view addSubview:self.smlView];
    
}


- (void)relayoutRemoteViewFrame {
    
    NSInteger total = self.trackViewDict.count;
    
    CGFloat startPointY = kItemH;
    if (total > 2) {
        startPointY = kTopViewH;
    }
    [self.trackViewDict.allValues enumerateObjectsUsingBlock:^(UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.frame = CGRectMake(kItemW*(idx%2), startPointY + kItemH*(idx/2), kItemW, kItemH);
        if (total==3 && idx==2) {
            obj.frame = CGRectMake(kItemW*(idx%2)+kItemW/2, startPointY + kItemH*(idx/2), kItemW, kItemH);
        }
    }];
    
    self.videoCapture.previewLayer.frame = self.localView.bounds;
}

- (void)onTapTrackView:(UIView *)tapView {
    NSInteger uid ;
    if ([tapView isKindOfClass:[DCRemoteTrackView class]]) {
        uid = ((DCRemoteTrackView *)tapView).userID;
    }else {
        uid = ((DCLocalTrackView *)tapView).userID;
    }
    if (self.mainViewId == uid) {
        self.mainViewId = 0;
        [self relayoutRemoteViewFrame];
        return;
    }
    self.mainViewId = uid;
    
    tapView.frame = CGRectMake(0, kItemW/2, kItemW*2, kItemH*2);
    
    CGFloat itemW = (kScreenWidth/(self.trackViewDict.count-1));
    
    CGFloat startPointX = 0;
    if (self.trackViewDict.count==2) {
        startPointX = kItemH/2;
        itemW = kItemW;
    }
    
    __block NSInteger idx = 0;
    
    
    [self.trackViewDict enumerateKeysAndObjectsUsingBlock:^(NSNumber * _Nonnull key, UIView * _Nonnull obj, BOOL * _Nonnull stop) {
        if (self.mainViewId != key.integerValue) {
            obj.frame = CGRectMake(startPointX + idx * itemW, CGRectGetMaxY(tapView.frame), itemW, itemW);
            idx += 1;
        }
    }];
    self.videoCapture.previewLayer.frame = self.localView.bounds;
}


- (void)onUserLeave:(NSNumber *)userID {

    DCRemoteTrackView *trackView = (DCRemoteTrackView *)[self.trackViewDict objectForKey:userID];
    [trackView removeFromSuperview];
    [self.trackViewDict removeObjectForKey:userID];
    [self relayoutRemoteViewFrame];
}

- (void)setMembers:(NSArray<DCUserInfo *> *)members {
    _members = members;
    
    
    if (self.direction==CallDirectionOutgoing) {
        __block NSString *parms = @"";
        [members enumerateObjectsUsingBlock:^(DCUserInfo *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (idx==members.count-1) {
                parms = [parms stringByAppendingString:[NSString stringWithFormat:@"%@&%ld",obj.userId,obj.quickbloxId]];
            }else {
                parms = [parms stringByAppendingString:[NSString stringWithFormat:@"%@&%ld,",obj.userId,obj.quickbloxId]];
            }
        }];
        [self.session startCall:@{@"isMultitude":@"1" , @"uid":kUser.uid,@"parms":parms,@"callUid":[DCCallManager sharedInstance].callUid}];
        [self createRemoteViews:members];
        [self relayoutRemoteViewFrame];
    }
    if (self.direction == CallDirectionIncoming) {
        [self.view addSubview:self.waitingView];
    }
    
    
}
- (void)closeCall {
    [self.videoCapture stopSession:^{

    }];
    [self.session hangUp:nil];
    [self closeCallPage];
}
/// 关闭通话页面
- (void)closeCallPage {
    [[DCCallManager sharedInstance] stopPlayCallingSound];
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.view.y = kScreenHeight;
    } completion:^(BOOL finished) {
        [self.view removeAllSubviews];
        [self.view removeFromSuperview];
        [self removeFromParentViewController];
        [DCCallManager sharedInstance].isCallBusy = NO;
        [DCCallManager sharedInstance].callUid = nil;
        [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    }];
}
//MARK: - timerAction
- (void)callTimeAction {
    self.callDuration += 1;
    NSString *durationString = [DCTools callDurationFromSeconds:self.callDuration];
    
    self.topView.durationLabel.text = durationString;
    
    if (self.session.conferenceType == QBRTCConferenceTypeAudio) {
        self.smlView.durationLabel.text = durationString;
    }
}

//MARK: - qb
- (void)rctInit {
    QBRTCVideoFormat *videoFormat = [QBRTCVideoFormat defaultFormat];
    self.videoCapture = [[QBRTCCameraCapture alloc] initWithVideoFormat:videoFormat position:AVCaptureDevicePositionFront]; // or AVCaptureDevicePositionBack
    self.videoCapture.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    self.videoCapture.supportedOrientations = UIInterfaceOrientationMaskPortrait;
    self.session.localMediaStream.videoTrack.videoCapture = self.videoCapture;
    self.videoCapture.previewLayer.frame = self.localView.bounds;
    [self.videoCapture startSession:^{
        
    }];
    [self.localView.layer insertSublayer:self.videoCapture.previewLayer atIndex:0];
    
}
- (void)updateAudioSessionConfiguration:(BOOL)hasVideo {
    
    QBRTCAudioSessionConfiguration *configuration = [[QBRTCAudioSessionConfiguration alloc] init];
    configuration.categoryOptions |= AVAudioSessionCategoryOptionDuckOthers;
    
    // adding blutetooth support
    configuration.categoryOptions |= AVAudioSessionCategoryOptionAllowBluetooth;
    configuration.categoryOptions |= AVAudioSessionCategoryOptionAllowBluetoothA2DP;
    
    // adding airplay support
    configuration.categoryOptions |= AVAudioSessionCategoryOptionAllowAirPlay;
    
    if (hasVideo) {
        configuration.mode = AVAudioSessionModeVideoChat;
    }
    [[QBRTCAudioSession instance] setConfiguration:configuration];
}

//MARK: - qbDelegate
- (void)session:(nonnull QBRTCSession *)session acceptedByUser:(nonnull NSNumber *)userID userInfo:(nullable NSDictionary<NSString *,NSString *> *)userInfo {
    if (!_timer && self.direction==CallDirectionOutgoing) {
        [self.timer fire];
    }
}

- (void)session:(nonnull QBRTCSession *)session hungUpByUser:(nonnull NSNumber *)userID userInfo:(nullable NSDictionary<NSString *,NSString *> *)userInfo {
    [self onUserLeave:userID];
    
}

- (void)session:(nonnull __kindof QBRTCBaseSession *)session receivedRemoteAudioTrack:(nonnull QBRTCAudioTrack *)audioTrack fromUser:(nonnull NSNumber *)userID {
    
}

- (void)session:(nonnull __kindof QBRTCBaseSession *)session receivedRemoteVideoTrack:(nonnull QBRTCVideoTrack *)videoTrack fromUser:(nonnull NSNumber *)userID {
    DCRemoteTrackView *trackView = (DCRemoteTrackView *)[self.trackViewDict objectForKey:userID];
    trackView.avatar.hidden = YES;
    [trackView setVideoTrack:videoTrack];
}

- (void)session:(nonnull QBRTCSession *)session rejectedByUser:(nonnull NSNumber *)userID userInfo:(nullable NSDictionary<NSString *,NSString *> *)userInfo {
    [self onUserLeave:userID];
}

- (void)session:(nonnull QBRTCSession *)session userDidNotRespond:(nonnull NSNumber *)userID {
    [self onUserLeave:userID];
}

- (void)sessionDidClose:(nonnull QBRTCSession *)session {
    DCLog(@"通话已结束");
    if (self.trackViewDict.count <= 1) {
        [self reportCallState:5];
    }
    [self closeCall];
}

- (void)session:(__kindof QBRTCBaseSession *)session lostUserWithId:(NSNumber *)userID {
    if ([self.trackViewDict.allKeys containsObject:userID]) {
        [self onUserLeave:userID];
    }
}

- (void)session:(__kindof QBRTCBaseSession *)session didChangeConnectionState:(QBRTCConnectionState)state forUser:(NSNumber *)userID {
    if (state==QBRTCConnectionStateConnected) {
        DCRemoteTrackView *trackView = (DCRemoteTrackView*)[self.trackViewDict objectForKey:userID];
        trackView.lodingView.hidden = YES;
        
        [[DCCallManager sharedInstance]stopPlayCallingSound];
    }
}
//MARK: - subviewDelegate
//botView
- (void)botViewClose {
    [self onUserLeave:@(kUser.quickblox_id)];
    [self closeCall];
}

- (void)botViewSwitchCamera:(BOOL)isSel {
    self.videoCapture.position = isSel?AVCaptureDevicePositionBack:AVCaptureDevicePositionFront;
}

- (void)botViewChangeOutputChannel:(BOOL)isSel {
    
    /* 将对方静音
     QBRTCAudioTrack *remoteAudioTrack = [self.session remoteAudioTrackWithUserID:self.session.opponentsIDs.firstObject];
    remoteAudioTrack.enabled = !isSel;
     */
    
    QBRTCAudioSession *audioSession = [QBRTCAudioSession instance];
    if (!audioSession.isActive) {
        return;
    }
    [audioSession overrideOutputAudioPort:isSel?AVAudioSessionPortOverrideNone:AVAudioSessionPortOverrideSpeaker];
}

- (void)botViewChangeMicEnable:(BOOL)isSel {
    self.session.localMediaStream.audioTrack.enabled = !isSel;
}

- (void)botViewChangeCameraEnable:(BOOL)isSel {
    self.session.localMediaStream.videoTrack.enabled = !isSel;
    if (!self.videoCapture.hasStarted && !isSel) {
        [self.videoCapture startSession:nil];
    }
}

//waitingView
- (void)waitingViewOnAcceptCall {
    [[DCCallManager sharedInstance] stopPlayCallingSound];
    [self.waitingView removeFromSuperview];
    [self.session acceptCall:nil];
    [self createRemoteViews:self.members];
    [self relayoutRemoteViewFrame];
    [self.timer fire];
}

- (void)waitingViewOnRefuseCall {
    [self.session rejectCall:@{@"reason":@"1"}];
    [self closeCall];
}

// topView
- (void)onTopViewSmallWindow {
    [self enterAudioSmall];
    
}
- (void)enterAudioSmall {
    self.topView.hidden = YES;
    self.botView.hidden = YES;
    self.backgroundImageView.hidden = YES;
    [self.trackViewDict.allValues enumerateObjectsUsingBlock:^(UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.hidden = YES;
    }];
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.view.frame = CGRectMake(kScreenWidth-76, kStatusBarHeight+60, 76, 76);
        self.backgroundImageView.frame = self.view.bounds;
        self.smlView.frame = CGRectMake(0, 0, 76, 76);
    } completion:^(BOOL finished) {
        self.dragEnable = YES;
        self.smlView.hidden = NO;
        [UIApplication.sharedApplication.keyWindow.rootViewController.view bringSubviewToFront:self.view];
    }];
}

- (void)existSmallWindow {
    self.smlView.hidden = YES;
    
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.view.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
        self.backgroundImageView.frame = self.view.bounds;
        self.smlView.frame = CGRectMake(0, 0, 76, 76);
    } completion:^(BOOL finished) {
        self.dragEnable = NO;
        self.topView.hidden = NO;
        self.botView.hidden = NO;
        self.backgroundImageView.hidden = NO;
        [self.trackViewDict.allValues enumerateObjectsUsingBlock:^(UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            obj.hidden = NO;
        }];
        [UIApplication.sharedApplication.keyWindow.rootViewController.view bringSubviewToFront:self.view];
    }];
}
//MARK: - setter getter setup
- (void)setupBackground {
    UIImageView *imgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    imgView.contentMode = UIViewContentModeScaleAspectFill;
    imgView.clipsToBounds = YES;
    [imgView sd_setImageWithURL:[NSURL URLWithString:[DCUserManager sharedManager].currentUserInfo.portraitUri]];
    [self.view addSubview:imgView];
    
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVisualEffectView *visualEffectView = [[UIVisualEffectView alloc]initWithEffect:blurEffect];
    visualEffectView.frame = imgView.bounds;
    [imgView addSubview:visualEffectView];
    
    self.backgroundImageView = imgView;
}

- (DCLocalTrackView *)localView {
    if (!_localView) {
        _localView = [[DCLocalTrackView alloc]initWithFrame:CGRectZero];
        _localView.userID = kUser.quickblox_id;
        _localView.dragEnable = NO;
        
        __weak typeof(self) weakSelf = self;
        _localView.clickDragViewBlock = ^(WMDragView *dragView) {
            __strong typeof(weakSelf)self = weakSelf;
//            [self onTapTrackView:dragView];
        };
    }
    return _localView;
}


- (NSMutableDictionary *)trackViewDict {
    if (!_trackViewDict) {
        _trackViewDict = [NSMutableDictionary dictionary];
    }
    return _trackViewDict;
}

- (DCInCallBottomView *)botView {
    if (!_botView) {
        _botView = [DCInCallBottomView xib];
        _botView.frame = CGRectMake(0, kScreenHeight-self.bottomViewHeight, kScreenWidth, self.bottomViewHeight);
        _botView.delegate = self;
        _botView.conferenceType = self.session.conferenceType;
    }
    return _botView;
}

- (DCInCallTopView *)topView {
    if (!_topView) {
        _topView = [[DCInCallTopView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, kTopViewH)];
        _topView.delegate = self;
    }
    return _topView;
}

- (DCCallWaitingView *)waitingView {
    if (!_waitingView) {
        _waitingView = [DCCallWaitingView xib];
        _waitingView.isMultit = YES;
        _waitingView.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
        _waitingView.delegate = self;
        _waitingView.inviteMembers = self.members;
        _waitingView.fromUid = self.fromUid;
        
    }
    
    return _waitingView;
}


- (DCInCallAudioSmallView *)smlView {
    if (!_smlView) {
        _smlView = [[DCInCallAudioSmallView alloc]initWithFrame:CGRectMake(0, 0, 76, 76)];
        _smlView.userInteractionEnabled = NO;
        _smlView.hidden = YES;
    }
    return _smlView;
}

- (YYTimer *)timer {
    if (!_timer) {
        _timer = [YYTimer timerWithTimeInterval:1 target:self selector:@selector(callTimeAction) repeats:YES];
        
    }
    return _timer;
}

@end
