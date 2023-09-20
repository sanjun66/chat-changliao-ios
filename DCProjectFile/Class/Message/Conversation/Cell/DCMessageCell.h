//
//  DCMessageCell.h
//  DCProjectFile
//
//  Created  on 2023/6/7.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class DCMessageContent;

@protocol DCMessageCellDelegate <NSObject>

- (void)didTapCellPortrait:(NSString *)userId;

- (void)didLongPressCellPortrait:(NSString *)userId;

- (void)didTapMessageCell:(DCMessageContent *)model;

- (void)didLongTouchMessageCell:(DCMessageContent *)model inView:(UIView *)view;

- (void)didTapmessageFailedStatusViewForResend:(DCMessageContent *)model;

- (void)didTapSecretMessage:(DCMessageContent *)model inputPwd:(NSString *)pwd;

- (void)onCheckMessage:(DCMessageContent *)model isSelect:(BOOL)isSelect;
@end

@interface DCMessageCell : UICollectionViewCell

@property (nonatomic, weak) id <DCMessageCellDelegate>delegate;

@property (nonatomic, strong) UIView *messageContentView;

@property (nonatomic, strong, nullable) UIImageView *bubbleBackgroundView;
/*!
 显示发送状态的View

 @discussion 其中包含messageFailedStatusView子View。
 */
@property (nonatomic, strong) UIView *statusContentView;
/*!
 显示发送失败状态的View
 */
@property (nonatomic, strong) UIButton *messageFailedStatusView;
/*!
 消息发送指示View
 */
@property (nonatomic, strong) UIActivityIndicatorView *messageActivityIndicatorView;


@property (nonatomic, strong) UIButton *messageHaveReadView;
/*!
消息发送者的用户头像
*/
@property (nonatomic, strong) UIImageView *portraitImageView;

/*!
 消息发送者的用户名称
 */
@property (nonatomic, strong) UILabel *nicknameLabel;

/*!
 消息Cell的数据模型
 */
@property (strong, nonatomic, nullable) DCMessageContent *model;


@property (nonatomic, assign) BOOL isEditing;


- (void)setDataModel:(DCMessageContent *)model;

- (void)setCellAutoLayout;

- (void)showBubbleBackgroundView:(BOOL)show;

+ (CGSize)sizeForMessageModel:(DCMessageContent *)model
      withCollectionViewWidth:(CGFloat)collectionViewWidth
         referenceExtraHeight:(CGFloat)extraHeight;
@end

NS_ASSUME_NONNULL_END
