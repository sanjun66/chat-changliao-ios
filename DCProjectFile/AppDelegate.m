//
//  AppDelegate.m
//  DCProjectFile
//
//  Created  on 2023/2/28.
//

#import "AppDelegate.h"
#import "DCTransitionalVC.h"
#import "DCNavigationController.h"
#import <UserNotifications/UserNotifications.h>
#import <JPUSHService.h>
#import "DCConversationListVC.h"
#import "DCFriendApplyVC.h"
@interface AppDelegate ()<UNUserNotificationCenterDelegate,JPUSHRegisterDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc]initWithFrame:UIScreen.mainScreen.bounds];
    self.window.backgroundColor = kBackgroundColor;
//    DCNavigationController *nav = [[DCNavigationController alloc]initWithRootViewController:[[DCTransitionalVC alloc]init]];
    self.window.rootViewController = [[DCTransitionalVC alloc]init];
    [self.window makeKeyAndVisible];
    [[DCReachabilityManager sharedManager] starMonitorNetworking];
    [DCCallManager.sharedInstance initializeRTC];
    [self initIQkerboardManager];
    
    [self registerNotification:application];
    [self registerJPush:launchOptions];
    return YES;
}
- (void)registerNotification:(UIApplication *)application {
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 10.0) {
            UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
            center.delegate = self;
            [center requestAuthorizationWithOptions:(UNAuthorizationOptionAlert | UNAuthorizationOptionBadge | UNAuthorizationOptionSound) completionHandler:^(BOOL granted, NSError * _Nullable error) {
                if (granted) {
                    //点击允许
                    [center getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {

                    }];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[UIApplication sharedApplication] registerForRemoteNotifications];
                    });
                    
                } else {
                    
                }
                
            }];
        }
}


- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler {
    
}
- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void(^)(void))completionHandler {
    
}
- (void)userNotificationCenter:(UNUserNotificationCenter *)center openSettingsForNotification:(nullable UNNotification *)notification {
    
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [JPUSHService registerDeviceToken:deviceToken];
}

//MARK: - 极光
- (void)registerJPush:(NSDictionary*)launchOptions {
    
    JPUSHRegisterEntity * entity = [[JPUSHRegisterEntity alloc] init];
      entity.types = JPAuthorizationOptionAlert|JPAuthorizationOptionBadge|JPAuthorizationOptionSound|JPAuthorizationOptionProvidesAppNotificationSettings;
    [JPUSHService registerForRemoteNotificationConfig:entity delegate:self];
    
    [JPUSHService setupWithOption:launchOptions
                           appKey:kJpushAppKey
                          channel:@"Publish channel"
                 apsForProduction:NO
            advertisingIdentifier:nil];
    [JPUSHService registrationIDCompletionHandler:^(int resCode, NSString * _Nullable registrationID) {
            
    }];
}

- (void)jpushNotificationCenter:(nonnull UNUserNotificationCenter *)center willPresentNotification:(nonnull UNNotification *)notification withCompletionHandler:(nonnull void (^)(NSInteger))completionHandler {
    
}

- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void(^)(void))completionHandler {
    NSDictionary * userInfo = response.notification.request.content.userInfo;
    if([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        [JPUSHService handleRemoteNotification:userInfo];
        [DCUserManager sharedManager].pushUserInfo = userInfo;
      }
      completionHandler();  // 系统要求执行这个方法
}

- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center openSettingsForNotification:(UNNotification *)notification {
    
}

- (void)jpushNotificationAuthorization:(JPAuthorizationStatus)status withInfo:(nullable NSDictionary *)info {
    
}




// MARK: - 注册键盘管理
- (void)initIQkerboardManager {
    [[IQKeyboardManager sharedManager] setEnable:YES];
    [[IQKeyboardManager sharedManager] setEnableAutoToolbar:NO];
    [[IQKeyboardManager sharedManager] setShouldResignOnTouchOutside:YES];
}



/// 当应用即将进入前台运行时调用
- (void)applicationDidBecomeActive:(UIApplication *)application {
    [JPUSHService resetBadge];
    DCLog(@"");
}
/// 当应用即将进从前台退出时调用
- (void)applicationWillResignActive:(UIApplication *)application {
    DCLog(@"");
}
/// 当应用开始在后台运行的时候调用
- (void)applicationDidEnterBackground:(UIApplication *)application{
    [JPUSHService setBadge:UIApplication.sharedApplication.applicationIconBadgeNumber];
    DCLog(@"");
}
/// 当程序从后台将要重新回到前台（但是还没变成Active状态）时候调用
- (void)applicationWillEnterForeground:(UIApplication *)application {
    [[DCUserManager sharedManager] checkVersionState];
    DCLog(@"");
}
/// 当前应用即将被终止，在终止前调用的函数。通常是用来保存数据和一些退出前的清理工作。如果应用当前处在suspended，此方法不会被调用。 该方法最长运行时限为5秒，过期应用即被kill掉并且移除内存
- (void)applicationWillTerminate:(UIApplication *)application {
    DCLog(@"");
}
@end
