//
//  DCCallMultitudeVC.h
//  DCProjectFile
//
//  Created  on 2023/8/1.
//

#import "DCDragViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface DCCallMultitudeVC : DCDragViewController
@property (strong, nonatomic) QBRTCSession *session;

@property (strong, nonatomic) QBRTCCameraCapture *videoCapture;

@property (strong, nonatomic) NSArray<DCUserInfo*>*members;

@property (copy, nonatomic) NSString *fromUid;

- (instancetype)initWithSession:(QBRTCSession *)session callDirection:(CallDirection)direction;

@end

NS_ASSUME_NONNULL_END
