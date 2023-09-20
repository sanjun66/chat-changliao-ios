

#import "MBProgressHUD+Tips.h"

@implementation MBProgressHUD (Tips)

+ (void)showTips:(NSString *)tips {
    if ([NSThread isMainThread]) {
        [self showTips:tips dely:1];
    }else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self showTips:tips dely:1];
        });
    }
    
}

+ (void)showTips:(NSString *)tips dely:(NSTimeInterval)time {
    // 快速显示一个提示信息
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    hud.userInteractionEnabled = NO;
    hud.detailsLabel.text = tips;
    hud.detailsLabel.font = [UIFont systemFontOfSize:15];
    hud.contentColor = UIColor.whiteColor;
    hud.bezelView.color = [[UIColor blackColor] colorWithAlphaComponent:0.8];
    hud.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
    // 再设置模式
    hud.mode = MBProgressHUDModeText;
    // 隐藏时候从父控件中移除
    [hud hideAnimated:YES afterDelay:time];
}


+ (void)showInView:(UIView *)view tips:(NSString *)tips{
    // 快速显示一个提示信息
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.userInteractionEnabled = NO;
    hud.detailsLabel.text = tips;
    hud.detailsLabel.font = [UIFont systemFontOfSize:15];
    hud.contentColor = UIColor.whiteColor;
    hud.bezelView.color = [[UIColor blackColor] colorWithAlphaComponent:0.8];
    hud.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
    // 再设置模式
    hud.mode = MBProgressHUDModeText;
    // 隐藏时候从父控件中移除
    [hud hideAnimated:YES afterDelay:1];
}

+ (MBProgressHUD *)showActivity {
    return [self showActivityWithMessage:@""];
}
+ (MBProgressHUD *)showActivityWithMessage:(NSString *)msg {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    hud.userInteractionEnabled = YES;
    hud.label.text = msg;
    hud.contentColor = UIColor.whiteColor;
    hud.label.font = [UIFont systemFontOfSize:14];
    hud.bezelView.color = [[UIColor blackColor] colorWithAlphaComponent:0.8];
    hud.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
    // 隐藏时候从父控件中移除
    hud.removeFromSuperViewOnHide = YES;

    // 蒙版效果
    
    return hud;
}
+ (void)hideActivity {
    [self hideHUDForView:[UIApplication sharedApplication].keyWindow animated:YES];
}

@end
