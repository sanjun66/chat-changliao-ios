//
//  DCFriendListModel.m
//  DCProjectFile
//
//  Created  on 2023/6/20.
//

#import "DCFriendListModel.h"
@implementation DCFriendItem
+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"group_id"  : @"id"};
}
- (NSString *)bg_tableName {
    return kFriendListTableName;
}
+(NSArray* _Nonnull)bg_unionPrimaryKeys {
    return @[@"friend_id"];
}

- (NSString *)remark {
    if ([DCTools isEmpty:_remark]) {
        _remark = kDefaultUserName;
    }
    return _remark;
}
@end

@implementation DCFriendListModel
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"group_list" : [DCFriendItem class]};
}
@end
