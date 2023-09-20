//
//  DCGroupListVC.h
//  DCProjectFile
//
//  Created  on 2023/7/14.
//

#import "DCBaseViewController.h"
#import "DCFriendListModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface DCGroupListVC : DCBaseViewController
@property (nonatomic, assign) BOOL isForwardMsg;
@property (nonatomic, copy) void(^selectItemBlock)(DCFriendItem *item);
@end

NS_ASSUME_NONNULL_END
