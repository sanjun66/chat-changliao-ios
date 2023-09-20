//
//  DCOssConfigModel.m
//  DCProjectFile
//
//  Created  on 2023/8/16.
//

#import "DCOssConfigModel.h"

@implementation DCOssAwsModel

@end

@implementation DCOssConfigModel
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"aws" : [DCOssAwsModel class]
    };
}
@end
