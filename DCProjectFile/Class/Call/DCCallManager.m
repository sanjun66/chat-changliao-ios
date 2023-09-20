//
//  DCCallManager.m
//  DCProjectFile
//
//  Created  on 2023/7/21.
//

#import "DCCallManager.h"
#import "CallPermissions.h"
#import "DCCallViewController.h"
#import "DCCallMultitudeVC.h"
#import <AVFoundation/AVFoundation.h>
@interface DCCallManager ()<QBRTCClientDelegate,QBChatDelegate>
@property (nonatomic, assign) BOOL connecting;
@property (nonatomic, strong) AVAudioPlayer *audioPlayer;
@end

@implementation DCCallManager

- (void)dealloc {
    [QBChat.instance removeDelegate:self];
}
- (instancetype)init {
    if (self = [super init]) {
        [QBChat.instance addDelegate:self];
        NSString *soundPath = [[NSBundle mainBundle] pathForResource:@"ringtone" ofType:@"wav"];
        self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL URLWithString:soundPath] error: nil];
        self.audioPlayer.volume = 1.0;
        self.audioPlayer.numberOfLoops = NSIntegerMax;
    }
    return self;
}

- (void)makeCall:(QBRTCConferenceType)conferenceType toUsers:(NSArray<DCUserInfo*>*)memberes isGroup:(BOOL)isGroup {
    [CallPermissions checkPermissionsWithConferenceType:conferenceType presentingViewController:[DCTools topViewController] completion:^(BOOL granted) {
        if (!granted) {
            return;
        }
        if (self.isCallBusy) {
            return;
        }
//        if ([self establish]) {
            NSMutableDictionary<NSNumber *, NSString *>*callMembers = @{}.mutableCopy;
            [memberes enumerateObjectsUsingBlock:^(DCUserInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                callMembers[@(obj.quickbloxId)] = obj.userId;
            }];
            
            QBRTCSession *session = [QBRTCClient.instance createNewSessionWithOpponents:callMembers.allKeys
                                             withConferenceType:conferenceType];
//            if (session) {
                self.isCallBusy = YES;
                if (!isGroup) {
                    DCCallViewController *callVc = [self presentCallViewController:session callDirection:CallDirectionOutgoing];
                    callVc.members = memberes;
                }else {
                    DCCallMultitudeVC *callVc = [self presentMultieCallViewController:session callDirection:CallDirectionOutgoing];
                    NSMutableArray *modelAarray = [NSMutableArray arrayWithArray:memberes];
                    [modelAarray addObject:[DCUserManager sharedManager].currentUserInfo];
                    callVc.members = modelAarray.copy;
                    
                }
                
//            }
//        }else {
//            [MBProgressHUD showTips:@"通话服务器未连接"];
//        }
    }];
}

- (BOOL)established {
    BOOL connected = NO;
    if (QBSession.currentSession.tokenHasExpired == NO && QBChat.instance.isConnected) {
        connected = YES;
    }
    return connected;
}
- (BOOL)establish {
    if (self.connecting) {
        [MBProgressHUD showTips:@"通话服务器连接中"];
        return NO;
    }
    
    if (!self.established) {
        self.connecting = YES;
        [self disconnect];
        [self singupQbChat];
        return NO;
    }
    return YES;
}


//MARK: - Internal
- (void)disconnect {
    if (QBChat.instance.isConnected == NO) {
        return;
    }
    [QBChat.instance disconnectWithCompletionBlock:nil];
}


- (void)initializeRTC {
    [Quickblox initWithApplicationId:kQBAppId
                             authKey:kQBAuthKey
                          authSecret:kQBAuthSecret
                          accountKey:kQBAccountKey
    ];
    
    [QBSettings setLogLevel:QBLogLevelDebug];
    [QBSettings disableFileLogging];
    [QBSettings disableXMPPLogging];
    [QBSettings setCarbonsEnabled: NO];
    [QBSettings setAutoReconnectEnabled:YES];
    
    QBRTCConfig.answerTimeInterval = 30.0f;
    QBRTCConfig.dialingTimeInterval = 5.0f;
    QBRTCConfig.statsReportTimeInterval = 3.0f;
    
    [QBRTCConfig setMediaStreamConfiguration:[QBRTCMediaStreamConfiguration defaultConfiguration]];
    [QBRTCConfig setLogLevel:QBRTCLogLevelVerboseWithWebRTC];
    [QBRTCClient initializeRTC];
    
    [[QBRTCClient instance] addDelegate:self];
    
}


- (void)singupQbChat {
    [QBRequest logInWithUserLogin:kUser.quickblox_login password:kUser.quickblox_pwd successBlock:^(QBResponse * _Nonnull response, QBUUser * _Nonnull tUser) {
        [QBChat.instance connectWithUserID:kUser.quickblox_id password:kUser.quickblox_pwd completion:^(NSError * _Nullable error) {
            if (error) {
                [MBProgressHUD showTips:@"视频服务器连接失败"];
            }
            self.connecting = NO;
        }];
    } errorBlock:^(QBResponse * _Nonnull response) {
        self.connecting = NO;
//        [MBProgressHUD showTips:@"视频服务器连接失败"];
    }];
}


- (DCCallViewController *)presentCallViewController:(QBRTCSession *)session callDirection:(CallDirection)direction {
    DCCallViewController *callVc = [[DCCallViewController alloc]initWithSession:session callDirection:direction];
    callVc.view.frame = CGRectMake(0, kScreenHeight, kScreenWidth, kScreenHeight);
    DCTabBarController *tabbar = (DCTabBarController*)UIApplication.sharedApplication.keyWindow.rootViewController;
    [tabbar addChildViewController:callVc];
    [tabbar.view addSubview:callVc.view];
    [tabbar.view bringSubviewToFront:callVc.view];
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        callVc.view.y = 0;
    } completion:nil];
    
    return callVc;
}

- (DCCallMultitudeVC *)presentMultieCallViewController:(QBRTCSession *)session callDirection:(CallDirection)direction {
    DCCallMultitudeVC *callVc = [[DCCallMultitudeVC alloc]initWithSession:session callDirection:direction];
    callVc.view.frame = CGRectMake(0, kScreenHeight, kScreenWidth, kScreenHeight);
    DCTabBarController *tabbar = (DCTabBarController*)UIApplication.sharedApplication.keyWindow.rootViewController;
    [tabbar addChildViewController:callVc];
    [tabbar.view addSubview:callVc.view];
    [tabbar.view bringSubviewToFront:callVc.view];
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        callVc.view.y = 0;
    } completion:nil];
    
    return callVc;
}

+ (instancetype)sharedInstance {
    static DCCallManager* instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}


- (void)playSound {
    [self.audioPlayer stop];
    [self.audioPlayer prepareToPlay];
    [self.audioPlayer play];
}

- (void)stopPlayCallingSound {
    [self.audioPlayer stop];
}


//MARK: - RCT DELEGATE
/**
 *  Called when someone started a new session with you.
 *
 *  @param session  QBRTCSession instance
 *  @param userInfo The user information dictionary for the new session. May be nil.
 */
- (void)didReceiveNewSession:(QBRTCSession *)session userInfo:(nullable NSDictionary <NSString *, NSString *> *)userInfo {
    if (self.isCallBusy) {
        [session rejectCall:@{@"reason":@"2"}];
        [self reportCallState:[userInfo objectForKey:@"callUid"]];
        [DCCallManager sharedInstance].callUid = nil;
        return;
    }
    self.isCallBusy = YES;
    [DCCallManager sharedInstance].callUid = [userInfo objectForKey:@"callUid"];
    if ([[userInfo objectForKey:@"isMultitude"] isEqualToString:@"0"]) {
        DCCallViewController *callVc = [self presentCallViewController:session callDirection:CallDirectionIncoming];
        callVc.fromUid = [NSString stringWithFormat:@"%@",userInfo[@"uid"]];
    }else {
        DCCallMultitudeVC *callVc = [self presentMultieCallViewController:session callDirection:CallDirectionIncoming];
        NSMutableArray *userModels = [NSMutableArray array];
        NSString *uids = [NSString stringWithFormat:@"%@",userInfo[@"parms"]];
        NSArray *infoStrArr = [uids componentsSeparatedByString:@","];
        for (NSString *temp in infoStrArr) {
            NSArray *arr = [temp componentsSeparatedByString:@"&"];
            NSString *uid = arr.firstObject;
            NSString *qbid = arr.lastObject;
            DCUserInfo *user = [[DCUserInfo alloc]init];
            user.userId = uid;
            user.quickbloxId = qbid.integerValue;
            [userModels addObject:user];
        }
        callVc.fromUid = [NSString stringWithFormat:@"%@",userInfo[@"uid"]];
        callVc.members = userModels.copy;
        
    }
}
- (void)reportCallState:(NSString *)callUid {
    [[DCRequestManager sharedManager] requestWithMethod:@"POST" url:@"api/talkState" parameters:@{@"id":callUid , @"state":@(7)} success:^(id  _Nullable result) {
            
        } failure:^(NSError * _Nonnull error) {
            
        }];
}
/**
 *  Called in case when user did not respond to your call within timeout.
 *
 *  @param userID ID of user
 *
 *  @remark use +[QBRTCConfig setAnswerTimeInterval:value] to set answer time interval
 *  default value: 45 seconds
 */
- (void)session:(QBRTCSession *)session userDidNotRespond:(NSNumber *)userID {
    if ([self.delegate respondsToSelector:@selector(session:userDidNotRespond:)]) {
        [self.delegate session:session userDidNotRespond:userID];
    }
}

/**
 *  Called in case when user rejected you call.
 *
 *  @param userID ID of user
 *  @param userInfo The user information dictionary for the reject call. May be nil
 */
- (void)session:(QBRTCSession *)session rejectedByUser:(NSNumber *)userID userInfo:(nullable NSDictionary <NSString *, NSString *> *)userInfo {
    if ([self.delegate respondsToSelector:@selector(session:rejectedByUser:userInfo:)]) {
        [self.delegate session:session rejectedByUser:userID userInfo:userInfo];
    }
}

/**
 *  Called in case when user accepted your call.
 *
 *  @param userID ID of user
 */
- (void)session:(QBRTCSession *)session acceptedByUser:(NSNumber *)userID userInfo:(nullable NSDictionary <NSString *, NSString *> *)userInfo {
    if ([self.delegate respondsToSelector:@selector(session:acceptedByUser:userInfo:)]) {
        [self.delegate session:session acceptedByUser:userID userInfo:userInfo];
    }
}

/**
 *  Called when user hung up.
 *
 *  @param session QBRTCSession instance
 *  @param userID  ID of user
 *  @param userInfo The user information dictionary for the hung up. May be nil.
 */
- (void)session:(QBRTCSession *)session hungUpByUser:(NSNumber *)userID userInfo:(nullable NSDictionary <NSString *, NSString *> *)userInfo {
    if ([self.delegate respondsToSelector:@selector(session:hungUpByUser:userInfo:)]) {
        [self.delegate session:session hungUpByUser:userID userInfo:userInfo];
    }
}

/**
 *  Called when session is closed.
 *
 *  @param session QBRTCSession instance
 */
- (void)sessionDidClose:(QBRTCSession *)session {
    if ([self.delegate respondsToSelector:@selector(sessionDidClose:)]) {
        [self.delegate sessionDidClose:session];
    }
}

//MARK: - baseDelegate

/**
 *  Called by timeout with updated stats report for user ID.
 *
 *  @param session QBRTCSession instance
 *  @param report  QBRTCStatsReport instance
 *  @param userID  user ID
 *
 *  @remark Configure time interval with [QBRTCConfig setStatsReportTimeInterval:timeInterval].
 */
- (void)session:(__kindof QBRTCBaseSession *)session updatedStatsReport:(QBRTCStatsReport *)report forUserID:(NSNumber *)userID {
    
}

/**
 *  Called when session state has been changed.
 *
 *  @param session QBRTCSession instance
 *  @param state session state
 *
 *  @discussion Use this to track a session state. As SDK 2.3 introduced states for session, you can now manage your own states based on this.
 */
- (void)session:(__kindof QBRTCBaseSession *)session didChangeState:(QBRTCSessionState)state {
    
}

/**
 *  Called when received remote audio track from user.
 *
 *  @param audioTrack QBRTCAudioTrack instance
 *  @param userID     ID of user
 */
- (void)session:(__kindof QBRTCBaseSession *)session receivedRemoteAudioTrack:(QBRTCAudioTrack *)audioTrack fromUser:(NSNumber *)userID {
    if ([self.delegate respondsToSelector:@selector(session:receivedRemoteAudioTrack:fromUser:)]) {
        [self.delegate session:session receivedRemoteAudioTrack:audioTrack fromUser:userID];
    }
}

/**
 *  Called when received remote video track from user.
 *
 *  @param videoTrack QBRTCVideoTrack instance
 *  @param userID     ID of user
 */
- (void)session:(__kindof QBRTCBaseSession *)session receivedRemoteVideoTrack:(QBRTCVideoTrack *)videoTrack fromUser:(NSNumber *)userID {
    if ([self.delegate respondsToSelector:@selector(session:receivedRemoteVideoTrack:fromUser:)]) {
        [self.delegate session:session receivedRemoteVideoTrack:videoTrack fromUser:userID];
    }
}

/**
 *  Called when connection is closed for user.
 *
 *  @param session QBRTCSession instance
 *  @param userID  ID of user
 */
- (void)session:(__kindof QBRTCBaseSession *)session connectionClosedForUser:(NSNumber *)userID {
    
}

/**
 *  Called when connection is initiated with user.
 *
 *  @param session QBRTCSession instance
 *  @param userID  ID of user
 */
- (void)session:(__kindof QBRTCBaseSession *)session startedConnectingToUser:(NSNumber *)userID {
    
}

/**
 *  Called when connection is established with user.
 *
 *  @param session QBRTCSession instance
 *  @param userID  ID of user
 */
- (void)session:(__kindof QBRTCBaseSession *)session connectedToUser:(NSNumber *)userID {
    
}

/**
 *  Called when disconnected from user.
 *
 *  @param session QBRTCSession instance
 *  @param userID  ID of user
 */
- (void)session:(__kindof QBRTCBaseSession *)session disconnectedFromUser:(NSNumber *)userID {
    if ([self.delegate respondsToSelector:@selector(session:lostUserWithId:)]) {
        [self.delegate session:session lostUserWithId:userID];
    }
}

/**
 *  Called when connection failed with user.
 *
 *  @param session QBRTCSession instance
 *  @param userID  ID of user
 */
- (void)session:(__kindof QBRTCBaseSession *)session connectionFailedForUser:(NSNumber *)userID {
    
}

/**
 *  Called when session connection state changed for a specific user.
 *
 *  @param session QBRTCSession instance
 *  @param state   state - @see QBRTCConnectionState
 *  @param userID  ID of user
 */
- (void)session:(__kindof QBRTCBaseSession *)session didChangeConnectionState:(QBRTCConnectionState)state forUser:(NSNumber *)userID {
    if ([self.delegate respondsToSelector:@selector(session:didChangeConnectionState:forUser:)]) {
        [self.delegate session:session didChangeConnectionState:state forUser:userID];
    }
}

/**
 * Called when session reconnection state changed for a specific user. Not called for the conference.
 *
 * @param session QBRTCSession instance
 * @param state  state - @see QBRTCReconnectionState
 * @param userID ID of user
 */
- (void)session:(__kindof QBRTCBaseSession *)session didChangeRconnectionState:(QBRTCReconnectionState)state forUser:(NSNumber *)userID {
    
}
@end
