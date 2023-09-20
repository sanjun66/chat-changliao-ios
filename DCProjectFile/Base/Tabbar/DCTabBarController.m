//
//  DCTabBarController.m
//  DCProjectFile
//
//  Created  on 2023/2/28.
//

#import "DCTabBarController.h"

#import "DCNavigationController.h"
#import "DCRoomMainVC.h"
#import "DCMsgContainerVC.h"
#import "DCMineMainVC.h"

#import "DCFriendApplyModel.h"

@interface DCTabBarController ()

@end

@implementation DCTabBarController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    bg_setDebug(YES);//打开调试模式,打印输出调试信息.
//    bg_setDisableCloseDB(YES);
    bg_setSqliteName(kSqliteName);
    [MBProgressHUD hideActivity];
    [[DCUserManager sharedManager] getConversationData:DC_ConversationType_PRIVATE targerId:[[DCUserManager sharedManager] userModel].uid completion:^(DCUserInfo * _Nonnull userInfo) {
        [DCUserManager sharedManager].currentUserInfo = userInfo;
    }];
    
    [[DCCallManager sharedInstance] singupQbChat];
    
    
    [self setupTabbar];
    [self setupAllControllers];
    
    [self.tabBar addSubview:self.redBadge];
    [self.tabBar addSubview:self.friendRedBadge];
    [self requesApplyUserDatas];
    [self requestOssInfo];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onFriendApply:) name:kOnReceiveFriendApplyNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(requesApplyUserDatas) name:UIApplicationDidBecomeActiveNotification object:nil];
}
- (void)onFriendApply:(NSNotification *)aNotification {
    dispatch_async(dispatch_get_main_queue(), ^{
//        self.friendRedBadge.hidden = NO;
        [self requesApplyUserDatas];
    });
    
}

- (void)setupAllControllers {
    DCMsgContainerVC *msg = [[DCMsgContainerVC alloc]init];
    [self addChildViewController:msg normalImage:@"tab_message" selectedImage:@"tab_message_sel" title:@"消息"];
    
    DCRoomMainVC *home = [[DCRoomMainVC alloc]init];
    [self addChildViewController:home normalImage:@"tab_game" selectedImage:@"tab_game_sel" title:@"朋友"];
    
    DCMineMainVC *mine = [[DCMineMainVC alloc]init];
    [self addChildViewController:mine normalImage:@"tab_mine" selectedImage:@"tab_mine_sel" title:@"我的"];
    
    self.tabBar.tintColor = kMainColor;
    if (@available(iOS 10.0, *)) {
        self.tabBar.unselectedItemTintColor = HEX(@"#868A9A");
    } else {
        // Fallback on earlier versions
    }
    
}
- (void)addChildViewController:(UIViewController *)childController normalImage:(NSString *)normalString selectedImage:(NSString *)selectedString title:(NSString *)title {
    childController.tabBarItem.image = [[UIImage imageNamed:normalString] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    childController.tabBarItem.selectedImage = [[UIImage imageNamed:selectedString] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    childController.tabBarItem.title = title;
    
    [[UITabBarItem appearance] setTitleTextAttributes:@{NSFontAttributeName:kFontSize(13),NSForegroundColorAttributeName:HEX(@"#868A9A")} forState:UIControlStateNormal];
    [[UITabBarItem appearance] setTitleTextAttributes:@{NSFontAttributeName:kFontSize(13),NSForegroundColorAttributeName:kMainColor} forState:UIControlStateSelected];
    
    DCNavigationController *nav = [[DCNavigationController alloc]initWithRootViewController:childController];
    [self addChildViewController:nav];
    
}

- (void)setupTabbar {
    [[UITabBar appearance] setBackgroundImage:[[UIImage alloc]init]];
    [[UITabBar appearance] setBackgroundColor:[UIColor whiteColor]];
    
    if(@available(iOS 13.0, *)) {
       UITabBarAppearance *appearance = [UITabBarAppearance new];
       appearance.backgroundColor = [UIColor whiteColor];
       appearance.backgroundImage = [UIImage new];
       appearance.shadowColor = [UIColor whiteColor];
       appearance.shadowImage = [UIImage new];
       [UITabBar appearance].standardAppearance = appearance;
    }
}
//MARK: - request
- (void)requesApplyUserDatas {
    [[DCRequestManager sharedManager] requestWithMethod:@"POST" url:@"api/applyList" parameters:nil success:^(id  _Nullable result) {
        __block NSInteger number = 0;
        if (((NSArray *)result[@"apply_list"]).count > 0) {
            [((NSArray *)result[@"apply_list"]) enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                DCFriendApplyModel *model = [DCFriendApplyModel modelWithDictionary:obj];
                if ([model.flag isEqualToString:@"taker"] && model.state == 1) {
                    self.friendRedBadge.hidden = NO;
                    number+=1;
                }
            }];
            [DCUserManager sharedManager].applyNumber = number;
            self.friendRedBadge.hidden = [DCUserManager sharedManager].applyNumber<=0;
            self.friendRedBadge.text = [NSString stringWithFormat:@"%ld",[DCUserManager sharedManager].applyNumber];
            
            [[NSNotificationCenter defaultCenter] postNotificationOnMainThreadWithName:@"tabbarcheckcomplete" object:nil];
        }
        
    } failure:^(NSError * _Nonnull error) {
            
    }];
}

- (void)requestOssInfo {
    NSString *storeInfo = [[NSUserDefaults standardUserDefaults] objectForKey:kOssConfigKey];
    DCOssConfigModel *model = [DCOssConfigModel modelWithJSON:storeInfo];
    [DCUserManager sharedManager].ossModel = model;
    if (model) {
        [self setupAws];
    }
    [[DCRequestManager sharedManager] requestWithMethod:@"POST" url:@"api/getOssInfo" parameters:nil success:^(id  _Nullable result) {
        DCOssConfigModel *model = [DCOssConfigModel modelWithDictionary:result];
        [DCUserManager sharedManager].ossModel = model;
        [[NSUserDefaults standardUserDefaults] setObject:[model modelToJSONString] forKey:kOssConfigKey];
        if (model) {
            [self setupAws];
        }
    } failure:^(NSError * _Nonnull error) {
        
    }];
}

- (void)setupAws {
    AWSStaticCredentialsProvider * credentialsProvider = [[AWSStaticCredentialsProvider alloc] initWithAccessKey:[DCUserManager sharedManager].ossModel.aws.aws_access_key_id secretKey:[DCUserManager sharedManager].ossModel.aws.aws_secret_access_key];
    
    AWSServiceConfiguration * configuration = [[AWSServiceConfiguration alloc] initWithRegion:[[DCUserManager sharedManager].ossModel.aws.aws_default_region aws_regionTypeValue] credentialsProvider:credentialsProvider];
    [AWSServiceManager defaultServiceManager].defaultServiceConfiguration = configuration;
}
//MARK: - getter

- (UILabel *)redBadge {
    if (!_redBadge) {
        _redBadge = [[UILabel alloc]init];
        _redBadge.layer.cornerRadius = 8;
        _redBadge.layer.masksToBounds = true;
        _redBadge.backgroundColor = kRedColor;
        _redBadge.frame = CGRectMake(kScreenWidth/3-WIDTH_SCALE(42), 7, 16, 16);
        _redBadge.textColor = kWhiteColor;
        _redBadge.font = kFontSize(10);
        _redBadge.textAlignment = NSTextAlignmentCenter;
        _redBadge.hidden = YES;
    }
    return _redBadge;
}

- (UILabel *)friendRedBadge {
    if (!_friendRedBadge) {
        _friendRedBadge = [[UILabel alloc]init];
        _friendRedBadge.layer.cornerRadius = 8;
        _friendRedBadge.layer.masksToBounds = true;
        _friendRedBadge.backgroundColor = kRedColor;
        _friendRedBadge.textColor = kWhiteColor;
        _friendRedBadge.font = kFontSize(10);
        _friendRedBadge.textAlignment = NSTextAlignmentCenter;
        _friendRedBadge.frame = CGRectMake(kScreenWidth*2/3-WIDTH_SCALE(42), 7, 16, 16);
        _friendRedBadge.hidden = YES;
    }
    return _friendRedBadge;
}

@end
