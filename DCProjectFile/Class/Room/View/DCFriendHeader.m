//
//  DCFriendHeader.m
//  DCProjectFile
//
//  Created  on 2023/7/14.
//

#import "DCFriendHeader.h"
#import "DCGroupListVC.h"
#import "DCFriendApplyVC.h"
@interface DCFriendHeader ()
@property (weak, nonatomic) IBOutlet UILabel *redBadge;

@end

@implementation DCFriendHeader

- (void)setApplyNumber:(NSInteger)applyNumber {
    _applyNumber = applyNumber;
    self.redBadge.hidden = applyNumber<=0;
    self.redBadge.text = [NSString stringWithFormat:@"%ld",applyNumber];
}

- (IBAction)groupListButtonClick:(id)sender {
    DCGroupListVC *vc = [[DCGroupListVC alloc]init];
    [[DCTools navigationViewController] pushViewController:vc animated:YES];
}

- (IBAction)friendApplyButtonClick:(id)sender {
    DCFriendApplyVC *vc = [[DCFriendApplyVC alloc]init];
    [[DCTools navigationViewController] pushViewController:vc animated:YES];
//    self.isHaveFriendApply = NO;
//    DCTabBarController *tabbar = (DCTabBarController *)[UIApplication sharedApplication].keyWindow.rootViewController;
//    if ([tabbar isKindOfClass:[DCTabBarController class]]) {
//        tabbar.friendRedBadge.hidden = YES;
//    }
}

@end
