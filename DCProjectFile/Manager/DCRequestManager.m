//
//  DCRequestManager.m
//  DCProjectFile
//
//  Created  on 2023/6/1.
//
// 402 token不对
// 403 账号其他设备登录
#import "DCRequestManager.h"
#import "MIUGTMBase64.h"


@implementation DCRequestManager
+ (instancetype)sharedManager {
    static DCRequestManager *manager = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        manager = [[self alloc] init];
    });

    return manager;
}

- (void)requestWithMethod:(NSString *)method
                      url:(NSString *)url
               parameters:(nullable NSDictionary *)parms
                  success:(nullable RequestSuccessBlock)success
                  failure:(nullable RequestFailureBlock)failure
{
    if (kUser.token && kUser.saveTime > 0 && ([DCTools getCurrentTimestamp].longValue - kUser.saveTime > kUser.expire_seconds*750)) {
        [[DCRequestManager sharedManager] resetToken:method url:url parameters:parms success:success failure:failure];
        return;
    }
    NSString *requestUrl = [NSString stringWithFormat:@"%@%@",kUrlPre,url];
    
    NSMutableDictionary *finalParms = [NSMutableDictionary dictionary];
    [finalParms addEntriesFromDictionary:parms];
    
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    NSError *err ;
    
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] requestWithMethod:method URLString:requestUrl parameters:nil error:&err];
    
    request.timeoutInterval= 30;
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    if (SECRET) {
        [request setValue:@"0" forHTTPHeaderField:@"app-encrypt"];
    }
    if ([[DCUserManager sharedManager] userModel].token) {
        [request setValue:[NSString stringWithFormat:@"Bearer %@",[[DCUserManager sharedManager] userModel].token] forHTTPHeaderField:@"Authorization"];
    }
    if (finalParms.count > 0) {
        if (SECRET) {
            NSString *jsonParms = [DCTools jsonString:finalParms];
            NSString *aesParms = [DCTools AESEncrypt:jsonParms];
            NSDictionary *secretParms = @{@"params_body":aesParms};
            [request setHTTPBody:[[DCTools jsonString:secretParms] dataUsingEncoding:NSUTF8StringEncoding]];
        }else {
            [request setHTTPBody:[[DCTools jsonString:finalParms] dataUsingEncoding:NSUTF8StringEncoding]];
        }
    }

    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request uploadProgress:^(NSProgress * _Nonnull uploadProgress) {
        
    } downloadProgress:^(NSProgress * _Nonnull downloadProgress) {
        
    } completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        
        if (error==nil) {
            NSDictionary *responseDictionary;
            if ([responseObject isKindOfClass:[NSData class]]) {
                responseDictionary = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
            }else if ([responseObject isKindOfClass:[NSDictionary class]]) {
                responseDictionary = responseObject;
            }else {
                [MBProgressHUD showTips:@"返回数据格式不支持"];
                return;
            }
            
            int code = [[responseDictionary valueForKey:@"code"] intValue];
            
            if (code==200) {
                id resultData = [responseDictionary objectForKey:@"data"];
                
                if (SECRET) {
                    // 解密处理
                    NSString *jsonString = [DCTools AESDecrypt:resultData];

                    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
                    NSError *err = nil;
                    id result = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                       options:NSJSONReadingMutableContainers
                                                                         error:&err];
                    success(result);
                }else {
                    // 不加密时直接返回数据
                    success(resultData);
                }
                
            }else if (code == 402 || code == 403) {
                [MBProgressHUD hideActivity];
                [MBProgressHUD showTips:@"登录状态已过期"];
                [[DCUserManager sharedManager] cleanUser];
                [[DCUserManager sharedManager] resetRootVc];
            }else {
                if ([requestUrl containsString:@"api/groupInfo"] && code==422) {
                    NSError *e = [NSError errorWithDomain:NSCocoaErrorDomain code:code userInfo:nil];
                    failure(e);
                    return;
                }
                [MBProgressHUD hideActivity];
                [MBProgressHUD showTips:[responseDictionary valueForKey:@"message"]];
            }
        }else {
            NSLog(@"出错的url:%@",requestUrl);
            [MBProgressHUD showTips:@"网络出错了"];
            failure(error);
        }
        
    }];
    
    [dataTask resume];
}


- (void)resetToken:(nullable NSString *)method
               url:(nullable NSString *)url
        parameters:(nullable NSDictionary *)parms
           success:(nullable RequestSuccessBlock)success
           failure:(nullable RequestFailureBlock)failure {
    
    if (![DCTools isEmpty:method] && ![DCTools isEmpty:url]) {
        [[DCSocketClient sharedInstance] destroySocket];
    }
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    NSString *requestUrl = [NSString stringWithFormat:@"%@api/refreshToken",kUrlPre];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    manager.completionQueue = dispatch_get_global_queue(0, 0);
    
    NSMutableDictionary *headers = [NSMutableDictionary dictionary];
    [headers setObject:@"0" forKey:@"app-encrypt"];
    [headers setObject:[NSString stringWithFormat:@"Bearer %@",[[DCUserManager sharedManager] userModel].token] forKey:@"Authorization"];
    
    NSURLSessionDataTask *dataTask = [manager dataTaskWithHTTPMethod:@"POST" URLString:requestUrl parameters:nil headers:headers uploadProgress:nil downloadProgress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([responseObject isKindOfClass:[NSDictionary class]]) {
                NSDictionary *resultDict = (NSDictionary *)responseObject;
                NSInteger code = [[resultDict valueForKey:@"code"] intValue];
                if (code == 200) {
                    NSString *dataString = [resultDict valueForKey:@"data"];
                    NSString *jsonString = [DCTools AESDecrypt:dataString];
                    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
                    NSError *err = nil;
                    id result = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                        options:NSJSONReadingMutableContainers
                                                                          error:&err];
                    
                    DCStoreModel *model = [DCStoreModel modelWithDictionary:result];
                    model.quickblox_id = kUser.quickblox_id;
                    model.quickblox_pwd = kUser.quickblox_pwd;
                    model.quickblox_login = kUser.quickblox_login;
                    [[DCUserManager sharedManager] saveUser:model];
                    
                    if (![DCTools isEmpty:method] && ![DCTools isEmpty:url]) {
                        [[DCSocketClient sharedInstance] reConnect];
                        [self requestWithMethod:method url:url parameters:parms success:success failure:failure];
                    }
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"kTokenRefreshSuccessNotification" object:nil];
                }else {
                    [MBProgressHUD showTips:@"登录状态已过期"];
                    [[DCUserManager sharedManager] cleanUser];
                    [[DCUserManager sharedManager] resetRootVc];
                }
            }
        });
        dispatch_semaphore_signal(semaphore);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
    
    [dataTask resume];
    
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    
}


- (void)downloadWithUrl:(NSString *)url
               filePath:(NSString *)filePath
                success:(nullable RequestSuccessBlock)success
{
    /* 创建网络下载对象 */
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];

    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    /* 开始请求下载 */
    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        NSLog(@"下载进度：%.0f％", downloadProgress.fractionCompleted * 100);
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        /* 设定下载到的位置 */
        return [NSURL fileURLWithPath:filePath];
                
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        success(filePath);
        NSLog(@"下载完成");
    }];
    [downloadTask resume];
}


- (void)networkForGetAppVersionInfo {
    [[DCRequestManager sharedManager] requestWithMethod:@"POST" url:@"api/getVersionInfo" parameters:@{@"platform":@"iOS"} success:^(id  _Nullable result) {
        // "force_update"
        // "desc": "sss", //更新说明
        DCVersionModel *model = [DCVersionModel modelWithDictionary:result];
        [DCUserManager sharedManager].verModel = model;
        [[DCUserManager sharedManager] checkVersionState];
    } failure:^(NSError * _Nonnull error) {
        
    }];
}
@end
