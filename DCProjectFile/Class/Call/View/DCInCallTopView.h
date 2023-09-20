//
//  DCInCallTopView.h
//  DCProjectFile
//
//  Created  on 2023/7/25.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol DCInCallTopViewDelegate <NSObject>

- (void)onTopViewSmallWindow;

@end
@interface DCInCallTopView : UIView
@property (strong, nonatomic) UILabel *durationLabel;
@property (nonatomic, weak) id <DCInCallTopViewDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
