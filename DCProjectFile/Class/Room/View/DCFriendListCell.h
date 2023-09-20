//
//  DCFriendListCell.h
//  DCProjectFile
//
//  Created  on 2023/6/20.
//

#import <UIKit/UIKit.h>
#import "DCFriendListModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface DCFriendListCell : UITableViewCell
@property (nonatomic, strong) DCFriendItem *item;
@property (nonatomic, strong) DCConversationModel *conversation;
@end

NS_ASSUME_NONNULL_END
