//
//  DCFriendListCell.m
//  DCProjectFile
//
//  Created  on 2023/6/20.
//

#import "DCFriendListCell.h"

@interface DCFriendListCell ()
@property (weak, nonatomic) IBOutlet UIImageView *userAvatar;
@property (weak, nonatomic) IBOutlet UILabel *nickname;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftMargin;
@property (weak, nonatomic) IBOutlet UIButton *checkButton;

@end

@implementation DCFriendListCell


- (void)setItem:(DCFriendItem *)item {
    _item = item;
    self.nickname.text = item.remark;
    [self.userAvatar sd_setImageWithURL:[NSURL URLWithString:item.avatar] placeholderImage:kPlaceholderImage];
    
    if (item.isSel) {
        self.nickname.textColor = kTextSubColor;
    }else {
        self.nickname.textColor = kTextTitColor;
    }
    self.checkButton.selected = item.isSel;
    
    
    if (![DCTools isEmpty:item.name]) {
        self.nickname.text = item.name;
    }
}
- (void)setConversation:(DCConversationModel *)conversation {
    _conversation = conversation;
    if (conversation.conversationInfo) {
        DCUserInfo *userInfo = conversation.conversationInfo;
        self.nickname.text = userInfo.name;
        [self.userAvatar sd_setImageWithURL:[NSURL URLWithString:userInfo.portraitUri] placeholderImage:kPlaceholderImage];
    }else {
        [self setUserInfo:conversation.targetId];
    }
}
- (void)setUserInfo:(NSString *)targetId {
    [[DCUserManager sharedManager] getConversationData:self.conversation.conversationType targerId:targetId completion:^(DCUserInfo * _Nonnull userInfo) {
        self.conversation.conversationInfo = userInfo;
        dispatch_async(dispatch_get_main_queue(), ^{
            self.nickname.text = userInfo.name;
            [self.userAvatar sd_setImageWithURL:[NSURL URLWithString:userInfo.portraitUri] placeholderImage:kPlaceholderImage];
        });
    }];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    for (UIControl *control in self.subviews) {
        if (![control isMemberOfClass:NSClassFromString(@"UITableViewCellEditControl")]){
            continue;
        }
        for (UIView *subView in control.subviews) {
            if (![subView isKindOfClass: [UIImageView class]]) {
                continue;
            }
            UIImageView *imageView = (UIImageView *)subView;
            if (self.selected) {
                imageView.image = [UIImage imageNamed:@"round_selected"]; // 选中时的图片
            } else {
                imageView.image = [UIImage imageNamed:@"round_unselected"];   // 未选中时的图片
            }
        }
    }
}
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    UIView *selectedBackgroundView = [[UIView alloc]init];
    selectedBackgroundView.backgroundColor = [kMainColor colorWithAlphaComponent:0.05];
    self.selectedBackgroundView = selectedBackgroundView;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
