//
//  DCForwardMsgBaseCell.h
//  DCProjectFile
//
//  Created  on 2023/9/7.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol DCForwardMsgBaseCellDelegate <NSObject>

- (void)didTapMessageCell:(DCMessageContent *)model;

- (void)didLongTouchMessageCell:(DCMessageContent *)model inView:(UIView *)view;

@end
@interface DCForwardMsgBaseCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *userAvatar;
@property (weak, nonatomic) IBOutlet UILabel *nicknameLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIView *msgContentView;
@property (weak, nonatomic) IBOutlet UILabel *msgTextLabel;

@property (weak, nonatomic) IBOutlet UIView *extraView;
@property (weak, nonatomic) IBOutlet UIImageView *extraIcon;
@property (weak, nonatomic) IBOutlet UILabel *extraTitle;
@property (weak, nonatomic) IBOutlet UILabel *extraDesc;

@property (nonatomic, strong) UIImageView *pictureView;

@property (nonatomic, strong) DCMessageContent *model;

@property (nonatomic, weak) id <DCForwardMsgBaseCellDelegate>delegate;
@end

NS_ASSUME_NONNULL_END
