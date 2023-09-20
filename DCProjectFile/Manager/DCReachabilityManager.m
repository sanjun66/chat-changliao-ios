//
//  DCReachabilityManager.m
//  DCProjectFile
//
//  Created on 2023/3/2.
//

#import "DCReachabilityManager.h"


#define kNetTips @"网络连接失败，请检查您的网络连接"

@implementation DCReachabilityManager
+ (instancetype)sharedManager {
    static DCReachabilityManager *manager = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        manager = [[self alloc] init];
    });

    return manager;
}

- (void)starMonitorNetworking {
    __block BOOL isOk = NO;
    
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"kNetworkStatusChangedNotification" object:(status == AFNetworkReachabilityStatusReachableViaWWAN || status == AFNetworkReachabilityStatusReachableViaWiFi)?@(YES):@(NO)];
        
        if (status == AFNetworkReachabilityStatusReachableViaWWAN || status == AFNetworkReachabilityStatusReachableViaWiFi) {
            NSLog(@"有网");
            self.isNetworkOK = YES;
            isOk = YES;
            if ([[DCTools topViewController] isKindOfClass:[UIAlertController class]]) {
                UIAlertController *alert = (UIAlertController *)[DCTools topViewController];
                if([alert.message isEqualToString:kNetTips]) {
                    [alert dismissViewControllerAnimated:NO completion:nil];
                }
            }
            
        }else{
            NSLog(@"没网");
            self.isNetworkOK = NO;
            isOk = NO;
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:kNetTips preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"退出重试" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                abort();
            }]];
            [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
            [[DCTools topViewController] presentViewController:alert animated:true completion:nil];
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationOnMainThreadWithName:kNetworkReachabilityStatusNotification object:@(isOk)];
    }];
}


@end
