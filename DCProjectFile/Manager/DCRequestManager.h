//
//  DCRequestManager.h
//  DCProjectFile
//
//  Created  on 2023/6/1.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^RequestSuccessBlock)(id _Nullable  result);
typedef void(^RequestFailureBlock)(NSError * _Nonnull error);

@interface DCRequestManager : NSObject
+ (instancetype)sharedManager;
- (void)requestWithMethod:(NSString *)method
                      url:(NSString *)url
               parameters:(nullable NSDictionary *)parms
                  success:(nullable RequestSuccessBlock)success
                  failure:(nullable RequestFailureBlock)failure;

- (void)resetToken:(nullable NSString *)method
               url:(nullable NSString *)url
        parameters:(nullable NSDictionary *)parms
           success:(nullable RequestSuccessBlock)success
           failure:(nullable RequestFailureBlock)failure;



- (void)downloadWithUrl:(NSString *)url
               filePath:(NSString *)filePath
                success:(nullable RequestSuccessBlock)success;

- (void)networkForGetAppVersionInfo;
@end

NS_ASSUME_NONNULL_END
