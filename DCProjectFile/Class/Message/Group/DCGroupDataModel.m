//
//  DCGroupDataModel.m
//  DCProjectFile
//
//  Created  on 2023/7/11.
//

#import "DCGroupDataModel.h"
@implementation DCGroupNotica

@end
@implementation DCGroupInfo
+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"groupId"  : @"id"};
}
@end
@implementation DCGroupMember

@end
@implementation DCGroupDataModel
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"group_info" : [DCGroupInfo class],
             @"group_notice" : [DCGroupNotica class],
             @"group_member" : [DCGroupMember class]
    };
}
@end
