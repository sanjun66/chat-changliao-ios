//
//  DCCloudConversationDataModel.m
//  DCProjectFile
//
//  Created  on 2023/9/12.
//

#import "DCCloudConversationDataModel.h"

@implementation DCCloudConversationDataModel
+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"targetId"  : @"id"};
}

- (NSString *)targetId {
    if (self.talk_type == 2) {
        return [NSString stringWithFormat:@"group_%@",_targetId];
    }
    return _targetId;
}
@end
