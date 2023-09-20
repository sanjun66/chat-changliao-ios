//
//  DCDragViewController.h
//  DCProjectFile
//
//  Created  on 2023/7/24.
//

#import "DCBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface DCDragViewController : DCBaseViewController
@property (nonatomic, assign) BOOL dragEnable;
- (void)existSmallWindow;
- (void)reportCallState:(NSInteger)state;
@end

NS_ASSUME_NONNULL_END
