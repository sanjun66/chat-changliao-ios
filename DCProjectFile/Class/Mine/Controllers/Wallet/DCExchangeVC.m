//
//  DCExchangeVC.m
//  DCProjectFile
//
//  Created  on 2023/9/15.
//

#import "DCExchangeVC.h"
#import "SCQRCodeVC.h"
#import "DCMineInfoModel.h"
#import "YBPopupMenu.h"

@interface DCExchangeVC ()<YBPopupMenuDelegate>
@property (weak, nonatomic) IBOutlet UITextView *addressTextView;
@property (weak, nonatomic) IBOutlet UITextField *amountTextField;
@property (weak, nonatomic) IBOutlet UILabel *totalLabel;
@property (weak, nonatomic) IBOutlet UILabel *coinLabel;
@property (weak, nonatomic) IBOutlet UITextField *codeTextField;

@property (weak, nonatomic) IBOutlet UIButton *codeButton;

@property (nonatomic, strong) YYTimer *timer;

@property (nonatomic, assign) int downIndex;
@property (nonatomic, strong) NSMutableArray *coinTypeArray;
@property (nonatomic, strong) YBPopupMenu *menu;
@property (nonatomic, strong) NSMutableArray *historyArray;
@end

@implementation DCExchangeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.title = @"提现";
    self.coinTypeArray = [NSMutableArray array];
    self.historyArray = [NSMutableArray array];
    self.addressTextView.placeholder = @"请输入收款地址";
    self.addressTextView.placeholderColor = RGB(197, 197, 199);
    self.totalLabel.text = [NSString stringWithFormat:@"%@ %@",self.walletModel.balance,self.walletModel.coin];
    [self requestCoinType];
}

- (void)requestCoinType {
    [[DCRequestManager sharedManager] requestWithMethod:@"POST" url:@"api/getCoinType" parameters:nil success:^(id  _Nullable result) {
        if ([result isKindOfClass:[NSArray class]]) {
            [self.coinTypeArray addObjectsFromArray:(NSArray*)result];
            self.coinLabel.text = [NSString stringWithFormat:@"%@",self.coinTypeArray.firstObject];
        }
    } failure:^(NSError * _Nonnull error) {
        
    }];
}

- (IBAction)walletClick:(UIButton *)sender {
    [[DCRequestManager sharedManager] requestWithMethod:@"POST" url:@"api/withdrawAddress" parameters:nil success:^(id  _Nullable result) {
        if ([result isKindOfClass:[NSArray class]]) {
            NSArray *array = (NSArray*)result;
            if (array.count<=0){
                return;
            }
            [self.historyArray removeAllObjects];
            [self.historyArray addObjectsFromArray:array];
            
            self.menu = [YBPopupMenu showRelyOnView:sender titles:array icons:nil menuWidth:240 otherSettings:^(YBPopupMenu *popupMenu) {
                popupMenu.backColor = kWhiteColor;
                popupMenu.textColor = kTextSubColor;
                popupMenu.font = kNameSize(@"PingFangSC-Medium", 14);
                popupMenu.maxVisibleCount = 4;
                popupMenu.isShowShadow = NO;
                popupMenu.cornerRadius = 3;
                popupMenu.height = 200;
                popupMenu.animationManager.style = YBPopupMenuAnimationStyleScale;
                popupMenu.arrowWidth = 0;
                popupMenu.arrowHeight = 0;
                popupMenu.offset = 16;
                popupMenu.itemHeight = 50;
                popupMenu.delegate = self;
                popupMenu.animationManager.style = YBPopupMenuAnimationStyleNone;
            }];
        }
    } failure:^(NSError * _Nonnull error) {
        
    }];
}
- (IBAction)scanClick:(id)sender {
    SCQRCodeVC *vc = [[SCQRCodeVC alloc]init];
    vc.scanBlock = ^(NSString * _Nonnull result) {
        self.addressTextView.text = result;
    };
    [self.navigationController pushViewController:vc animated:YES];
}
- (IBAction)typeClick:(UIButton *)sender {
    if (self.coinTypeArray.count <= 1) {return;}
    [YBPopupMenu showRelyOnView:sender titles:self.coinTypeArray icons:nil menuWidth:120 otherSettings:^(YBPopupMenu *popupMenu) {
        popupMenu.backColor = kWhiteColor;
        popupMenu.textColor = kTextTitColor;
        popupMenu.font = kNameSize(@"PingFangSC-Medium", 15);
        popupMenu.maxVisibleCount = 4;
        popupMenu.isShowShadow = NO;
        popupMenu.cornerRadius = 3;
        popupMenu.height = 200;
        popupMenu.animationManager.style = YBPopupMenuAnimationStyleScale;
        popupMenu.arrowWidth = 0;
        popupMenu.arrowHeight = 0;
        popupMenu.offset = 16;
        popupMenu.itemHeight = 50;
        popupMenu.delegate = self;
        popupMenu.animationManager.style = YBPopupMenuAnimationStyleNone;
    }];
}
- (void)ybPopupMenu:(YBPopupMenu *)ybPopupMenu didSelectedAtIndex:(NSInteger)index {
    if (ybPopupMenu==self.menu) {
        self.addressTextView.text = self.historyArray[index];
    }else {
        self.coinLabel.text = self.coinTypeArray[index];
    }
}
- (IBAction)allinClick:(id)sender {
    if ([self.walletModel.balance floatValue] > 0) {
        self.amountTextField.text = self.walletModel.balance;
    }else {
        self.amountTextField.text = @"0";
    }
}
- (IBAction)codeClick:(id)sender {
    [self requestForCode];
}
- (IBAction)sureClick:(id)sender {
    if ([DCTools isEmpty:self.addressTextView.text]) {
        [MBProgressHUD showTips:@"收款地址不能为空"];
        return;
    }
    if ([DCTools isEmpty:self.amountTextField.text]) {
        [MBProgressHUD showTips:@"提现数量不能为空"];
        return;
    }
    
    if ([self.amountTextField.text floatValue] <= 0) {
        [MBProgressHUD showTips:@"提现数量应大于0"];
        return;
    }
    
    if ([DCTools isEmpty:self.codeTextField.text]) {
        [MBProgressHUD showTips:@"验证码不能为空"];
        return;
    }
    NSDictionary *parms = @{
        @"address":self.addressTextView.text ,
        @"num":self.amountTextField.text ,
        @"currency":[DCTools isEmpty:self.coinLabel.text]?self.walletModel.coin:self.coinLabel.text,
        @"code":self.codeTextField.text
    };
    
    [[DCRequestManager sharedManager] requestWithMethod:@"POST" url:@"api/withdraw" parameters:parms success:^(id  _Nullable result) {
        [MBProgressHUD showTips:@"提现成功"];
        [[DCRequestManager sharedManager] requestWithMethod:@"POST" url:@"api/walletBalance" parameters:nil success:^(id  _Nullable result) {
            if ([result isKindOfClass:[NSArray class]]) {
                if (((NSArray *)result).count > 0) {
                    NSDictionary *obj = ((NSArray *)result).firstObject;
                    self.walletModel = [DCWalletDataModel modelWithDictionary:obj];
                    self.totalLabel.text = [NSString stringWithFormat:@"%@ %@",self.walletModel.balance,self.walletModel.coin];
                }
            }
        } failure:^(NSError * _Nonnull error) {
            
        }];
    } failure:^(NSError * _Nonnull error) {
        
    }];
}

- (void)requestForCode {
    NSString *area = @"86";
    NSString *account = self.account;
    NSString *sms_type = @"withdraw";
    if ([DCTools isEmpty:account]) {
        [self requestAccount:^(NSString *result) {
            self.account = result;
            [self requestForCode];
        }];
        return;
    }
    [[DCRequestManager sharedManager] requestWithMethod:@"POST" url:@"api/sms" parameters:@{@"area":area , @"account":account,@"sms_type":sms_type} success:^(id  _Nullable result) {
        self.codeButton.backgroundColor = KSelectBackColor;
        self.codeButton.selected = YES;
        self.codeButton.userInteractionEnabled = NO;
        self.downIndex = 60;
        self.timer = [YYTimer timerWithTimeInterval:1 target:self selector:@selector(timerVerificationCode) repeats:YES];
        [self.timer fire];
    } failure:^(NSError * _Nonnull error) {
        
    }];
    
}

- (void)timerVerificationCode {
    self.downIndex --;
    [self.codeButton setTitle:[NSString stringWithFormat:@"%ds后重发",self.downIndex] forState:UIControlStateNormal];
    if (self.downIndex <= 0) {
        [self.timer invalidate];
        self.timer = nil;
        [self.codeButton setTitle:@"发送验证码" forState:UIControlStateNormal];
        self.codeButton.backgroundColor = kNormalBackColor;
        self.codeButton.selected = NO;
        self.codeButton.userInteractionEnabled = YES;
    }
}


- (void) requestAccount:(void(^)(NSString *result))complete {
    [[DCRequestManager sharedManager] requestWithMethod:@"POST" url:@"api/userInfo" parameters:@{@"id":[[DCUserManager sharedManager] userModel].uid} success:^(id  _Nullable result) {
        DCMineInfoModel *infoModel = [DCMineInfoModel modelWithDictionary:result];
        complete([DCTools isEmpty:infoModel.phone]?infoModel.email:infoModel.phone);
    } failure:^(NSError * _Nonnull error) {
    }];
}
@end
