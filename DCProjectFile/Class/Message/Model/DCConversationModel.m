//
//  DCConversationModel.m
//  DCProjectFile
//
//  Created  on 2023/6/8.
//

#import "DCConversationModel.h"

@implementation DCConversationModel
+(NSArray* _Nonnull)bg_unionPrimaryKeys {
    return @[@"targetId"];
}

+(NSDictionary *_Nonnull)bg_objectClassForCustom {
    return @{@"lastMessage" : [DCMessageContent class]};
}

- (NSString *)bg_tableName {
    return kConversationListTableName;
}


- (NSComparisonResult)compareConversatonDatas:(DCConversationModel *)conversation {
    NSComparisonResult result = [[NSNumber numberWithLong:self.lastMsgTime] compare:[NSNumber numberWithLong:conversation.lastMsgTime]];
    if (result == NSOrderedSame) {
        result = [self.targetId compare:conversation.targetId];
    }
    return  result == NSOrderedAscending;
}
@end
