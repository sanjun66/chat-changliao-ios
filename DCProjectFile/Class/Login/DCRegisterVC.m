//
//  DCRegisterVC.m
//  DCProjectFile
//
//  Created  on 2023/5/22.
//

#import "DCRegisterVC.h"

@interface DCRegisterVC ()
@property (weak, nonatomic) IBOutlet UITextField *accountTF;
@property (weak, nonatomic) IBOutlet UILabel *titLabel;
@property (weak, nonatomic) IBOutlet UIButton *codeBtn;

@property (nonatomic, strong) YYTimer *timer;
@property (nonatomic, assign) int downIndex;

@end

@implementation DCRegisterVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setup];
}
- (IBAction)getCodeClick:(UIButton *)sender {
    sender.enabled = NO;
    self.downIndex = 60;
    
    self.timer = [YYTimer timerWithTimeInterval:1 target:self selector:@selector(timerVerificationCode) repeats:YES];
    [self.timer fire];
    
}
- (void)timerVerificationCode {
    self.downIndex --;
    [self.codeBtn setTitle:[NSString stringWithFormat:@"%ds",self.downIndex] forState:UIControlStateNormal];
    if (self.downIndex <= 0) {
        [self.timer invalidate];
        self.timer = nil;
        self.codeBtn.enabled = YES;
        [self.codeBtn setTitle:@"验证码" forState:UIControlStateNormal];
    }
}
- (IBAction)registBtnClick:(id)sender {
    [MBProgressHUD showTips:@"注册成功"];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setup {
    self.accountTF.keyboardType = self.isEmail?UIKeyboardTypeDefault:UIKeyboardTypeNumberPad;
    self.titLabel.text = self.isEmail?@"使用邮箱账号注册":@"使用手机号码注册";
    self.accountTF.placeholder = self.isEmail?@"请输入邮箱账号":@"请输入手机号码";
    
}
@end
