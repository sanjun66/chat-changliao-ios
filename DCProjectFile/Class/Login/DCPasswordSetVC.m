//
//  DCPasswordSetVC.m
//  DCProjectFile
//
//  Created  on 2023/5/24.
//

#import "DCPasswordSetVC.h"

@interface DCPasswordSetVC ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIView *accountView;
@property (weak, nonatomic) IBOutlet UIView *codeView;
@property (weak, nonatomic) IBOutlet UIView *pwdView;
@property (weak, nonatomic) IBOutlet UIView *confirmView;

@property (weak, nonatomic) IBOutlet UITextField *accountTF;
@property (weak, nonatomic) IBOutlet UIButton *codeBtn;

@property (weak, nonatomic) IBOutlet UITextField *codeTF;
@property (weak, nonatomic) IBOutlet UITextField *pswTF;
@property (weak, nonatomic) IBOutlet UITextField *confirmTF;


@property (nonatomic, strong) YYTimer *timer;
@property (nonatomic, assign) int downIndex;
@end

@implementation DCPasswordSetVC
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setup];
}

- (IBAction)showPwdClick:(UIButton *)sender {
    sender.selected = !sender.selected;
    self.pswTF.secureTextEntry = !sender.selected;
}
- (IBAction)showCinfirmClick:(UIButton *)sender {
    sender.selected = !sender.selected;
    self.confirmTF.secureTextEntry = !sender.selected;
}

- (IBAction)getCodeClick:(UIButton *)sender {
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
- (IBAction)sureClick:(id)sender {
    if (self.isEmail && ![DCTools isValidateEmail:self.accountTF.text]) {
        [MBProgressHUD showTips:@"请输入正确的邮箱"];
        return;
    }
    
    if (!self.isEmail && ![DCTools isValidateMobile:self.accountTF.text]) {
        [MBProgressHUD showTips:@"请输入正确的手机号"];
        return;
    }
    if ([DCTools isEmpty:self.codeTF.text]) {
        [MBProgressHUD showTips:@"请输入验证码"];
        return;
    }
    if (self.pswTF.text.length < 6) {
        [MBProgressHUD showTips:@"请输入至少6位密码"];
        return;
    }
    
    if (![self.pswTF.text isEqualToString:self.confirmTF.text]) {
        [MBProgressHUD showTips:@"两次输入不一致"];
        return;
    }
    [self requestForPswReset];
}
- (void)requestForCode {
    NSString *area = @"86";
    NSString *account = self.accountTF.text;
    NSString *type = self.isEmail?@"email":@"phone";
    NSString *sms_type = @"forget";
    
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

- (void)requestForPswReset {
    NSString *area_code = @"86";
    NSString *login_way = self.isEmail?@"email":@"phone";
    
    [[DCRequestManager sharedManager] requestWithMethod:@"POST" url:@"api/forgetPassword" parameters:@{@"login_way":login_way , @"password":self.pswTF.text , @"code":self.codeTF.text , login_way:self.accountTF.text , @"area_code":area_code} success:^(id  _Nullable result) {
        [MBProgressHUD showTips:@"修改密码成功"];
        if (self.isLoginAlso) {
            [[DCUserManager sharedManager] cleanUser];
            [[DCUserManager sharedManager] resetRootVc];
            return;
        }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.navigationController popViewControllerAnimated:YES];
        });
    } failure:^(NSError * _Nonnull error) {
        
    }];
}
- (void)setup {
    self.accountTF.keyboardType = self.isEmail?UIKeyboardTypeDefault:UIKeyboardTypeNumberPad;
    self.accountTF.placeholder = self.isEmail?@"请输入邮箱账号":@"请输入手机号码";
    self.accountTF.delegate = self.codeTF.delegate = self.pswTF.delegate = self.confirmTF.delegate = self;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (textField == self.accountTF) {
        self.accountView.borderColor = KSelectBorderColor;
        self.accountView.borderWidth = 1;
    }
    if (textField == self.codeTF) {
        self.codeView.borderColor = KSelectBorderColor;
        self.codeView.borderWidth = 1;
    }
    if (textField == self.pswTF) {
        self.pwdView.borderColor = KSelectBorderColor;
        self.pwdView.borderWidth = 1;
    }
    if (textField == self.confirmTF) {
        self.confirmView.borderColor = KSelectBorderColor;
        self.confirmView.borderWidth = 1;
    }
    return YES;
}
- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField == self.accountTF) {
        self.accountView.borderColor = kNormalBorderColor;
        self.accountView.borderWidth = 0.5;
    }
    if (textField == self.codeTF) {
        self.codeView.borderColor = kNormalBorderColor;
        self.codeView.borderWidth = 0.5;
    }
    
    if (textField == self.pswTF) {
        self.pwdView.borderColor = kNormalBorderColor;
        self.pwdView.borderWidth = 0.5;
    }
    if (textField == self.confirmTF) {
        self.confirmView.borderColor = kNormalBorderColor;
        self.confirmView.borderWidth = 0.5;
    }
    
}

@end
