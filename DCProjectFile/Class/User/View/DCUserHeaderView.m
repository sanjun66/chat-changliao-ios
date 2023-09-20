//
//  DCUserHeaderView.m
//  DCProjectFile
//
//  Created  on 2023/5/29.
//

#import "DCUserHeaderView.h"
#import "DCMineInfoModel.h"

@interface DCUserHeaderView ()
@property (weak, nonatomic) IBOutlet UIImageView *avatar;
@property (weak, nonatomic) IBOutlet UILabel *showName;
@property (weak, nonatomic) IBOutlet UILabel *nickname;
@property (weak, nonatomic) IBOutlet UILabel *account;
@property (weak, nonatomic) IBOutlet UIImageView *genderIcon;
@end

@implementation DCUserHeaderView

- (void)awakeFromNib {
    [super awakeFromNib];
    UILongPressGestureRecognizer *ges = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longTapAccountGes:)];
    self.account.userInteractionEnabled = YES;
    [self.account addGestureRecognizer:ges];
}
- (void)longTapAccountGes:(UILongPressGestureRecognizer*)ges {
    if (self.isFromGroupChat) {return;}
    if (ges.state == UIGestureRecognizerStateBegan) {
        UIPasteboard *pas = [UIPasteboard generalPasteboard];
        pas.string = ([DCTools isEmpty:self.infoModel.phone]?self.infoModel.email:self.infoModel.phone);
        [MBProgressHUD showTips:@"复制成功"];
    }
}
- (void)setInfoModel:(DCMineInfoModel *)infoModel {
    _infoModel = infoModel;
    [self.avatar sd_setImageWithURL:[NSURL URLWithString:self.infoModel.avatar]];
    if ([DCTools isEmpty:self.infoModel.note_name]) {
        self.showName.text = self.infoModel.nick_name;
    }else {
        self.showName.text = self.infoModel.note_name;
    }
    
    self.nickname.text = [NSString stringWithFormat:@"昵称：%@",self.infoModel.nick_name];
    NSString *userAccount = ([DCTools isEmpty:self.infoModel.phone]?self.infoModel.email:self.infoModel.phone);
    if (self.isFromGroupChat) {
        NSUInteger textLength = userAccount.length;
        if (textLength > 4) {
            NSInteger startPoint = floorf(textLength/2.f-2);
            userAccount =  [userAccount stringByReplacingCharactersInRange:NSMakeRange(startPoint, 4) withString:@"****"];
        }else {
            userAccount = @"****";
        }
    }
    self.account.text = [NSString stringWithFormat:@"账号:%@",userAccount];
    
    if (self.infoModel.sex==1) {
        self.genderIcon.image = [UIImage imageNamed:@"icon_nan"];
    }else if (self.infoModel.sex==2) {
        self.genderIcon.image = [UIImage imageNamed:@"icon_nv"];
    }else {
        self.genderIcon.image = nil;
    }
    
}
@end
