//
//  DCOssConfigModel.h
//  DCProjectFile
//
//  Created  on 2023/8/16.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DCOssAwsModel : NSObject
@property (nonatomic, copy) NSString * aws_bucket;
@property (nonatomic, copy) NSString * aws_url;
@property (nonatomic, copy) NSString * aws_access_key_id;
@property (nonatomic, copy) NSString * aws_secret_access_key;
@property (nonatomic, copy) NSString * aws_default_region;

@end

@interface DCOssConfigModel : NSObject
@property (nonatomic, copy) NSString *oss_status;
@property (nonatomic, strong) DCOssAwsModel *aws;
@end

NS_ASSUME_NONNULL_END
