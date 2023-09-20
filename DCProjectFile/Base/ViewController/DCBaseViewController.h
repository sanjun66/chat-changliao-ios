//
//  DCBaseViewController.h
//  DCProjectFile
//
//  Created  on 2023/2/28.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DCBaseViewController : UIViewController
- (void)createLeftBarButtonItemWithString:(NSString *)string;
- (void)rightBarButtonItemWithString:(NSString *)string;

- (void)leftBarButtonAction;
- (void)rightBarButtonAction;

- (void)popGestureEnable:(BOOL)enable;
@end

NS_ASSUME_NONNULL_END
