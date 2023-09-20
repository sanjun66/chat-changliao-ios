//
//  DCUserManager.m
//  DCProjectFile
//
//  Created  on 2023/6/14.
//

#import "DCUserManager.h"
#import "DCTabBarController.h"
#import "DCLoginMainVC.h"
#import "DCNavigationController.h"
#import "DCStoreModel.h"
#import "DCMineInfoModel.h"

#define kUserInfoModel @"kUserInfoModel"

@interface DCUserManager ()

@end

@implementation DCUserManager
+ (instancetype)sharedManager {
    static DCUserManager *manager = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        manager = [[self alloc] init];
    });

    return manager;
}

- (void)saveUser:(DCStoreModel*)model {
    model.saveTime = [[DCTools getCurrentTimestamp] longValue];
    [[NSUserDefaults standardUserDefaults] setObject:model.modelToJSONObject forKey:kUserInfoModel];
    [[NSUserDefaults standardUserDefaults] synchronize];
    self.model = model;
}

- (DCStoreModel *) userModel {
    if (!self.model) {
        self.model = [DCStoreModel modelWithJSON:[[NSUserDefaults standardUserDefaults] objectForKey:kUserInfoModel]];
        return self.model;
    }
    return self.model;
}

- (void)cleanUser {
    [[DCRequestManager sharedManager] requestWithMethod:@"POST" url:@"api/logout" parameters:nil success:^(id  _Nullable result) {
            
    } failure:^(NSError * _Nonnull error) {
        
    }];
    self.model = nil;
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    });
    [[DCSocketClient sharedInstance] destroySocket];
    [QBChat.instance disconnectWithCompletionBlock:^(NSError * _Nullable error) {
        
    }];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kUserInfoModel];
}

- (void)getConversationData:(DCConversationType)conversationType targerId:(NSString *)userId completion:(void (^)(DCUserInfo *userInfo))completion {
    
    NSString *where = [NSString stringWithFormat:@"where %@=%@",bg_sqlKey(@"userId"), bg_sqlValue(userId)];
    
    [DCUserInfo bg_findAsync:kConversationUserInfoTableName where:where complete:^(NSArray * _Nullable array) {
        if (array.count > 0) {
            DCUserInfo *user = array.firstObject;
            completion(user);
        }else {
            [self requesetConversationData:conversationType targerId:userId completion:^(DCUserInfo * _Nonnull userInfo, DCGroupDataModel * _Nonnull groupData) {
                completion(userInfo);
            }];
        }
//        bg_closeDB();
    }];
}

- (void)requesetConversationData:(DCConversationType)conversationType targerId:(NSString *)userId completion:(void (^)(DCUserInfo *userInfo , DCGroupDataModel *groupData))completion {
    if (conversationType == DC_ConversationType_GROUP) {
        NSString *groupId = [userId componentsSeparatedByString:@"_"].lastObject;
        [[DCRequestManager sharedManager] requestWithMethod:@"POST" url:@"api/groupInfo" parameters:@{@"id":groupId} success:^(id  _Nullable result) {
            DCGroupDataModel *model = [DCGroupDataModel modelWithDictionary:result];
            DCUserInfo *user = [[DCUserInfo alloc]initWithUserId:userId name:model.group_info.name portrait:model.group_info.avatar];
            [user bg_saveOrUpdateAsync:^(BOOL isSuccess) {
//                bg_closeDB();
            }];
            completion(user,model);
            
            [model.group_member enumerateObjectsUsingBlock:^(DCGroupMember * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                DCUserInfo *user = [[DCUserInfo alloc]initWithUserId:obj.uid name:obj.notes portrait:obj.avatar];
                user.quickbloxId = obj.quickblox_id;
                [user bg_saveOrUpdateAsync:^(BOOL isSuccess) {
//                    bg_closeDB();
                }];
            }];
        } failure:^(NSError * _Nonnull error) {
            if (error.code==422) {
                DCGroupDataModel *gModel = [[DCGroupDataModel alloc]init];
                gModel.code = 422;
                completion(nil,gModel);
            }
        }];
    }else {
        [[DCRequestManager sharedManager] requestWithMethod:@"POST" url:@"api/userInfo" parameters:@{@"id":userId} success:^(id  _Nullable result) {
            NSDictionary *dict = result;
            NSString *userName = [NSString stringWithFormat:@"%@",dict[@"note_name"]];
            if ([DCTools isEmpty:userName]) {
                userName = [NSString stringWithFormat:@"%@",dict[@"nick_name"]];
            }
            if ([DCTools isEmpty:userName]) {
                userName = kDefaultUserName;
            }
            DCUserInfo *user = [[DCUserInfo alloc]initWithUserId:userId name:[NSString stringWithFormat:@"%@",userName] portrait:[NSString stringWithFormat:@"%@",dict[@"avatar"]]];
            user.quickbloxId = [dict[@"quickblox_id"] integerValue];
            
            [user bg_saveOrUpdateAsync:^(BOOL isSuccess) {
//                bg_closeDB();
            }];
            
            completion(user,nil);

        } failure:^(NSError * _Nonnull error) {

        }];
    }
    
    
}
- (void)requestConversationDistrubState:(DCConversationType)conversationType targerId:(NSString *)userId completion:(void (^)(NSString *state))completion {
    if (conversationType == DC_ConversationType_GROUP) {
        NSString *groupId = [userId componentsSeparatedByString:@"_"].lastObject;
        [[DCRequestManager sharedManager] requestWithMethod:@"POST" url:@"api/groupInfo" parameters:@{@"id":groupId} success:^(id  _Nullable result) {
            DCGroupDataModel *model = [DCGroupDataModel modelWithDictionary:result];
            DCUserInfo *user = [[DCUserInfo alloc]initWithUserId:userId name:model.group_info.name portrait:model.group_info.avatar];
            [user bg_saveOrUpdateAsync:^(BOOL isSuccess) {
            }];
            [model.group_member enumerateObjectsUsingBlock:^(DCGroupMember * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                DCUserInfo *user = [[DCUserInfo alloc]initWithUserId:obj.uid name:obj.notes portrait:obj.avatar];
                user.quickbloxId = obj.quickblox_id;
                [user bg_saveOrUpdateAsync:^(BOOL isSuccess) {
                }];
            }];
            completion(model.group_info.is_disturb?@"1":@"0");
        } failure:^(NSError * _Nonnull error) {
        }];
    }else {
        [[DCRequestManager sharedManager] requestWithMethod:@"POST" url:@"api/userInfo" parameters:@{@"id":userId} success:^(id  _Nullable result) {
            DCMineInfoModel *model = [DCMineInfoModel modelWithDictionary:result];
            NSDictionary *dict = result;
            NSString *userName = model.note_name;
            if ([DCTools isEmpty:userName]) {
                userName = model.nick_name;
            }
            if ([DCTools isEmpty:userName]) {
                userName = kDefaultUserName;
            }
            DCUserInfo *user = [[DCUserInfo alloc]initWithUserId:userId name:[NSString stringWithFormat:@"%@",userName] portrait:model.avatar];
            user.quickbloxId = [dict[@"quickblox_id"] integerValue];
            [user bg_saveOrUpdateAsync:^(BOOL isSuccess) {
            }];
            completion(model.is_disturb?@"1":@"0");
        } failure:^(NSError * _Nonnull error) {

        }];
    }
}
- (void)resetRootVc {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIViewController *rootVc;
        
        if ([[DCUserManager sharedManager] userModel].token) {
            DCTabBarController *tabBar = [[DCTabBarController alloc] init];
            rootVc = tabBar;
        }else {
            DCLoginMainVC *mainVc = [[DCLoginMainVC alloc]init];
            rootVc = [[DCNavigationController alloc]initWithRootViewController:mainVc];
        }
        CATransition *transtition = [CATransition animation];
        transtition.duration = 0.5;
        transtition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        [UIApplication sharedApplication].keyWindow.rootViewController = rootVc;
        [[UIApplication sharedApplication].keyWindow.layer addAnimation:transtition forKey:@"animation"];
    });    
}

- (void)checkVersionState {
    if (![DCUserManager sharedManager].verModel) {return;}
    
    if ([DCUserManager sharedManager].verModel.version_code > [kBundleVersion floatValue]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"版本更新提醒" message:[DCUserManager sharedManager].verModel.desc preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"去更新" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[DCTools isEmpty:[DCUserManager sharedManager].verModel.update_url]?@"https://www.baidu.com":[DCUserManager sharedManager].verModel.update_url] options:@{} completionHandler:^(BOOL success) {
            }];
        }]];
        if (![DCUserManager sharedManager].verModel.forced_update) {
            [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                [DCUserManager sharedManager].verModel = nil;
            }]];
        }
        [[DCTools topViewController] presentViewController:alert animated:YES completion:nil];
    }else {
        [DCUserManager sharedManager].verModel = nil;
    }
}
@end
