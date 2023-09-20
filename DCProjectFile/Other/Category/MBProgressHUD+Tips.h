
#import "MBProgressHUD.h"

NS_ASSUME_NONNULL_BEGIN

@interface MBProgressHUD (Tips)

+ (void)showTips:(NSString *)tips;
+ (void)showTips:(NSString *)tips dely:(NSTimeInterval)time;
+ (void)showInView:(UIView *)view tips:(NSString *)tips;

+ (MBProgressHUD *)showActivity;
+ (MBProgressHUD *)showActivityWithMessage:(NSString *)msg;
+ (void)hideActivity;

@end

NS_ASSUME_NONNULL_END
