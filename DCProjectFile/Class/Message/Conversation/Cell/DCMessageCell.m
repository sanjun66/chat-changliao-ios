//
//  DCMessageCell.m
//  DCProjectFile
//
//  Created  on 2023/6/7.
//

#import "DCMessageCell.h"
// 头像
#define PortraitImageViewTop 0
// 气泡
#define ContentViewBottom 14
#define DefaultMessageContentViewWidth 200
#define StatusContentViewWidth 100
#define DestructBtnWidth 20
#define StatusViewAndContentViewSpace 8

@interface DCMessageCell ()
@property (nonatomic, strong) UILabel *msgTimeLabel;
@property (nonatomic, strong) UIButton *checkView;

@end

@implementation DCMessageCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.contentView.transform = CGAffineTransformMakeRotation(-M_PI);
        [self setupMessageCellView];
    }
    return self;
}

- (void)setupMessageCellView {
    [self.contentView addSubview:self.msgTimeLabel];
    [self.contentView addSubview:self.portraitImageView];
    [self.contentView addSubview:self.nicknameLabel];
    [self.contentView addSubview:self.messageContentView];
    [self.contentView addSubview:self.statusContentView];
    [self.contentView addSubview:self.checkView];
    
    [self.statusContentView addSubview:self.messageFailedStatusView];
    [self.statusContentView addSubview:self.messageActivityIndicatorView];
    [self.statusContentView addSubview:self.messageHaveReadView];
    self.messageActivityIndicatorView.hidden = YES;
}

- (void)setDataModel:(DCMessageContent *)model {
    self.model = model;
    //    if (model.senderUser) {
    //        [self.portraitImageView sd_setImageWithURL:[NSURL URLWithString:model.senderUser.portraitUri] placeholderImage:[UIImage imageNamed:@"default_portrait_msg"]];
    //        self.nicknameLabel.text = model.senderUser.name;
    //    }else {
    if (model.messageDirection == DC_MessageDirection_SEND) {
        model.senderUser = [DCUserManager sharedManager].currentUserInfo;
        [self.portraitImageView sd_setImageWithURL:[NSURL URLWithString:[DCUserManager sharedManager].currentUserInfo.portraitUri] placeholderImage:[UIImage imageNamed:@"default_portrait_msg"]];
        self.nicknameLabel.text = [DCUserManager sharedManager].currentUserInfo.name;
    }else {
        [[DCUserManager sharedManager] getConversationData:DC_ConversationType_PRIVATE targerId:model.from_uid completion:^(DCUserInfo * _Nonnull userInfo) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.portraitImageView sd_setImageWithURL:[NSURL URLWithString:userInfo.portraitUri] placeholderImage:[UIImage imageNamed:@"default_portrait_msg"]];
                self.nicknameLabel.text = userInfo.name;
                model.senderUser = userInfo;
            });
        }];
    }
    //    }
    
    if (model.messageDirection == DC_MessageDirection_SEND) {
        if (model.msgSentStatus == DC_SentStatus_SENT) {
            self.statusContentView.hidden = NO;
            self.messageFailedStatusView.hidden = YES;
            self.messageActivityIndicatorView.hidden = YES;
            self.messageHaveReadView.hidden = NO;
            self.messageHaveReadView.selected = model.is_read;
        }else {
            self.statusContentView.hidden = NO;
            if (model.msgSentStatus == DC_SentStatus_SENDING) {
                self.messageActivityIndicatorView.hidden = NO;
                self.messageFailedStatusView.hidden = YES;
                self.messageHaveReadView.hidden = YES;
                [self.messageActivityIndicatorView startAnimating];
            }else if (model.msgSentStatus == DC_SentStatus_FAILED) {
                self.messageActivityIndicatorView.hidden = YES;
                self.messageFailedStatusView.hidden = NO;
                self.messageHaveReadView.hidden = YES;
            }else {
                self.statusContentView.hidden = YES;
            }
        }
    }else {
        self.statusContentView.hidden = YES;
    }
    NSString *dateTime = [DCTools convertStrToTime:model.timestamp];
    NSString *day = [[dateTime componentsSeparatedByString:@" "].firstObject componentsSeparatedByString:@"-"].lastObject;
    NSString *today = [[[DCTools getCurrentTimes] componentsSeparatedByString:@" "].firstObject componentsSeparatedByString:@"-"].lastObject;
    
    if ([day isEqualToString:today]) {
        self.msgTimeLabel.text = [dateTime componentsSeparatedByString:@" "].lastObject;
    }else {
        self.msgTimeLabel.text = dateTime;
    }
    
//    self.msgTimeLabel.text = [[DCTools convertStrToTime:model.timestamp] componentsSeparatedByString:@" "].lastObject;
    if (self.model.isHighlighted) {
        self.backgroundColor = HEX(@"F2F2F7");
    }else {
        self.backgroundColor = kBackgroundColor;
    }
    [self setCellAutoLayout];
}


- (void)setCellAutoLayout {
    CGFloat portraitY;
    CGFloat nicknameY;
    CGFloat portraitX=16;
    
    CGRect rect = self.contentView.bounds;
    if (self.model.cellSize.height > 0) {
        rect.size = self.model.cellSize;
    }
    
    self.checkView.hidden = YES;
    if (self.isEditing && !self.model.is_secret && self.model.msgSentStatus != DC_SentStatus_FAILED && self.model.msgSentStatus != DC_SentStatus_SENDING && (self.model.message_type==1 || (self.model.message_type==2 && self.model.extra.type != 4))) {
        portraitX=76;
        self.checkView.hidden = NO;
    }
    self.checkView.selected = self.model.isSelected;
    
    if (self.model.isDisplayMsgTime) {
        self.msgTimeLabel.hidden = NO;
        self.msgTimeLabel.frame = CGRectMake(0, 0, self.contentView.width, 20);
        portraitY =  28;
        nicknameY = 26;
    }else {
        self.msgTimeLabel.hidden = YES;
        portraitY = 8;
        nicknameY = 6;
    }
    
    
    if (self.model.messageDirection == DC_MessageDirection_RECEIVE) {
        self.portraitImageView.frame = CGRectMake(portraitX, portraitY, 40, 40);
        
        self.nicknameLabel.frame = CGRectMake(CGRectGetMaxX(self.portraitImageView.frame) + 12, nicknameY, 200, 14);
        self.nicknameLabel.textAlignment = NSTextAlignmentLeft;
        
        self.messageContentView.frame = CGRectMake(self.nicknameLabel.x, CGRectGetMaxY(self.nicknameLabel.frame)+(self.nicknameLabel.isHidden?-6:6), self.messageContentView.width, self.messageContentView.height);
        
        self.statusContentView.frame = CGRectMake(CGRectGetMaxX(self.messageContentView.frame), CGRectGetMidY(self.messageContentView.frame)-20, 40, 40);
        
    }else {
        self.portraitImageView.frame = CGRectMake(self.contentView.width-16-40, portraitY, 40, 40);
        
        self.nicknameLabel.frame = CGRectMake(self.portraitImageView.x-200-12, nicknameY, 200, 14);
        self.nicknameLabel.textAlignment = NSTextAlignmentRight;
        
        self.messageContentView.frame = CGRectMake(self.portraitImageView.x-12-self.messageContentView.width, CGRectGetMaxY(self.nicknameLabel.frame)+(self.nicknameLabel.isHidden?-6:6), self.messageContentView.width, self.messageContentView.height);
        
        self.statusContentView.frame = CGRectMake(self.messageContentView.x-40, CGRectGetMidY(self.messageContentView.frame)-20, 40, 40);
    }
    
    
    self.messageFailedStatusView.frame = CGRectMake(0, 0, self.statusContentView.width, self.statusContentView.height);
    self.messageActivityIndicatorView.frame = CGRectMake(0, 0, self.statusContentView.width, self.statusContentView.height);
    self.messageHaveReadView.frame =  CGRectMake(0, 0, self.statusContentView.width, self.statusContentView.height);
    self.checkView.frame = CGRectMake(0, 0, 60, rect.size.height);
    
}

+ (CGSize)sizeForMessageModel:(DCMessageContent *)model
      withCollectionViewWidth:(CGFloat)collectionViewWidth
         referenceExtraHeight:(CGFloat)extraHeight {
    NSLog(@"Warning, you not implement sizeForMessageModel:withCollectionViewWidth:referenceExtraHeight: method for "
          @"you custom cell %@",
          NSStringFromClass(self));
    return CGSizeMake(0, 0);
}

- (void)showBubbleBackgroundView:(BOOL)show {
    self.bubbleBackgroundView.userInteractionEnabled = show;
    if (show){
        [self.messageContentView sendSubviewToBack:self.bubbleBackgroundView];
    }else{
        self.bubbleBackgroundView = nil;
    }
}

#pragma mark - Target Action
- (void)didClickMsgFailedView:(UIButton *)button {
    self.messageFailedStatusView.hidden = YES;
    self.model.msgSentStatus = DC_SentStatus_SENDING;
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(didTapmessageFailedStatusViewForResend:)]) {
            [self.delegate didTapmessageFailedStatusViewForResend:self.model];
        }
    }
}

- (void)didClickMessageHaveReadView:(UIButton *)button {
    
}
- (void)tapUserPortaitEvent:(UIGestureRecognizer *)gestureRecognizer {
    __weak typeof(self) weakSelf = self;
    if ([self.delegate respondsToSelector:@selector(didTapCellPortrait:)]) {
        [self.delegate didTapCellPortrait:weakSelf.model.senderUser.userId];
    }
}

- (void)longPressUserPortaitEvent:(UIGestureRecognizer *)gestureRecognizer {
    __weak typeof(self) weakSelf = self;
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        if ([self.delegate respondsToSelector:@selector(didLongPressCellPortrait:)]) {
            [self.delegate didLongPressCellPortrait:weakSelf.model.senderUser.userId];
        }
    }
}

- (void)longPressedMessageContentView:(id)sender {
    UILongPressGestureRecognizer *press = (UILongPressGestureRecognizer *)sender;
    if (press.state == UIGestureRecognizerStateEnded) {
        return;
    } else if (press.state == UIGestureRecognizerStateBegan) {
        [self.delegate didLongTouchMessageCell:self.model inView:self.messageContentView];
    }
}

- (void)didTapMessageContentView{
    if ([self.delegate respondsToSelector:@selector(didTapMessageCell:)]) {
        [self.delegate didTapMessageCell:self.model];
    }
}

- (void)checkMessageCellClick:(UIButton *)sender {
    if (self.model.is_secret) {
        [MBProgressHUD showTips:@"密聊消息不支持转发"];
        return;
    }
    if ([self.delegate respondsToSelector:@selector(onCheckMessage:isSelect:)]) {
        [self.delegate onCheckMessage:self.model isSelect:!self.model.isSelected];
    }
}

#pragma mark - Getter && Setter
- (UIButton *)messageFailedStatusView{
    if (!_messageFailedStatusView) {
        _messageFailedStatusView = [[UIButton alloc] init];
        [_messageFailedStatusView setImage:[UIImage imageNamed:@"sendMsg_failed_tip"] forState:UIControlStateNormal];
//        _messageFailedStatusView.hidden = YES;
        [_messageFailedStatusView addTarget:self
                                     action:@selector(didClickMsgFailedView:)
                           forControlEvents:UIControlEventTouchUpInside];
    }
    return _messageFailedStatusView;
}

- (UIButton *)messageHaveReadView {
    if (!_messageHaveReadView) {
        _messageHaveReadView = [[UIButton alloc] init];
        [_messageHaveReadView setImage:[UIImage imageNamed:@"msg_read_no"] forState:UIControlStateNormal];
        [_messageHaveReadView setImage:[UIImage imageNamed:@"msg_read"] forState:UIControlStateSelected];
        _messageHaveReadView.hidden = YES;
        [_messageHaveReadView addTarget:self
                                     action:@selector(didClickMessageHaveReadView:)
                           forControlEvents:UIControlEventTouchUpInside];
    }
    return _messageHaveReadView;
}

- (UIImageView *)bubbleBackgroundView{
    if (!_bubbleBackgroundView) {
        _bubbleBackgroundView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self.messageContentView addSubview:self.bubbleBackgroundView];
    }
    return _bubbleBackgroundView;
}

- (UIImageView *)portraitImageView{
    if (!_portraitImageView) {
        _portraitImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"default_portrait_msg"]];
        //点击头像
        UITapGestureRecognizer *portraitTap =
            [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapUserPortaitEvent:)];
        portraitTap.numberOfTapsRequired = 1;
        portraitTap.numberOfTouchesRequired = 1;
        [_portraitImageView addGestureRecognizer:portraitTap];

        UILongPressGestureRecognizer *portraitLongPress =
            [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressUserPortaitEvent:)];
        [_portraitImageView addGestureRecognizer:portraitLongPress];

        _portraitImageView.userInteractionEnabled = YES;
        _portraitImageView.layer.cornerRadius = 10;
        _portraitImageView.layer.masksToBounds = YES;
    }
    return _portraitImageView;
}

- (UILabel *)nicknameLabel{
    if (!_nicknameLabel) {
        _nicknameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _nicknameLabel.backgroundColor = [UIColor clearColor];
        [_nicknameLabel setFont:[UIFont systemFontOfSize:13]];
        [_nicknameLabel
            setTextColor:kTextSubColor];
        _nicknameLabel.text = @"昵称昵称昵称昵称";
    }
    return _nicknameLabel;
}


- (UIView *)statusContentView{
    if (!_statusContentView) {
        _statusContentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, StatusContentViewWidth, StatusContentViewWidth)];
    }
    return _statusContentView;
}

- (UIView *)messageContentView {
    if (!_messageContentView) {
        _messageContentView = [[UIView alloc] init];
        UILongPressGestureRecognizer *longPress =
        [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressedMessageContentView:)];
        [_messageContentView addGestureRecognizer:longPress];
//        _messageContentView.backgroundColor = kBackgroundColor;

        UITapGestureRecognizer *tap =
            [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapMessageContentView)];
        tap.numberOfTapsRequired = 1;
        tap.numberOfTouchesRequired = 1;
        [_messageContentView addGestureRecognizer:tap];
        _messageContentView.userInteractionEnabled = YES;
    }
    return _messageContentView;
}

- (UIActivityIndicatorView *)messageActivityIndicatorView {
    if (!_messageActivityIndicatorView) {
        if (@available(iOS 13.0, *)) {
            _messageActivityIndicatorView =
                [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
        } else {
            _messageActivityIndicatorView =
                [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        }
         _messageActivityIndicatorView.hidden = YES;
    }
    return _messageActivityIndicatorView;
}


- (UILabel *)msgTimeLabel {
    if (!_msgTimeLabel) {
        _msgTimeLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        _msgTimeLabel.font = kFontSize(12);
        _msgTimeLabel.textColor = kTextSubColor;
        _msgTimeLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _msgTimeLabel;
}

- (UIButton *)checkView {
    if (!_checkView) {
        _checkView = [[UIButton alloc]initWithFrame:CGRectZero];
        _checkView.backgroundColor = kBackgroundColor;
        [_checkView setImage:[UIImage imageNamed:@"round_unselected"] forState:UIControlStateNormal];
        [_checkView setImage:[UIImage imageNamed:@"round_selected"] forState:UIControlStateSelected];
        [_checkView addTarget:self action:@selector(checkMessageCellClick:) forControlEvents:UIControlEventTouchUpInside];
        _checkView.hidden = YES;
    }
    return _checkView;
}
@end
