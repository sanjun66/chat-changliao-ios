//
//  DCTransitionalVC.m
//  DCProjectFile
//
//  Created  on 2023/2/28.
//

#import "DCTransitionalVC.h"
#import "DCNavigationController.h"

#import "DCLoginMainVC.h"
#import "DCTabBarController.h"

@interface DCTransitionalVC ()

@end

@implementation DCTransitionalVC
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    UIImageView *backImageView = [[UIImageView alloc]initWithImage:[UIImage imageWithColor:kMainColor]];
    backImageView.frame = UIScreen.mainScreen.bounds;
    [self.view addSubview:backImageView];
    
    CGFloat itemW = (MIN(kScreenWidth, kScreenHeight)-110);
    
    UIImageView *transitionalView = [[UIImageView alloc]initWithFrame:CGRectMake(55, (kScreenHeight-itemW)/2, itemW, itemW)];
    transitionalView.image = [UIImage imageNamed:@"luanch_icon"];
    transitionalView.contentMode = UIViewContentModeScaleAspectFill;
    transitionalView.clipsToBounds = YES;
    [self.view addSubview:transitionalView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(networkStatusChanged:)
                                                 name:@"kNetworkStatusChangedNotification"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onTokenSuccess:)
                                                 name:@"kTokenRefreshSuccessNotification"
                                               object:nil];
    
}

- (void)networkStatusChanged:(NSNotification *)noti {
    BOOL status = [(NSNumber *)noti.object boolValue];
    if (status) {
        [self checkTokenStatus];
        [[DCRequestManager sharedManager] networkForGetAppVersionInfo];
    }
}

- (void)onTokenSuccess:(NSNotification *)noti {
    [[DCUserManager sharedManager] resetRootVc];
}
- (void)checkTokenStatus {
    if (kUser.token && kUser.saveTime > 0 && ([DCTools getCurrentTimestamp].longValue - kUser.saveTime > kUser.expire_seconds*750)) {
        [[DCRequestManager sharedManager] resetToken:nil url:nil parameters:nil success:nil failure:nil];
    }else {
        [[DCUserManager sharedManager] resetRootVc];
    }
}
@end
