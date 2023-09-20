//
//  DCNavigationController.m
//  DCProjectFile
//
//  Created  on 2023/2/28.
//

#import "DCNavigationController.h"

@interface DCNavigationController ()<UIGestureRecognizerDelegate>

@end

@implementation DCNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupNavigationBar];
    
    __weak typeof(self) weakself = self;
    if ([self respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.interactivePopGestureRecognizer.delegate = (id)weakself;
    }

}

#pragma mark - UIGestureRecognizerDelegate
//这个方法是在手势将要激活前调用：返回YES允许右滑手势的激活，返回NO不允许右滑手势的激活
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer == self.interactivePopGestureRecognizer) {
        //屏蔽调用rootViewController的滑动返回手势，避免右滑返回手势引起crash
        if (self.viewControllers.count < 2 ||
            self.visibleViewController == [self.viewControllers objectAtIndex:0]) {
            return NO;
        }
    }
    return YES;
}

+ (void)initialize {

    if (self == [DCNavigationController class]) {
        UINavigationBar *bar = [UINavigationBar appearanceWhenContainedInInstancesOfClasses:@[self]];
        [bar setBackgroundImage:[UIImage createImageWithColor:kBackgroundColor] forBarMetrics:UIBarMetricsDefault];
        bar.translucent = NO;
        bar.shadowImage = [[UIImage alloc]init];
    }

}
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (self.viewControllers.count >0) {
        [viewController setHidesBottomBarWhenPushed:YES];
        viewController.navigationItem.leftBarButtonItem = [self setBackBarButtonItem];

    }
    [super pushViewController:viewController animated:animated];
}


- (UIBarButtonItem *)setBackBarButtonItem {
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [backBtn setImage:[UIImage imageNamed:@"icon_back_normal"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backClick) forControlEvents:UIControlEventTouchUpInside];
    backBtn.frame = CGRectMake(0, 0, 39, 37);
    backBtn.adjustsImageWhenHighlighted = false;
    backBtn.contentEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 0);
    UIBarButtonItem *item = [[UIBarButtonItem alloc]initWithCustomView:backBtn];

    return item;
}
- (void)backClick {
    [self popViewControllerAnimated:YES];
}



- (void)setupNavigationBar {
    self.navigationBar.tintColor = kBackgroundColor;
    self.navigationBar.translucent = false;
    
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : kTextTitColor,NSFontAttributeName : [UIFont fontWithName:@"PingFangSC-Medium" size:20]}];
    //[[UIScrollView appearance] setContentInsetAdjustmentBehavior:UIScrollViewContentInsetAdjustmentNever];
    
    // iOS 15适配
    if (@available(iOS 13.0, *)) {
        UINavigationBarAppearance *appearance = [[UINavigationBarAppearance alloc] init];
        [appearance setBackgroundColor:kBackgroundColor];
        [appearance setShadowImage:[UIImage createImageWithColor:kBackgroundColor]];

        [[UINavigationBar appearance] setScrollEdgeAppearance: appearance];
        [[UINavigationBar appearance] setStandardAppearance:appearance];
    }
    
    if (@available(iOS 15.0, *)) {
        //设置默认的分组头部间隙为0
        [UITableView appearance].sectionHeaderTopPadding = 0;
    }
    
}
@end
