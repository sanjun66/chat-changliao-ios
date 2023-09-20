//
//  DCFileUploadManager.m
//  DCProjectFile
//
//  Created  on 2023/8/17.
//

#import "DCFileUploadManager.h"

@implementation DCFileUploadManager

- (void)upload:(NSData*)data name:(NSString *)fileName uniquelyIdentifies:(nullable NSString *)identifies success:(UploadSuccessBlock)success failure:(UploadFailureBlock)failure {
    if ([[DCUserManager sharedManager].ossModel.oss_status intValue] == 1) {
        NSString *requestUrl = [NSString stringWithFormat:@"%@api/localUpload",kUrlPre];
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        NSMutableDictionary *headers = [NSMutableDictionary dictionary];
        [headers setObject:[NSString stringWithFormat:@"Bearer %@",[[DCUserManager sharedManager] userModel].token] forKey:@"Authorization"];
        NSURLSessionDataTask *dataTask = [manager POST:requestUrl parameters:nil headers:headers constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
            [formData appendPartWithFileData:data name:@"file" fileName:fileName mimeType:@""];
        } progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            if (identifies) {
                if ([self.dataTaskDictionary containsObjectForKey:identifies]) {
                    [self.dataTaskDictionary removeObjectForKey:identifies];
                }
            }
            NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
            if (code==200) {
                NSDictionary *resultData = [responseObject objectForKey:@"data"];
                NSString *file_name = [resultData objectForKey:@"file_name"];
                success(file_name);
            }else {
                failure(@"");
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            failure(error);
        }];
        [dataTask resume];
        if (identifies) {
            [self.dataTaskDictionary setObject:dataTask forKey:identifies];
        }
    }else {
        AWSS3TransferUtilityUploadCompletionHandlerBlock completionHandler = ^(AWSS3TransferUtilityUploadTask *task, NSError *error) {
            if (identifies) {
                if ([self.dataTaskDictionary containsObjectForKey:identifies]) {
                    [self.dataTaskDictionary removeObjectForKey:identifies];
                }
            }
            
            if (error) {
                failure(error);
            } else {
                success(task.key);
            }
        };
        AWSS3TransferUtilityUploadExpression *expression = [AWSS3TransferUtilityUploadExpression new];
        expression.progressBlock = ^(AWSS3TransferUtilityTask *task, NSProgress *progress) {
            if (task.status==AWSS3TransferUtilityTransferStatusCancelled) {
                
            }
        };
        AWSS3TransferUtility *transferUtility = [AWSS3TransferUtility defaultS3TransferUtility];
        transferUtility.shouldRemoveCompletedTasks = YES;
        
        [[transferUtility uploadData:data bucket:[DCUserManager sharedManager].ossModel.aws.aws_bucket key:fileName contentType:@"" expression:expression completionHandler:completionHandler] continueWithBlock:^id _Nullable(AWSTask<AWSS3TransferUtilityUploadTask *> * _Nonnull t) {
            if (t.error) {
                failure(t.error);
            }
            if (t.result) {
                AWSS3TransferUtilityUploadTask *uploadTask = t.result;
                if (identifies) {
                    [self.dataTaskDictionary setObject:uploadTask forKey:identifies];
                }
            }
            return nil;
        }];
    }
}

- (instancetype)init {
    if (self = [super init]) {
        self.dataTaskDictionary = [NSMutableDictionary dictionary];
    }
    return self;
}

+ (instancetype)sharedManager {
    static DCFileUploadManager *manager = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        manager = [[self alloc] init];
    });

    return manager;
}

@end
