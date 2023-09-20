//
//  DCUserManager.h
//  DCProjectFile
//
//  Created  on 2023/6/14.
//

#import <Foundation/Foundation.h>
#import "DCStoreModel.h"
#import "DCUserInfo.h"
#import "DCStatusDefine.h"
#import "DCGroupDataModel.h"
#import "DCOssConfigModel.h"
#import "DCVersionModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface DCUserManager : NSObject
@property (nonatomic, strong, nullable) DCStoreModel *model;

@property (nonatomic, strong) DCUserInfo *currentUserInfo;

@property (nonatomic, strong) NSData *deviceToken;

@property (nonatomic, strong) DCOssConfigModel *ossModel;

@property (nonatomic, strong, nullable) NSDictionary *pushUserInfo;
@property (nonatomic, assign) NSInteger applyNumber;
@property (nonatomic, strong, nullable) DCVersionModel *verModel;

/// 获取用户信息
- (void)getConversationData:(DCConversationType)conversationType targerId:(NSString *)userId completion:(void (^)(DCUserInfo *userInfo))completion;

/// 请求用户信息并保存
- (void)requesetConversationData:(DCConversationType)conversationType targerId:(NSString *)userId completion:(void (^)(DCUserInfo *userInfo , DCGroupDataModel *groupData))completion;

- (void)requestConversationDistrubState:(DCConversationType)conversationType targerId:(NSString *)userId completion:(void (^)(NSString *state))completion;

- (void)saveUser:(DCStoreModel*)model;

- (DCStoreModel *)userModel;

- (void)cleanUser;

- (void)resetRootVc;
- (void)checkVersionState;
+ (instancetype)sharedManager;

@end

NS_ASSUME_NONNULL_END
