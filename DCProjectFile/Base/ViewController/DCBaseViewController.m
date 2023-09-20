//
//  DCBaseViewController.m
//  DCProjectFile
//
//  Created  on 2023/2/28.
//

#import "DCBaseViewController.h"

@interface DCBaseViewController ()

@end

@implementation DCBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = kBackgroundColor;
}

- (void)dealloc {
   DCLog(@"deinit_type_%@",self);
}

- (void)createLeftBarButtonItemWithString:(NSString *)string {
   UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
   for(int i=0; i< [string length];i++){
       int a = [string characterAtIndex:i];
       if( a > 0x4e00 && a < 0x9fff)
       {
           [btn setTitle:string forState:UIControlStateNormal];
           [btn setTitleColor:kBlackColor forState:UIControlStateNormal];
           btn.titleLabel.font = kFontSize(14);
       }else {
           [btn setImage:[UIImage imageNamed:string] forState:UIControlStateNormal];
       }
   }
   
   [btn addTarget:self action:@selector(leftBarButtonAction) forControlEvents:UIControlEventTouchUpInside];
   [btn sizeToFit];
   
   UIBarButtonItem *item = [[UIBarButtonItem alloc]initWithCustomView:btn];
   self.navigationItem.leftBarButtonItem = item;
}

- (void)rightBarButtonItemWithString:(NSString *)string {
   UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
   for(int i=0; i< [string length];i++){
       int a = [string characterAtIndex:i];
       if( a > 0x4e00 && a < 0x9fff)
       {
           [btn setTitle:string forState:UIControlStateNormal];
           [btn setTitleColor:kBlackColor forState:UIControlStateNormal];
           btn.titleLabel.font = kFontSize(14);
       }else {
           [btn setImage:[UIImage imageNamed:string] forState:UIControlStateNormal];
       }
   }
   [btn addTarget:self action:@selector(rightBarButtonAction) forControlEvents:UIControlEventTouchUpInside];
   [btn sizeToFit];
   
   UIBarButtonItem *item = [[UIBarButtonItem alloc]initWithCustomView:btn];
   self.navigationItem.rightBarButtonItem = item;
}

- (void)leftBarButtonAction{}
- (void)rightBarButtonAction{}


- (void)popGestureEnable:(BOOL)enable
{
    // 禁用侧滑返回手势
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        //这里对添加到右滑视图上的所有手势禁用
        for (UIGestureRecognizer *popGesture in self.navigationController.interactivePopGestureRecognizer.view.gestureRecognizers) {
            popGesture.enabled = enable;
        }
    }
}

@end
