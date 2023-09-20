//
//  DCCallWaitingView.m
//  DCProjectFile
//
//  Created  on 2023/7/25.
//

#import "DCCallWaitingView.h"
@interface DCCallWaitingView ()
@property (weak, nonatomic) IBOutlet UIView *backgroundView;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;

@property (weak, nonatomic) IBOutlet UIButton *controlButton;
@property (weak, nonatomic) IBOutlet UIImageView *avatar;
@property (weak, nonatomic) IBOutlet UILabel *nicknameLabel;
@property (weak, nonatomic) IBOutlet UILabel *stateLabel;

@property (weak, nonatomic) IBOutlet UIButton *acceptBtn;
@property (weak, nonatomic) IBOutlet UIButton *refuseBtn;
@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;

@property (weak, nonatomic) IBOutlet UIView *inviteMemberView;
@end

@implementation DCCallWaitingView

- (void)setMembers:(NSArray<DCUserInfo *> *)members {
    if (members.count==0) return;
    
    _members = members;
    self.acceptBtn.hidden = YES;
    self.refuseBtn.hidden = YES;
    self.cancelBtn.hidden = NO;
    
    DCUserInfo *user = members.firstObject;
    [self.avatar sd_setImageWithURL:[NSURL URLWithString:user.portraitUri]];
    self.nicknameLabel.text = user.name;
    self.stateLabel.text = @"等待对方同意...";
    if (self.conferenceType == QBRTCConferenceTypeAudio) {
        self.backgroundView.hidden = NO;
        [self.backgroundImageView sd_setImageWithURL:[NSURL URLWithString:user.portraitUri]];
    }
}

- (void)setFromUid:(NSString *)fromUid {
    if ([DCTools isEmpty:fromUid]) return;
    
    _fromUid = fromUid;
    self.acceptBtn.hidden = NO;
    self.refuseBtn.hidden = NO;
    self.cancelBtn.hidden = YES;
    [[DCUserManager sharedManager] getConversationData:DC_ConversationType_PRIVATE targerId:fromUid completion:^(DCUserInfo * _Nonnull userInfo) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.avatar sd_setImageWithURL:[NSURL URLWithString:userInfo.portraitUri]];
            self.nicknameLabel.text = userInfo.name;
            self.stateLabel.text = @"邀请您通话...";
            if (self.isMultit) {
                self.stateLabel.text = @"邀请您加入多人通话...";
            }
            if (self.conferenceType == QBRTCConferenceTypeAudio || self.isMultit) {
                self.backgroundView.hidden = NO;
                [self.backgroundImageView sd_setImageWithURL:[NSURL URLWithString:userInfo.portraitUri]];
            }
            
        });
    }];
}

- (void)setInviteMembers:(NSArray<DCUserInfo *> *)inviteMembers {
    self.inviteMemberView.hidden = NO;
    CGFloat superWidth = kScreenWidth-40;
    CGFloat size_t = 30.f;
    CGFloat speace = 5.f;
    
    CGFloat startX = (superWidth - inviteMembers.count * (size_t+speace) + speace)/2;
    
    [inviteMembers enumerateObjectsUsingBlock:^(DCUserInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIImageView *item = [[UIImageView alloc]initWithFrame:CGRectMake(startX + (size_t+speace)*idx, 36, size_t, size_t)];
        item.layer.cornerRadius = 5;
        item.layer.masksToBounds = YES;
        [self.inviteMemberView addSubview:item];
        
        [[DCUserManager sharedManager] getConversationData:DC_ConversationType_PRIVATE targerId:obj.userId completion:^(DCUserInfo * _Nonnull userInfo) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [item sd_setImageWithURL:[NSURL URLWithString:userInfo.portraitUri]];
            });
        }];
    }];
}

- (void)setConferenceType:(QBRTCConferenceType)conferenceType {
    _conferenceType = conferenceType;
}

- (void)hideSubviews {
    self.acceptBtn.hidden = YES;
    self.refuseBtn.hidden = YES;
    self.cancelBtn.hidden = YES;
    self.stateLabel.hidden = YES;
}

- (IBAction)acceptClick:(id)sender {
    if ([self.delegate respondsToSelector:@selector(waitingViewOnAcceptCall)]) {
        [self.delegate waitingViewOnAcceptCall];
    }
}
- (IBAction)refuseClick:(id)sender {
    if ([self.delegate respondsToSelector:@selector(waitingViewOnRefuseCall)]) {
        [self.delegate waitingViewOnRefuseCall];
    }
}

- (IBAction)cancelClick:(id)sender {
    if ([self.delegate respondsToSelector:@selector(waitingViewOnCancelCall)]) {
        [self.delegate waitingViewOnCancelCall];
    }
}
- (IBAction)controllerButtonClick:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(waitingViewOnTapControll)]) {
        [self.delegate waitingViewOnTapControll];
    }
}

@end
