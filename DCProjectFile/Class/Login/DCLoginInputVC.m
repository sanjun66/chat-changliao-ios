//
//  DCLoginInputVC.m
//  DCProjectFile
//
//  Created  on 2023/5/17.
//

#import "DCLoginInputVC.h"
#import "DCTabBarController.h"
#import "DCPasswordSetVC.h"
#import <JPUSHService.h>


@interface DCLoginInputVC ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UILabel *titLabel;

@property (weak, nonatomic) IBOutlet UIView *accountView;
@property (weak, nonatomic) IBOutlet UIView *ancillaryView;
@property (weak, nonatomic) IBOutlet UITextField *accountTF;
@property (weak, nonatomic) IBOutlet UITextField *ancillaryTF;

@property (weak, nonatomic) IBOutlet UIButton *accImg;
@property (weak, nonatomic) IBOutlet UIButton *anciImg;

@property (weak, nonatomic) IBOutlet UIButton *showPwdBtn;
@property (weak, nonatomic) IBOutlet UIButton *codeBtn;
@property (weak, nonatomic) IBOutlet UIButton *forgetBtn;
@property (weak, nonatomic) IBOutlet UIView *protocolView;

@property (weak, nonatomic) IBOutlet UIButton *exchangeBtn;

@property (nonatomic, strong) YYTimer *timer;

@property (nonatomic, assign) int downIndex;

@property (strong, nonatomic) UIButton *checkBox;

@property (weak, nonatomic) IBOutlet UIImageView *logoIcon;

@end

@implementation DCLoginInputVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.logoIcon.image = [UIImage imageNamed:@"luanch_icon"];
    [self setup];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (textField == self.accountTF) {
        self.accountView.borderColor = KSelectBorderColor;
        self.accountView.borderWidth = 1;
    }
    if (textField == self.ancillaryTF) {
        self.ancillaryView.borderColor = KSelectBorderColor;
        self.ancillaryView.borderWidth = 1;
    }
    return YES;
}
- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField == self.accountTF) {
        self.accountView.borderColor = kNormalBorderColor;
        self.accountView.borderWidth = 0.5;
    }
    if (textField == self.ancillaryTF) {
        self.ancillaryView.borderColor = kNormalBorderColor;
        self.ancillaryView.borderWidth = 0.5;
    }
}
- (void)setup {
    self.accountTF.delegate = self;
    self.ancillaryTF.delegate = self;
    
    self.accountTF.keyboardType = self.isEmail?UIKeyboardTypeDefault:UIKeyboardTypeNumberPad;
    self.titLabel.text = self.isEmail?@"使用邮箱账号登录":@"使用手机号码登录";
    self.accountTF.placeholder = self.isEmail?@"请输入邮箱账号":@"请输入手机号码";
    [self.accImg setImage:[UIImage imageNamed:self.isEmail?@"login_input_email":@"login_input_phone"] forState:UIControlStateNormal];
    self.ancillaryTF.secureTextEntry = YES;
    [self setupViews];
    [self exchangeLoginMethod:self.exchangeBtn];
}
- (IBAction)getVerificationCode:(UIButton *)sender {
    if (self.isEmail && ![DCTools isValidateEmail:self.accountTF.text]) {
        [MBProgressHUD showTips:@"请输入正确的邮箱"];
        return;
    }
    
    if (!self.isEmail && ![DCTools isValidateMobile:self.accountTF.text]) {
        [MBProgressHUD showTips:@"请输入正确的手机号"];
        return;
    }
    [self requestForCode];
    
}

- (void)timerVerificationCode {
    self.downIndex --;
    [self.codeBtn setTitle:[NSString stringWithFormat:@"%ds后重发",self.downIndex] forState:UIControlStateNormal];
    if (self.downIndex <= 0) {
        [self.timer invalidate];
        self.timer = nil;
        [self.codeBtn setTitle:@"发送验证码" forState:UIControlStateNormal];
        
        self.codeBtn.backgroundColor = kNormalBackColor;
        self.codeBtn.selected = NO;
        self.codeBtn.userInteractionEnabled = YES;
    }
}

- (IBAction)forgetPassword:(UIButton *)sender {
    DCPasswordSetVC *vc = [[DCPasswordSetVC alloc]init];
    vc.isEmail = self.isEmail;
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)exchangeLoginMethod:(UIButton *)sender {
    sender.selected = !sender.selected;
    
    self.showPwdBtn.hidden = sender.selected;
    self.showPwdBtn.selected = NO;
    self.forgetBtn.hidden = sender.selected;
    self.codeBtn.hidden = !sender.selected;
    
    self.ancillaryTF.keyboardType = sender.selected?UIKeyboardTypeNumberPad:UIKeyboardTypeDefault;
    self.ancillaryTF.secureTextEntry = !sender.selected;
    self.ancillaryTF.text = @"";
    self.ancillaryTF.placeholder = sender.selected?@"请输入验证码":@"请输入密码";
    [self.anciImg setImage:[UIImage imageNamed:sender.isSelected?@"login_input_code":@"login_input_pwd"] forState:UIControlStateNormal];
}
- (IBAction)showPwdBtnClick:(UIButton *)sender {
    sender.selected = !sender.selected;
    self.ancillaryTF.secureTextEntry = !sender.selected;
}

- (IBAction)loginComfirmed:(UIButton *)sender {
    if (!self.checkBox.isSelected) {
        [MBProgressHUD showTips:@"请阅读并同意下方协议"];
        return;
    }

    if (![DCTools isEmpty:self.accountTF.text] && ![DCTools isEmpty:self.ancillaryTF.text]) {
        [self netRequestForLogin];
    }
    
}

- (void)requestForCode {
    NSString *area = @"86";
    NSString *account = self.accountTF.text;
    NSString *type = self.isEmail?@"email":@"phone";
    NSString *sms_type = @"login";
    
    [[DCRequestManager sharedManager] requestWithMethod:@"POST" url:@"api/sms" parameters:@{@"area":area , @"account":account,@"type":type,@"sms_type":sms_type} success:^(id  _Nullable result) {
        self.codeBtn.backgroundColor = KSelectBackColor;
        self.codeBtn.selected = YES;
        self.codeBtn.userInteractionEnabled = NO;
        self.downIndex = 60;
        self.timer = [YYTimer timerWithTimeInterval:1 target:self selector:@selector(timerVerificationCode) repeats:YES];
        [self.timer fire];
    } failure:^(NSError * _Nonnull error) {
        
    }];
    
}

- (void)netRequestForLogin {
    NSMutableDictionary *parms = [NSMutableDictionary dictionary];
    [parms setObject:self.accountTF.text forKey:(self.isEmail?@"email":@"phone")];
    [parms setObject:self.ancillaryTF.text forKey:(self.exchangeBtn.isSelected?@"code":@"password")];
    [parms setObject:(self.exchangeBtn.isSelected?@"2":@"1") forKey:@"type"];
    [parms setObject:(self.isEmail?@"email":@"phone") forKey:@"login_way"];
    [parms setObject:@"ios" forKey:@"platform"];
    if (!self.isEmail) {
        [parms setObject:@"86" forKey:@"area_code"];
    }
    NSString *registrationID = [JPUSHService registrationID];
    [parms setObject:registrationID?registrationID:@"" forKey:@"registration_id"];
    [MBProgressHUD showActivity];
    [[DCRequestManager sharedManager] requestWithMethod:@"POST" url:@"api/login" parameters:parms success:^(id  _Nullable result) {
        DCStoreModel *model = [DCStoreModel modelWithDictionary:result];
        [[DCUserManager sharedManager] saveUser:model];
        [[DCUserManager sharedManager] resetRootVc];
        [[RCIMClient sharedRCIMClient]connectWithToken:model.rong_yun_token dbOpened:^(RCDBErrorCode code) {
        } success:^(NSString * _Nonnull userId) {
            [[RCIMClient sharedRCIMClient] disconnect];
        } error:^(RCConnectErrorCode errorCode) {

        }];
    } failure:^(NSError * _Nonnull error) {
        [MBProgressHUD hideActivity];
    }];
    
}


- (void)setupViews {
    NSMutableAttributedString *atts = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"登录代表您已同意%@《用户协议》和《隐私政策》",kAppName] attributes:@{NSFontAttributeName:kFontSize(12) , NSForegroundColorAttributeName:kTextSubColor}];
    
    [atts setTextHighlightRange:[atts.string rangeOfString:@"《用户协议》"] color:kMainColor backgroundColor:kWhiteColor tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
            
    }];
    
    [atts setTextHighlightRange:[atts.string rangeOfString:@"《隐私政策》"] color:kMainColor backgroundColor:kWhiteColor tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
            
    }];
    
    YYLabel *agreementLabel = [[YYLabel alloc]init];
    agreementLabel.attributedText = atts;
    agreementLabel.textAlignment = NSTextAlignmentLeft;
    agreementLabel.frame = CGRectMake(kScreenWidth/2-155+12, 10, 310, 20);
    [self.protocolView addSubview:agreementLabel];
    
    
    self.checkBox = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.checkBox setImage:[UIImage imageNamed:@"log_m_check"] forState:UIControlStateNormal];
    [self.checkBox setImage:[UIImage imageNamed:@"login_input_checkSel"] forState:UIControlStateSelected];
    [self.checkBox addTarget:self action:@selector(checkBoxAction:) forControlEvents:UIControlEventTouchUpInside];
//    self.checkBox.selected = YES;
    [self.protocolView addSubview:self.checkBox];
    [self.checkBox mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo (agreementLabel);
        make.right.equalTo (agreementLabel.mas_left);
        make.size.mas_equalTo (24);
    }];
}


- (void)checkBoxAction:(UIButton *)sender {
    sender.selected = !sender.selected;
}
@end
