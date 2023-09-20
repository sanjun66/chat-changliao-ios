//
//  DCTextMessageCell.h
//  DCProjectFile
//
//  Created  on 2023/6/7.
//

#import "DCMessageCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface DCTextMessageCell : DCMessageCell

@property (nonatomic, strong) UILabel *textLabel;

- (void)setDataModel:(DCMessageContent *)model;

@end

NS_ASSUME_NONNULL_END
