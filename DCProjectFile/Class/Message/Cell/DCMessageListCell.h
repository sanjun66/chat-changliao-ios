//
//  DCMessageListCell.h
//  DCProjectFile
//
//  Created  on 2023/6/6.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DCMessageListCell : UITableViewCell
@property (nonatomic, strong) DCConversationModel *dataModel;
@property (nonatomic, strong) NSArray *historyMsgs;
@end

NS_ASSUME_NONNULL_END
