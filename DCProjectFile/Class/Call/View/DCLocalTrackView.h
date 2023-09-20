//
//  DCLocalTrackView.h
//  DCProjectFile
//
//  Created  on 2023/7/25.
//

#import "WMDragView.h"

NS_ASSUME_NONNULL_BEGIN

@interface DCLocalTrackView : WMDragView
@property (nonatomic, assign) NSInteger userID;
@property (nonatomic, strong) UIImageView *avatar;

@end

NS_ASSUME_NONNULL_END
