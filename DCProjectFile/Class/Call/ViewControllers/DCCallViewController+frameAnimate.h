//
//  DCCallViewController+frameAnimate.h
//  DCProjectFile
//
//  Created  on 2023/7/26.
//

#import "DCCallViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface DCCallViewController (frameAnimate)
/// 进入小窗
- (void)enterSmallWindow;
/// 进入语音小窗
- (void)enterAudioSmall;
/// 隐藏顶底view
- (void)hideSubview;
/// 显示顶底view
- (void)showSubview;
/// 本地画面变大
- (void)localViewToMain:(NSInteger)selUid;
/// 远层画面变大
- (void)remoteViewToMain:(NSInteger)selUid;
/// 关闭通话页面
- (void)closeCallPage;
@end

NS_ASSUME_NONNULL_END
