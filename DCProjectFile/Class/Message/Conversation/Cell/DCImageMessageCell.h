//
//  DCImageMessageCell.h
//  DCProjectFile
//
//  Created  on 2023/6/26.
//

#import "DCMessageCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface DCImageMessageCell : DCMessageCell

@property (nonatomic, strong) UIImageView *pictureView;

- (void)setDataModel:(DCMessageContent *)model;
@end

NS_ASSUME_NONNULL_END
