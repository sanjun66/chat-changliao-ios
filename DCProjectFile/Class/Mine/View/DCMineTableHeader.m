//
//  DCMineTableHeader.m
//  DCProjectFile
//
//  Created  on 2023/5/24.
//

#import "DCMineTableHeader.h"
#import "DCInfoEditVC.h"
@interface DCMineTableHeader ()
@property (weak, nonatomic) IBOutlet UIImageView *userAvatar;
@property (weak, nonatomic) IBOutlet UILabel *nicknameLabel;

@property (weak, nonatomic) IBOutlet UIView *accountView;
@property (weak, nonatomic) IBOutlet UILabel *accountTitle;
@property (weak, nonatomic) IBOutlet UILabel *accountDesc;

@end

@implementation DCMineTableHeader

- (void)awakeFromNib {
    [super awakeFromNib];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAccountGes:)];
    [self.accountView addGestureRecognizer:tap];
    
    UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapPortraitGes:)];
    [self.userAvatar addGestureRecognizer:tap1];
    
    [self.userAvatar sd_setImageWithURL:[NSURL URLWithString:[DCUserManager sharedManager].currentUserInfo.portraitUri]];
    self.nicknameLabel.text = [DCUserManager sharedManager].currentUserInfo.name;
}

- (void)setInfoModel:(DCMineInfoModel *)infoModel {
    _infoModel = infoModel;
    [self.userAvatar sd_setImageWithURL:[NSURL URLWithString:infoModel.avatar] placeholderImage:kPlaceholderImage];
    self.nicknameLabel.text = infoModel.nick_name;
//    self.accountTitle.text = [NSString stringWithFormat:@"ID:%@",infoModel.uid];
    self.accountTitle.text = @"";
    self.accountDesc.text = [NSString stringWithFormat:@"账号:%@",([DCTools isEmpty:infoModel.phone]?infoModel.email:infoModel.phone)];
}

- (void)tapAccountGes:(UITapGestureRecognizer *)ges {
    if (!self.infoModel) {return;}
    if (ges.state == UIGestureRecognizerStateEnded) {
        [[DCTools topViewController] presentViewController:[DCTools actionSheet:@[@"复制账号"] complete:^(int idx) {
            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
            pasteboard.string = ([DCTools isEmpty:self.infoModel.phone]?self.infoModel.email:self.infoModel.phone);
            [MBProgressHUD showTips:@"复制成功"];
        }] animated:YES completion:nil];
    }
}
- (void)tapPortraitGes:(UITapGestureRecognizer *)ges {
    if (!self.infoModel) {return;}
    if (ges.state == UIGestureRecognizerStateEnded) {
        DCInfoEditVC *vc = [[DCInfoEditVC alloc]init];
        vc.infoModel = self.infoModel;
        [[DCTools navigationViewController] pushViewController:vc animated:YES];
    }
}
@end
