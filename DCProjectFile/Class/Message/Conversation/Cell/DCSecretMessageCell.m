//
//  DCSecretMessageCell.m
//  DCProjectFile
//
//  Created  on 2023/7/28.
//

#import "DCSecretMessageCell.h"
#import "DCMessagePswInputAlert.h"

#define SECRET_CONTENT_HEIGHT 40.f
@interface DCSecretMessageCell ()
@property (nonatomic, strong) UIVisualEffectView *visualEffectView;
@property (nonatomic, strong) UIButton *textLabel;

@end

@implementation DCSecretMessageCell
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)initialize {
    [self showBubbleBackgroundView:NO];
    
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    self.visualEffectView = [[UIVisualEffectView alloc]initWithEffect:blurEffect];
    self.visualEffectView.layer.cornerRadius = 10;
    self.visualEffectView.layer.masksToBounds = YES;
    [self.messageContentView addSubview:self.visualEffectView];
    
    self.textLabel = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.textLabel setTitle:@"密聊消息" forState:UIControlStateNormal];
    [self.textLabel setTitleColor:kWhiteColor forState:UIControlStateNormal];
    self.textLabel.titleLabel.font = kFontSize(16);
    [self.textLabel setImage:[UIImage imageNamed:@"call_lock"] forState:UIControlStateNormal];
    self.textLabel.userInteractionEnabled = NO;
    [self.textLabel setTitleEdgeInsets:UIEdgeInsetsMake(0, 5, 0, 0)];
    [self.textLabel setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 5)];
    [self.messageContentView addSubview:self.textLabel];
    
    UITapGestureRecognizer *ges = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onTapSecretMsgCell:)];
    [self.messageContentView addGestureRecognizer:ges];
}

- (void)onTapSecretMsgCell:(UITapGestureRecognizer *)ges {
    if (ges.state == UIGestureRecognizerStateEnded) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kMessagePswInputAlertWillShowNotification object:nil];
        DCMessagePswInputAlert *alert = [DCMessagePswInputAlert xib];
        alert.isMaker = YES;
        alert.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
        [[UIApplication sharedApplication].keyWindow.rootViewController.view addSubview:alert];
        [DCTools animationForView:alert.backView];
        [alert.sectetField becomeFirstResponder];
        alert.inputAlertComplete = ^(NSString * _Nullable text) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kMessagePswInputAlertDidRemoveNotification object:nil];
            if (text != nil) {
                if ([self.delegate respondsToSelector:@selector(didTapSecretMessage:inputPwd:)]) {
                    [self.delegate didTapSecretMessage:self.model inputPwd:text];
                }
            }
        };
    }
}

- (void)setDataModel:(DCMessageContent *)model {
    [super setDataModel:model];
    self.nicknameLabel.hidden = (self.model.conversationType==DC_ConversationType_PRIVATE || self.model.messageDirection == DC_MessageDirection_SEND);
    
    CGRect rect = self.messageContentView.frame;
    rect.size = CGSizeMake(118, SECRET_CONTENT_HEIGHT);
    self.messageContentView.frame = rect;
    
    self.visualEffectView.frame = self.messageContentView.bounds;
    self.textLabel.frame = self.messageContentView.bounds;
    [self setCellAutoLayout];
}
+ (CGSize)sizeForMessageModel:(DCMessageContent *)model withCollectionViewWidth:(CGFloat)collectionViewWidth referenceExtraHeight:(CGFloat)extraHeight {
    return CGSizeMake(collectionViewWidth, SECRET_CONTENT_HEIGHT+extraHeight + (model.isDisplayMsgTime?20:0) +((model.conversationType==DC_ConversationType_GROUP && model.messageDirection==DC_MessageDirection_RECEIVE)?20:0));
}
@end
