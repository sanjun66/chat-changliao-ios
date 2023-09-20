//
//  DCSearchUserCell.h
//  DCProjectFile
//
//  Created  on 2023/6/14.
//

#import <UIKit/UIKit.h>
#import "DCSearchUserModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface DCSearchUserCell : UITableViewCell
@property (nonatomic, strong) DCSearchUserModel *model;
@property (nonatomic, copy) void (^applyFriendBlock)(DCSearchUserModel *selModel);
@end

NS_ASSUME_NONNULL_END
