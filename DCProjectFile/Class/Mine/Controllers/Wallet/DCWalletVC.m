//
//  DCWalletVC.m
//  DCProjectFile
//
//  Created  on 2023/9/14.
//

#import "DCWalletVC.h"
#import "DCRecordListVC.h"
#import "DCAccountMagVC.h"
#import "DCRechargeVC.h"
#import "DCExchangeVC.h"
#import "DCWalletDataModel.h"
@interface DCWalletVC ()
@property (weak, nonatomic) IBOutlet UIView *accountMagView;
@property (weak, nonatomic) IBOutlet UILabel *walletTtileLabel;
@property (weak, nonatomic) IBOutlet UILabel *walletBalanceLabel;
@property (nonatomic, strong) DCWalletDataModel *walletModel;

@end

@implementation DCWalletVC

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self requestWalletDatas];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.title = @"我的钱包";
    [self rightBarButtonItemWithString:@"账单明细"];
    [self setupViews];
}

- (void)requestWalletDatas {
    [[DCRequestManager sharedManager] requestWithMethod:@"POST" url:@"api/walletBalance" parameters:nil success:^(id  _Nullable result) {
        if ([result isKindOfClass:[NSArray class]]) {
            if (((NSArray *)result).count > 0) {
                NSDictionary *obj = ((NSArray *)result).firstObject;
                self.walletModel = [DCWalletDataModel modelWithDictionary:obj];
            }
        }
    } failure:^(NSError * _Nonnull error) {
        
    }];
}

- (void)setWalletModel:(DCWalletDataModel *)walletModel {
    _walletModel = walletModel;
    self.walletTtileLabel.text = [NSString stringWithFormat:@"钱包余额（%@）",walletModel.coin];
    self.walletBalanceLabel.text = walletModel.balance;
}
- (void)rightBarButtonAction {
    DCRecordListVC *vc = [[DCRecordListVC alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
    
}
- (IBAction)rechargeClick:(id)sender {
    if (self.walletModel.recharge_channel==1) {
        DCRechargeVC *vc = [[DCRechargeVC alloc]init];
        [self.navigationController pushViewController:vc animated:YES];
    }
}
- (IBAction)exchangeClick:(id)sender {
    if (self.walletModel.withdraw_channel==1) {
        DCExchangeVC *vc = [[DCExchangeVC alloc]init];
        vc.account = self.account;
        vc.walletModel = self.walletModel;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)setupViews {
    
    NSString *highlightStr = @" 提现账户 ";
    
    NSMutableAttributedString *atts = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"管理我的%@",highlightStr] attributes:@{NSFontAttributeName:kFontSize(13) , NSForegroundColorAttributeName:kTextSubColor}];
    
    [atts setTextHighlightRange:[atts.string rangeOfString:highlightStr] color:kMainColor backgroundColor:kBackgroundColor tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
        DCAccountMagVC *vc = [[DCAccountMagVC alloc]init];
        [self.navigationController pushViewController:vc animated:YES];
    }];
    
    YYLabel *agreementLabel = [[YYLabel alloc]init];
    agreementLabel.attributedText = atts;
    agreementLabel.textAlignment = NSTextAlignmentCenter;
    agreementLabel.frame = CGRectMake(0, 0, 300, 34);
    [self.accountMagView addSubview:agreementLabel];
}

@end
