//
//  DCUserInfo.m
//  DCProjectFile
//
//  Created  on 2023/6/7.
//

#import "DCUserInfo.h"

@implementation DCUserInfo
- (instancetype)initWithUserId:(NSString *)userId name:(nullable NSString *)username portrait:(nullable NSString *)portrait {
    if (self = [super init]) {
        self.userId = userId;
        self.name = username;
        self.portraitUri = portrait;
    }
    return self;
}

- (NSString *)bg_tableName {
    return kConversationUserInfoTableName;
}

+(NSArray* _Nonnull)bg_unionPrimaryKeys {
    return @[@"userId"];
}

- (BOOL)isEqual:(id)object {
    if (!object || ![object isKindOfClass:[DCUserInfo class]]) {
        return NO;
    }
    if (object == self) {
        return YES;
    }
    
    DCUserInfo *model = (DCUserInfo *)object;
    if ([model.userId isEqualToString:self.userId] && [model.name isEqualToString:self.name] && [model.portraitUri isEqualToString:self.portraitUri]) {
        return YES;
    }
    return NO;
}
@end
