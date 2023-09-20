//
//  DCFriendApplyCell.h
//  DCProjectFile
//
//  Created  on 2023/6/15.
//

#import <UIKit/UIKit.h>
#import "DCFriendApplyModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface DCFriendApplyCell : UITableViewCell
@property (nonatomic, strong) DCFriendApplyModel *model;
@property (nonatomic, copy) void (^actionBlock)(DCFriendApplyModel *selModel , NSInteger action);

@end

NS_ASSUME_NONNULL_END
