//
//  DCForwardMessageCell.m
//  DCProjectFile
//
//  Created  on 2023/7/31.
//

#import "DCForwardMessageCell.h"

@interface DCForwardMessageCell ()
@property (nonatomic, strong) UILabel *titItem;
@property (nonatomic, strong) UILabel *descLabel;
@property (nonatomic, strong) UILabel *descLabel1;
@property (nonatomic, strong) UILabel *descLabel2;
@property (nonatomic, strong) UIView *lineView;
@property (nonatomic, strong) UILabel *noticeLabel;
@end

@implementation DCForwardMessageCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initialize];
    }
    return self;
}

+ (CGSize)sizeForMessageModel:(DCMessageContent *)model withCollectionViewWidth:(CGFloat)collectionViewWidth referenceExtraHeight:(CGFloat)extraHeight {
    NSInteger lineCount = model.extra.talk_list.count > 3 ? 3:model.extra.talk_list.count;
    CGFloat height = lineCount *20 + 70;
    if (model.isDisplayMsgTime) {
        height += 20;
    }
    if (model.conversationType==DC_ConversationType_GROUP && model.messageDirection==DC_MessageDirection_RECEIVE) {
        height += 20;
    }
    
    height += extraHeight;
    
    return CGSizeMake(collectionViewWidth,height);
}

- (void)setDataModel:(DCMessageContent *)model {
    [super setDataModel:model];
    self.nicknameLabel.hidden = (self.model.conversationType==DC_ConversationType_PRIVATE || self.model.messageDirection == DC_MessageDirection_SEND);
    CGFloat maxWidth = kScreenWidth *0.637+7;
    NSInteger lineCount = model.extra.talk_list.count > 3 ? 3:model.extra.talk_list.count;
    
    CGRect rect = self.messageContentView.frame;
    rect.size.width = maxWidth;
    rect.size.height = lineCount * 20 + 70;
    
    self.messageContentView.frame = rect;
    self.bubbleBackgroundView.frame = self.messageContentView.bounds;
    CGFloat pointX = (self.model.messageDirection == DC_MessageDirection_SEND ? 12:20);
    
    self.titItem.frame = CGRectMake(pointX, 10, rect.size.width-32, 20);
    self.descLabel.frame = CGRectMake(pointX, CGRectGetMaxY(self.titItem.frame)+10, CGRectGetWidth(self.titItem.frame), 20);
    
    self.lineView.frame = CGRectMake(pointX, rect.size.height-20, CGRectGetWidth(self.titItem.frame), 0.5);
    self.noticeLabel.frame = CGRectMake(pointX, CGRectGetMaxY(self.lineView.frame), CGRectGetWidth(self.titItem.frame), 20);
    
    if (self.model.messageDirection == DC_MessageDirection_RECEIVE) {
        self.bubbleBackgroundView.image = [UIImage imageNamed:@"msg_bubble_receive"];
        self.titItem.textColor = HEX(@"#1C2340");
        self.descLabel.textColor = [HEX(@"#1C2340") colorWithAlphaComponent:0.8];
        self.descLabel1.textColor = [HEX(@"#1C2340") colorWithAlphaComponent:0.8];
        self.descLabel2.textColor = [HEX(@"#1C2340") colorWithAlphaComponent:0.8];
        self.noticeLabel.textColor = [HEX(@"#1C2340") colorWithAlphaComponent:0.8];
        self.lineView.backgroundColor = [HEX(@"#1C2340") colorWithAlphaComponent:0.1];
    }else {
        self.bubbleBackgroundView.image = [UIImage imageNamed:@"msg_bubble_sent"];
        self.titItem.textColor = kWhiteColor;
        self.descLabel.textColor = [kWhiteColor colorWithAlphaComponent:0.8];
        self.descLabel1.textColor = [kWhiteColor colorWithAlphaComponent:0.8];
        self.descLabel2.textColor = [kWhiteColor colorWithAlphaComponent:0.8];
        self.noticeLabel.textColor = [kWhiteColor colorWithAlphaComponent:0.8];
        self.lineView.backgroundColor = [kWhiteColor colorWithAlphaComponent:0.3];
    }
    UIImage *image = self.bubbleBackgroundView.image;
    self.bubbleBackgroundView.image = [self.bubbleBackgroundView.image
        resizableImageWithCapInsets:UIEdgeInsetsMake(image.size.height -5, image.size.width * 0.5,
                                                     5, image.size.width * 0.5)];
    
    
    if (self.model.extra.talk_list.count==1) {
        self.descLabel1.hidden = YES;
        self.descLabel2.hidden = YES;
        DCMessageContent *fMsg = self.model.extra.talk_list.firstObject;
        [[DCUserManager sharedManager] getConversationData:DC_ConversationType_PRIVATE targerId:fMsg.from_uid completion:^(DCUserInfo * _Nonnull userInfo) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.descLabel.text = [NSString stringWithFormat:@"%@：%@",userInfo.name , fMsg.message];
            });
        }];
        
    }
    
    if (self.model.extra.talk_list.count==2) {
        self.descLabel2.hidden = YES;
        self.descLabel1.hidden = NO;
        DCMessageContent *fMsg = self.model.extra.talk_list.firstObject;
        [[DCUserManager sharedManager] getConversationData:DC_ConversationType_PRIVATE targerId:fMsg.from_uid completion:^(DCUserInfo * _Nonnull userInfo) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.descLabel.text = [NSString stringWithFormat:@"%@：%@",userInfo.name , fMsg.message];
            });
        }];
        
        DCMessageContent *fMsg1 = self.model.extra.talk_list[1];
        [[DCUserManager sharedManager] getConversationData:DC_ConversationType_PRIVATE targerId:fMsg1.from_uid completion:^(DCUserInfo * _Nonnull userInfo) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.descLabel1.text = [NSString stringWithFormat:@"%@：%@",userInfo.name , fMsg1.message];
            });
        }];
        
        self.descLabel1.frame = CGRectMake(pointX, CGRectGetMaxY(self.descLabel.frame), CGRectGetWidth(self.titItem.frame), 20);
    }
    
    if (self.model.extra.talk_list.count >= 3) {
        self.descLabel1.hidden = NO;
        self.descLabel2.hidden = NO;
        DCMessageContent *fMsg = self.model.extra.talk_list.firstObject;
        [[DCUserManager sharedManager] getConversationData:DC_ConversationType_PRIVATE targerId:fMsg.from_uid completion:^(DCUserInfo * _Nonnull userInfo) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.descLabel.text = [NSString stringWithFormat:@"%@：%@",userInfo.name , fMsg.message];
            });
        }];
        
        DCMessageContent *fMsg1 = self.model.extra.talk_list[1];
        [[DCUserManager sharedManager] getConversationData:DC_ConversationType_PRIVATE targerId:fMsg1.from_uid completion:^(DCUserInfo * _Nonnull userInfo) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.descLabel1.text = [NSString stringWithFormat:@"%@：%@",userInfo.name , fMsg1.message];
            });
        }];
        
        DCMessageContent *fMsg2 = self.model.extra.talk_list[2];
        [[DCUserManager sharedManager] getConversationData:DC_ConversationType_PRIVATE targerId:fMsg2.from_uid completion:^(DCUserInfo * _Nonnull userInfo) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.descLabel2.text = [NSString stringWithFormat:@"%@：%@",userInfo.name , fMsg2.message];
            });
        }];
        self.descLabel1.frame = CGRectMake(pointX, CGRectGetMaxY(self.descLabel.frame), CGRectGetWidth(self.titItem.frame), 20);
        self.descLabel2.frame = CGRectMake(pointX, CGRectGetMaxY(self.descLabel1.frame), CGRectGetWidth(self.titItem.frame), 20);
    }
    
    if (self.model.extra.talk_type==2) {
        self.titItem.text = @"群聊的聊天记录";
    }else {
        DCMessageContent *fMsg = self.model.extra.talk_list.firstObject;
        [[DCUserManager sharedManager] getConversationData:DC_ConversationType_PRIVATE targerId:fMsg.from_uid completion:^(DCUserInfo * _Nonnull userInfo) {
            NSString *fromName = userInfo.name;
            [[DCUserManager sharedManager] getConversationData:DC_ConversationType_PRIVATE targerId:fMsg.to_uid completion:^(DCUserInfo * _Nonnull userInfo) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.titItem.text = [NSString stringWithFormat:@"%@和%@的聊天记录", fromName, userInfo.name];
                });
            }];
        }];
    }
    
    [self setCellAutoLayout];
}
- (void)initialize {
    [self showBubbleBackgroundView:YES];
    [self.messageContentView addSubview:self.titItem];
    [self.messageContentView addSubview:self.descLabel];
    [self.messageContentView addSubview:self.descLabel1];
    [self.messageContentView addSubview:self.descLabel2];
    [self.messageContentView addSubview:self.lineView];
    [self.messageContentView addSubview:self.noticeLabel];
}
- (UILabel *)titItem {
    if (!_titItem) {
        _titItem = [[UILabel alloc]initWithFrame:CGRectZero];
        _titItem.textColor = kTextTitColor;
        _titItem.font = kFontSize(16);
    }
    return _titItem;
}

- (UILabel *)descLabel {
    if (!_descLabel) {
        _descLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        _descLabel.font = kFontSize(13);
        _descLabel.textColor = kTextSubColor;
    }
    return _descLabel;
}
- (UILabel *)descLabel1 {
    if (!_descLabel1) {
        _descLabel1 = [[UILabel alloc]initWithFrame:CGRectZero];
        _descLabel1.font = kFontSize(13);
        _descLabel1.textColor = kTextSubColor;
    }
    return _descLabel1;
}
- (UILabel *)descLabel2 {
    if (!_descLabel2) {
        _descLabel2 = [[UILabel alloc]initWithFrame:CGRectZero];
        _descLabel2.font = kFontSize(13);
        _descLabel2.textColor = kTextSubColor;
    }
    return _descLabel2;
}

- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [[UIView alloc]initWithFrame:CGRectZero];
        _lineView.backgroundColor = kBackgroundColor;
        
    }
    return _lineView;
}

- (UILabel *)noticeLabel {
    if (!_noticeLabel) {
        _noticeLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        _noticeLabel.text = @"聊天记录";
        _noticeLabel.font = kFontSize(11);
        _noticeLabel.textColor = kTextSubColor;
    }
    return _noticeLabel;
}
@end
