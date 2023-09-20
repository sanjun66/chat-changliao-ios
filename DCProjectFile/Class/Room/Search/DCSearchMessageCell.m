//
//  DCSearchMessageCell.m
//  DCProjectFile
//
//  Created  on 2023/9/11.
//

#import "DCSearchMessageCell.h"
@interface DCSearchMessageCell ()
@property (weak, nonatomic) IBOutlet UILabel *nicknameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *userAvatar;
@property (weak, nonatomic) IBOutlet UILabel *messageContent;
@property (weak, nonatomic) IBOutlet UILabel *msgTimeLabel;

@end


@implementation DCSearchMessageCell

- (void)setMsg:(DCMessageContent *)msg {
    _msg = msg;
    [self setUserInfo:msg.from_uid];
    
    self.msgTimeLabel.text = [DCTools convertStrToTime:msg.timestamp];
    
    if (msg.is_secret) {
        self.messageContent.text = @"[密聊消息]";
    }else {
        self.messageContent.text = msg.message;
        if (msg.message_type==3) {
            self.messageContent.text = @"[聊天记录]";
        }
        if (msg.message_type==10) {
            self.messageContent.text = @"[语音通话]";
        }
        
        if (msg.message_type==11) {
            self.messageContent.text = @"[视频通话]";
        }
    }
    
    
}
- (void)setUserInfo:(NSString *)targetId {
    [[DCUserManager sharedManager] getConversationData:DC_ConversationType_PRIVATE targerId:targetId completion:^(DCUserInfo * _Nonnull userInfo) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.nicknameLabel.text = userInfo.name;
            [self.userAvatar sd_setImageWithURL:[NSURL URLWithString:userInfo.portraitUri] placeholderImage:kPlaceholderImage];
        });
    }];
}
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
