//
//  DCExchangeVC.h
//  DCProjectFile
//
//  Created  on 2023/9/15.
//

#import "DCBaseViewController.h"
#import "DCWalletDataModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface DCExchangeVC : DCBaseViewController
@property (nonatomic, strong) DCWalletDataModel *walletModel;
@property (nonatomic, copy) NSString *account;
@end

NS_ASSUME_NONNULL_END
