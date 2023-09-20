//
//  DCRemoteTrackView.h
//  DCProjectFile
//
//  Created  on 2023/7/25.
//

#import "WMDragView.h"

NS_ASSUME_NONNULL_BEGIN

@interface DCRemoteTrackView : QBRTCRemoteVideoView
@property (nonatomic, assign) BOOL dragEnable;
@property (nonatomic, assign) NSInteger userID;
@property (nonatomic, strong) UIImageView *avatar;
@property (nonatomic, strong) UIView *lodingView;

@property (nonatomic, copy) void (^clickRemoteVideoViewBlock)(DCRemoteTrackView *selView);
@end

NS_ASSUME_NONNULL_END
