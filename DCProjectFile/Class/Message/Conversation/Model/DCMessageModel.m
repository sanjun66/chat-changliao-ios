//
//  DCMessageModel.m
//  DCProjectFile
//
//  Created  on 2023/6/7.
//

#import "DCMessageModel.h"

@implementation DCMessageModel
+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"list"  : @"data" , @"aesData":@"data"};
}

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"data" : [DCMessageContent class],
             @"list" : [DCMessageContent class]
    };
}
@end


@implementation DCMessageContent

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"messageId"  : @"id"};
}
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"extra" : [DCMessageExtra class]};
}


+(NSArray* _Nonnull)bg_unionPrimaryKeys {
    return @[@"messageId"];
}

+(NSDictionary *_Nonnull)bg_objectClassForCustom {
    return @{@"extra" : [DCMessageExtra class]};
}

+ (NSArray *)bg_ignoreKeys {
    return @[@"flag",@"cellSize",@"senderUser",@"isDisplayMsgTime",@"isSelected",@"isHighlighted"];
}
- (DCMessageDirection)messageDirection{
    if ([self.from_uid isEqualToString:[[DCUserManager sharedManager] userModel].uid]) {
        return DC_MessageDirection_SEND;
    }
    return DC_MessageDirection_RECEIVE;
}


- (DCConversationType)conversationType {
    if (self.talk_type==1) {
        return DC_ConversationType_PRIVATE;
    }else if (self.talk_type==2) {
        return DC_ConversationType_GROUP;
    }else {
        return DC_ConversationType_INVALID;
    }
}

- (NSString *)targetId {
    if (self.talk_type == 2) {
        return [NSString stringWithFormat:@"group_%@",self.to_uid];
    }
    if ([self.from_uid isEqualToString:[[DCUserManager sharedManager] userModel].uid]) {
        return self.to_uid;
    }
    return  self.from_uid;
}

- (BOOL)isEqual:(id)object {
    if (!object || ![object isKindOfClass:[DCMessageContent class]]) {
        return NO;
    }
    if (object == self) {
        return YES;
    }
    
    DCMessageContent *model = (DCMessageContent *)object;
    if ([model.targetId isEqualToString:self.targetId] && [model.messageId isEqualToString:self.messageId]) {
        return YES;
    }
    return NO;
}

- (NSString *)bg_tableName {
    return kConversationMessageTableName;
}



- (NSComparisonResult)compareMessageDatas:(DCMessageContent *)msg {
    NSComparisonResult result = [[NSNumber numberWithString:self.messageId] compare:[NSNumber numberWithString:msg.messageId]];
    return  result;
}

@end


@implementation DCMessageExtra
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"talk_list" : [DCMessageContent class],
             @"quote_msg" : [DCMessageContent class]
    };
}
@end
