//
//  DCCallMessageCell.m
//  DCProjectFile
//
//  Created  on 2023/7/31.
//

#import "DCCallMessageCell.h"
@interface DCCallMessageCell ()
@property (nonatomic, strong) UIImageView *titIcon;
@property (nonatomic, strong) UILabel *textLabel;
@end

@implementation DCCallMessageCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initialize];
    }
    return self;
}

+ (CGSize)sizeForMessageModel:(DCMessageContent *)model withCollectionViewWidth:(CGFloat)collectionViewWidth referenceExtraHeight:(CGFloat)extraHeight {
    return CGSizeMake(collectionViewWidth, 40+extraHeight+(model.isDisplayMsgTime?20:0) +((model.conversationType==DC_ConversationType_GROUP && model.messageDirection==DC_MessageDirection_RECEIVE)?20:0));
}

- (void)setDataModel:(DCMessageContent *)model {
    [super setDataModel:model];
    self.nicknameLabel.hidden = (self.model.conversationType==DC_ConversationType_PRIVATE || self.model.messageDirection == DC_MessageDirection_SEND);
    NSString *textString = [self textString];
    
    CGSize size = [textString textSizeIn:CGSizeMake(CGFLOAT_MAX, 16) font:kFontSize(15)];
    CGRect rect = self.messageContentView.frame;
    rect.size.width = size.width + 16 + 10 + 24 + 10 + 8;
    rect.size.height = 40;
    self.messageContentView.frame = rect;
    
    self.bubbleBackgroundView.frame = self.messageContentView.bounds;
    
    self.titIcon.frame = CGRectMake(16, 8, 24, 24);
    self.textLabel.frame = CGRectMake(50, 10, size.width, 20);
    
    self.textLabel.text = textString;
    
    
    
    if (self.model.messageDirection == DC_MessageDirection_RECEIVE) {
        self.textLabel.textColor = HEX(@"#1C2340");
        self.bubbleBackgroundView.image = [UIImage imageNamed:@"msg_bubble_receive"];
        if (self.model.message_type==10) {
            self.titIcon.image = [UIImage imageNamed:@"call_msg_audio"];
        }else {
            self.titIcon.image = [UIImage imageNamed:@"call_msg_video"];
        }
        
    }else {
        self.textLabel.textColor = kWhiteColor;
        self.bubbleBackgroundView.image = [UIImage imageNamed:@"msg_bubble_sent"];
        if (self.model.message_type==10) {
            self.titIcon.image = [UIImage imageNamed:@"call_msg_audio_sent"];
        }else {
            self.titIcon.image = [UIImage imageNamed:@"call_msg_video_sent"];
        }
    }
    UIImage *image = self.bubbleBackgroundView.image;
    self.bubbleBackgroundView.image = [self.bubbleBackgroundView.image
        resizableImageWithCapInsets:UIEdgeInsetsMake(image.size.height * 0.5, image.size.width * 0.5,
                                                     image.size.height * 0.5, image.size.width * 0.5)];
    
    [self setCellAutoLayout];
}

- (NSString *)textString {
    NSString *text = @"";
    if (self.model.extra.state==1) {
        if (self.model.messageDirection==DC_MessageDirection_SEND) {
            text = @"已取消";
        }else {
            text = @"对方已取消";
        }
    }else if (self.model.extra.state==2) {
        if (self.model.messageDirection==DC_MessageDirection_SEND) {
            text = @"对方已拒绝";
        }else {
            text = @"已拒绝";
        }
    }else if (self.model.extra.state==3) {
        if (self.model.messageDirection==DC_MessageDirection_SEND) {
            text = @"对方无应答";
        }else {
            text = @"未接听";
        }
    }else if (self.model.extra.state==5) {
        text = [NSString stringWithFormat:@"通话时长 %@",[DCTools callDurationFromSeconds:self.model.extra.duration]];
    }else if (self.model.extra.state==7) {
        if (self.model.messageDirection==DC_MessageDirection_SEND) {
            text = @"对方忙碌";
        }else {
            text = @"忙碌未接通";
        }
    }else {
        text = @"通话异常";
    }
    
    return text;
}

- (void)initialize {
    [self showBubbleBackgroundView:YES];
    [self.messageContentView addSubview:self.titIcon];
    [self.messageContentView addSubview:self.textLabel];
}

- (UIImageView *)titIcon {
    if(!_titIcon) {
        _titIcon = [[UIImageView alloc]init];
        
    }
    return _titIcon;
}

- (UILabel *)textLabel {
    if (!_textLabel) {
        _textLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        _textLabel.font = kFontSize(15);
        _textLabel.textColor = kTextTitColor;
        
    }
    return _textLabel;
}
@end
