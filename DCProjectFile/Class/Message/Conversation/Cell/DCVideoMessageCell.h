//
//  DCVideoMessageCell.h
//  DCProjectFile
//
//  Created  on 2023/6/29.
//

#import "DCMessageCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface DCVideoMessageCell : DCMessageCell
@property (nonatomic, strong) UIImageView *pictureView;

@property (nonatomic, assign) CGFloat progress;

- (void)setDataModel:(DCMessageContent *)model;

@end

NS_ASSUME_NONNULL_END
