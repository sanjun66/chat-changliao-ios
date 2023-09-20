//
//  DCTabBarController.h
//  DCProjectFile
//
//  Created  on 2023/2/28.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DCTabBarController : UITabBarController
@property (nonatomic, strong) UILabel *redBadge;        // 消息红点
@property (nonatomic, strong) UILabel *friendRedBadge;  // 好友红点
@end

NS_ASSUME_NONNULL_END
