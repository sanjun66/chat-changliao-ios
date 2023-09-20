//
//  DCCallViewController.h
//  DCProjectFile
//
//  Created  on 2023/7/25.
//

#import "DCDragViewController.h"

#import "DCCallWaitingView.h"
#import "DCRemoteTrackView.h"
#import "DCLocalTrackView.h"
#import "DCInCallBottomView.h"
#import "DCInCallTopView.h"
#import "DCInCallAudioSmallView.h"

#define kTopViewH (44 + kStatusBarHeight)

NS_ASSUME_NONNULL_BEGIN

@interface DCCallViewController : DCDragViewController
@property (strong, nonatomic) QBRTCSession *session;

@property (strong, nonatomic) QBRTCCameraCapture *videoCapture;

@property (strong, nonatomic) NSArray<DCUserInfo*>*members;
@property (copy, nonatomic) NSString *fromUid;

@property (strong, nonatomic) DCCallWaitingView *waitingView;

@property (strong, nonatomic) DCLocalTrackView *localView;
@property (strong, nonatomic) DCRemoteTrackView *remoteView;

@property (strong, nonatomic) DCInCallBottomView *botView;
@property (strong, nonatomic) DCInCallTopView *topView;

@property (strong, nonatomic) DCInCallAudioSmallView *smlView;

@property (assign, nonatomic) NSUInteger mainViewID;

@property (nonatomic, assign) BOOL isShowing;

@property (nonatomic, assign) CGFloat bottomViewHeight;

- (instancetype)initWithSession:(QBRTCSession *)session callDirection:(CallDirection)direction;

@end

NS_ASSUME_NONNULL_END
