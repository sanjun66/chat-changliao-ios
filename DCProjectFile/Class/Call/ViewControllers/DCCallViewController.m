//
//  DCCallViewController.m
//  DCProjectFile
//
//  Created  on 2023/7/25.
//

#import "DCCallViewController.h"


#import "DCCallViewController+frameAnimate.h"

@interface DCCallViewController ()<

DCCallManagerDelegate,
DCInCallBottomViewDelegate,
DCInCallTopViewDelegate,
DCCallWaitingViewDelegate,
QBRTCRemoteVideoViewDelegate

>

@property (assign, nonatomic) CallDirection direction;

@property (nonatomic, assign) CGFloat callDuration;

@property (nonatomic, strong) YYTimer *timer;

@end

@implementation DCCallViewController
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
    [DCCallManager sharedInstance].delegate = self;
    [[DCCallManager sharedInstance] playSound];
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    self.view.backgroundColor = UIColor.blackColor;
    
    self.mainViewID = kUser.quickblox_id;
    
    if (self.session.conferenceType == QBRTCConferenceTypeVideo) {
        [self.view addSubview:self.localView];
        [self.view addSubview:self.remoteView];
        [self rctInit];
    }else {
        [self.view addSubview:self.smlView];
    }

    [self.view addSubview:self.botView];
    [self.view addSubview:self.topView];
    
    [self updateAudioSessionConfiguration:self.session.conferenceType == QBRTCConferenceTypeVideo];

    if (self.direction == CallDirectionOutgoing) {
        [self.session startCall:@{@"uid":kUser.uid,@"isMultitude":@"0",@"callUid":[DCCallManager sharedInstance].callUid}];
    }
    [QBRTCAudioSession instance].useManualAudio = YES;
    [[QBRTCAudioSession instance] setActive:YES];
    
    [QBRTCAudioSession instance].audioEnabled = YES;
    [self.view addSubview:self.waitingView];
    
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


- (void)setMembers:(NSArray<DCUserInfo *> *)members {
    _members = members;
    self.waitingView.members = members;
}

- (void)setFromUid:(NSString *)fromUid {
    _fromUid = fromUid;
    self.waitingView.fromUid = fromUid;
}

- (void)rctInit {
    
    QBRTCVideoFormat *videoFormat = [QBRTCVideoFormat videoFormatWithWidth:960
                                                                    height:540
                                                                 frameRate:30
                                                               pixelFormat:QBRTCPixelFormat420f];
//    QBRTCVideoFormat *videoFormat = [QBRTCVideoFormat defaultFormat];
    self.videoCapture = [[QBRTCCameraCapture alloc] initWithVideoFormat:videoFormat position:AVCaptureDevicePositionFront]; // or AVCaptureDevicePositionBack
    self.videoCapture.previewLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    self.videoCapture.supportedOrientations = UIInterfaceOrientationMaskPortrait;
    self.session.localMediaStream.videoTrack.videoCapture = self.videoCapture;
    self.videoCapture.previewLayer.frame = self.view.bounds;
    [self.videoCapture startSession:^{
        
    }];
    [self.localView.layer insertSublayer:self.videoCapture.previewLayer atIndex:0];
    
}

//MARK: - Action
- (void)closeCall {
    [[DCCallManager sharedInstance] stopPlayCallingSound];
    [self.videoCapture stopSession:^{

    }];
    [self.session hangUp:nil];
    [self closeCallPage];
}

- (void)acceptCall {
    [[DCCallManager sharedInstance] stopPlayCallingSound];
    [self.session acceptCall:nil];
    [self.timer fire];
    [self showSubview];
}

- (void)refuseCall {
    [self.session rejectCall:@{@"reason":@"1"}];
    [self closeCall];
}


- (void)controlCallSubview {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideSubview) object:nil];
    if (self.isShowing) {
        [self hideSubview];
    }else {
        [self showSubview];
    }
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

//MARK: - delegate
- (void)session:(QBRTCSession *)session userDidNotRespond:(NSNumber *)userID {
    [MBProgressHUD showTips:@"对方无应答"];
    [self reportCallState:3];
    [self closeCall];
}

- (void) session:(QBRTCSession *)session acceptedByUser:(NSNumber *)userID userInfo:(NSDictionary<NSString *,NSString *> *)userInfo {
    if (!_timer && self.direction==CallDirectionOutgoing) {
        [self.timer fire];
        if (self.session.conferenceType == QBRTCConferenceTypeVideo) {
            [self.waitingView removeFromSuperview];
        }else {
            [self.view sendSubviewToBack:self.waitingView];
            [self.waitingView hideSubviews];
        }
        
        [self showSubview];
        
    }
}

- (void)session:(QBRTCSession *)session rejectedByUser:(NSNumber *)userID userInfo:(nullable NSDictionary <NSString *, NSString *> *)userInfo {
    int reason = [userInfo[@"reason"] intValue];
    if (reason==1) {
        [MBProgressHUD showTips:@"对方拒绝"];
    }else if (reason==2) {
        [MBProgressHUD showTips:@"对方正忙"];
    }
}
- (void)session:(QBRTCSession *)session hungUpByUser:(NSNumber *)userID userInfo:(nullable NSDictionary <NSString *, NSString *> *)userInfo {
    
}
- (void)sessionDidClose:(QBRTCSession *)session {
    [self closeCall];
}


- (void)session:(__kindof QBRTCBaseSession *)session receivedRemoteAudioTrack:(QBRTCAudioTrack *)audioTrack fromUser:(NSNumber *)userID {
    
    
}
- (void)session:(__kindof QBRTCBaseSession *)session receivedRemoteVideoTrack:(QBRTCVideoTrack *)videoTrack fromUser:(NSNumber *)userID {
    NSLog(@"对方ID==%@",userID);
    self.remoteView.userID = userID.integerValue;
    self.remoteView.hidden = NO;
//    self.remoteView.videoGravity = AVLayerVideoGravityResizeAspect;
    [self.remoteView setVideoTrack:videoTrack];
}

- (void)session:(__kindof QBRTCBaseSession *)session lostUserWithId:(NSNumber *)userID {
//    [MBProgressHUD showTips:@"对方失去连接"];
//    [self closeCall];
//    [self reportCallState:6];
}

- (void)session:(__kindof QBRTCBaseSession *)session didChangeConnectionState:(QBRTCConnectionState)state forUser:(NSNumber *)userID {
    if (state==QBRTCConnectionStateConnected) {
        [[DCCallManager sharedInstance]stopPlayCallingSound];
    }
}
//MARK: - subview delegate

//botView
- (void)botViewClose {
    [self reportCallState:5];
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
    NSLog(@"currentUserID=%@ , initiatorID=%@",self.session.currentUserID,self.session.initiatorID);
    
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

// topView
- (void)onTopViewSmallWindow {
    if (self.session.conferenceType==QBRTCConferenceTypeVideo) {
        [self enterSmallWindow];
    }else {
        [self enterAudioSmall];
    }
}




//waitingView
- (void)waitingViewOnAcceptCall {
    if (self.session.conferenceType == QBRTCConferenceTypeVideo) {
        [self.waitingView removeFromSuperview];
    }else {
        [self.view sendSubviewToBack:self.waitingView];
        [self.waitingView hideSubviews];
    }
    [self acceptCall];
    [self reportCallState:4];
}

- (void)waitingViewOnRefuseCall {
    [self refuseCall];
    [self closeCall];
    [self reportCallState:2];
}

- (void)waitingViewOnCancelCall {
    [self closeCall];
    [self reportCallState:1];
}

- (void)waitingViewOnTapControll {
    [self controlCallSubview];
}
- (void)videoView:(QBRTCRemoteVideoView *)videoView didChangeVideoSize:(CGSize)size {
    
}

//MARK: - setter && getter

- (DCLocalTrackView *)localView {
    if (!_localView) {
        _localView = [[DCLocalTrackView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
        _localView.freeRect = CGRectMake(10, kStatusBarHeight, kScreenWidth-20, kScreenHeight-kStatusBarHeight-kBottomSafe);
        _localView.userID = kUser.quickblox_id;
        _localView.backgroundColor = UIColor.blackColor;
        _localView.dragEnable = NO;
        _localView.isKeepBounds = YES;
        
        __weak typeof(self) weakSelf = self;
        _localView.clickDragViewBlock = ^(WMDragView *dragView) {
            __strong typeof(weakSelf)self = weakSelf;
            NSInteger selUid = ((DCLocalTrackView*)dragView).userID;
            if (self.mainViewID==selUid) {
                [self controlCallSubview];
            }else {
                [self localViewToMain:selUid];
            }
            
        };
    }
    return _localView;
}


- (DCRemoteTrackView *)remoteView {
    if (!_remoteView) {
        _remoteView = [[DCRemoteTrackView alloc]initWithFrame:CGRectMake(kScreenWidth-93, kStatusBarHeight+60, 93, 165)];
        _remoteView.hidden = YES;
        _remoteView.dragEnable = YES;
        _remoteView.delegate = self;
        
        __weak typeof(self) weakSelf = self;
        _remoteView.clickRemoteVideoViewBlock = ^(DCRemoteTrackView * _Nonnull selView) {
            __strong typeof(weakSelf)self = weakSelf;
            if (self.mainViewID==selView.userID) {
                [self controlCallSubview];
            }else {
                [self remoteViewToMain:selView.userID];
            }
        };
    }
    return _remoteView;
}


- (DCCallWaitingView *)waitingView {
    if (!_waitingView) {
        _waitingView = [DCCallWaitingView xib];
        _waitingView.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
        _waitingView.delegate = self;
        _waitingView.conferenceType = self.session.conferenceType;
        _waitingView.members = self.members;
        _waitingView.fromUid = self.fromUid;
        
    }
    
    return _waitingView;
}

- (DCInCallBottomView *)botView {
    if (!_botView) {
        _botView = [DCInCallBottomView xib];
        _botView.frame = CGRectMake(0, kScreenHeight, kScreenWidth, self.bottomViewHeight);
        _botView.delegate = self;
        _botView.conferenceType = self.session.conferenceType;
    }
    return _botView;
}

- (DCInCallTopView *)topView {
    if (!_topView) {
        _topView = [[DCInCallTopView alloc]initWithFrame:CGRectMake(0, -kTopViewH, kScreenWidth, kTopViewH)];
        _topView.delegate = self;
    }
    return _topView;
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
