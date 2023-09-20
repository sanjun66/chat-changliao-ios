//
//  DCReminderMessageCell.h
//  DCProjectFile
//
//  Created  on 2023/7/10.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DCReminderMessageCell : UICollectionViewCell

@property (strong, nonatomic, nullable) DCMessageContent *model;

- (void)setDataModel:(DCMessageContent *)model;

+ (CGSize)sizeForMessageModel:(DCMessageContent *)model
      withCollectionViewWidth:(CGFloat)collectionViewWidth
         referenceExtraHeight:(CGFloat)extraHeight;
@end

NS_ASSUME_NONNULL_END
