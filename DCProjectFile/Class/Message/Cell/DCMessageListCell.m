//
//  DCMessageListCell.m
//  DCProjectFile
//
//  Created  on 2023/6/6.
//

#import "DCMessageListCell.h"

@interface DCMessageListCell ()
@property (weak, nonatomic) IBOutlet UIImageView *userAvatar;
@property (weak, nonatomic) IBOutlet UILabel *nicknameLabel;
@property (weak, nonatomic) IBOutlet UILabel *messageContent;
@property (weak, nonatomic) IBOutlet UILabel *msgTimeLabel;
@property (weak, nonatomic) IBOutlet UIView *unReadMsgView;
@property (weak, nonatomic) IBOutlet UILabel *unReadMsgLabel;
@property (weak, nonatomic) IBOutlet UILabel *msgPreLabel;
@property (weak, nonatomic) IBOutlet UIImageView *notiOffImg;

@end


@implementation DCMessageListCell


- (void)setDataModel:(DCConversationModel *)dataModel {
    _dataModel = dataModel;
    if (dataModel.conversationInfo) {
        DCUserInfo *userInfo = dataModel.conversationInfo;
        self.nicknameLabel.text = userInfo.name;
        [self.userAvatar sd_setImageWithURL:[NSURL URLWithString:userInfo.portraitUri] placeholderImage:kPlaceholderImage];
    }else {
        [self setUserInfo:dataModel.targetId];
    }
    self.messageContent.text = dataModel.lastMessage.message;
    if (dataModel.lastMessage.is_secret) {
        self.messageContent.text = @"[密聊消息]";
    }
    
    if (dataModel.lastMessage.message_type==3) {
        self.messageContent.text = @"[聊天记录]";
    }
    if (dataModel.lastMessage.message_type==10) {
        self.messageContent.text = @"[语音通话]";
    }
    
    if (dataModel.lastMessage.message_type==11) {
        self.messageContent.text = @"[视频通话]";
    }
    if (dataModel.isMentionedMe) {
        self.msgPreLabel.text = @"[有人@我]";
    }else {
        self.msgPreLabel.text = @"";
    }
    self.msgTimeLabel.text = [DCTools convertStrToTime:dataModel.lastMsgTime];
    self.unReadMsgView.hidden = dataModel.unReadMessageCount <= 0;
    self.unReadMsgLabel.text = [NSString stringWithFormat:@"%ld",(long)dataModel.unReadMessageCount];
    self.notiOffImg.hidden = ![dataModel.disturbState isEqualToString:@"1"];
}

- (void)setUserInfo:(NSString *)targetId {
    [[DCUserManager sharedManager] getConversationData:self.dataModel.conversationType targerId:targetId completion:^(DCUserInfo * _Nonnull userInfo) {
        if (self.dataModel) {
            self.dataModel.conversationInfo = userInfo;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            self.nicknameLabel.text = userInfo.name;
            [self.userAvatar sd_setImageWithURL:[NSURL URLWithString:userInfo.portraitUri] placeholderImage:kPlaceholderImage];
        });
    }];
}


- (void)setHistoryMsgs:(NSArray *)historyMsgs {
    _historyMsgs = historyMsgs;
    DCMessageContent *dataModel = historyMsgs.firstObject;
    [self setUserInfo:dataModel.targetId];
    
    self.messageContent.text = historyMsgs.count > 1 ? [NSString stringWithFormat:@"%ld条相关聊天记录",historyMsgs.count] : dataModel.message;
    self.msgTimeLabel.hidden = YES;
    self.unReadMsgView.hidden = YES;
    self.notiOffImg.hidden = YES;
    
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
