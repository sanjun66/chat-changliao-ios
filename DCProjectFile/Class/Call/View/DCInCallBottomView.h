//
//  DCInCallBottomView.h
//  DCProjectFile
//
//  Created  on 2023/7/25.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol DCInCallBottomViewDelegate <NSObject>

- (void)botViewClose;
- (void)botViewSwitchCamera:(BOOL)isSel;
- (void)botViewChangeOutputChannel:(BOOL)isSel;
- (void)botViewChangeMicEnable:(BOOL)isSel;
- (void)botViewChangeCameraEnable:(BOOL)isSel;
@end

@interface DCInCallBottomView : UIView
@property (nonatomic, weak) id <DCInCallBottomViewDelegate> delegate;
@property (nonatomic, assign) QBRTCConferenceType conferenceType;

@end

NS_ASSUME_NONNULL_END
