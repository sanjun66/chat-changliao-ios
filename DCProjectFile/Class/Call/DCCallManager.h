//
//  DCCallManager.h
//  DCProjectFile
//
//  Created  on 2023/7/21.
//

#import <Foundation/Foundation.h>
#import <Quickblox/Quickblox.h>
#import <QuickbloxWebRTC/QuickbloxWebRTC.h>
#import "DCCallViewController.h"

NS_ASSUME_NONNULL_BEGIN

@protocol DCCallManagerDelegate <NSObject>

- (void)session:(QBRTCSession *)session userDidNotRespond:(NSNumber *)userID;

- (void)session:(QBRTCSession *)session acceptedByUser:(NSNumber *)userID userInfo:(nullable NSDictionary <NSString *, NSString *> *)userInfo;

- (void)session:(QBRTCSession *)session rejectedByUser:(NSNumber *)userID userInfo:(nullable NSDictionary <NSString *, NSString *> *)userInfo;

- (void)session:(QBRTCSession *)session hungUpByUser:(NSNumber *)userID userInfo:(nullable NSDictionary <NSString *, NSString *> *)userInfo;

- (void)sessionDidClose:(QBRTCSession *)session;


- (void)session:(__kindof QBRTCBaseSession *)session receivedRemoteAudioTrack:(QBRTCAudioTrack *)audioTrack fromUser:(NSNumber *)userID;
- (void)session:(__kindof QBRTCBaseSession *)session receivedRemoteVideoTrack:(QBRTCVideoTrack *)videoTrack fromUser:(NSNumber *)userID;

- (void)session:(__kindof QBRTCBaseSession *)session lostUserWithId:(NSNumber *)userID;
- (void)session:(__kindof QBRTCBaseSession *)session didChangeConnectionState:(QBRTCConnectionState)state forUser:(NSNumber *)userID;

@end

@interface DCCallManager : NSObject
@property (nonatomic, weak) id <DCCallManagerDelegate> delegate;
@property (nonatomic, copy, nullable) NSString *callUid;
@property (nonatomic, assign) BOOL isCallBusy;
- (void)initializeRTC;
- (void)singupQbChat;
- (void)makeCall:(QBRTCConferenceType)conferenceType toUsers:(NSArray<DCUserInfo*>*)memberes isGroup:(BOOL)isGroup;

- (DCCallViewController *)presentCallViewController:(QBRTCSession *)session callDirection:(CallDirection)direction;

- (void)playSound;
- (void)stopPlayCallingSound;
+ (instancetype)sharedInstance;
@end

NS_ASSUME_NONNULL_END
