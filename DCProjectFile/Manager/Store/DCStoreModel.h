//
//  DCStoreModel.h
//  DCProjectFile
//
//  Created  on 2023/6/14.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DCStoreModel : NSObject
@property (nonatomic, assign) NSInteger expire_seconds;
@property (nonatomic, copy) NSString *uid;
@property (nonatomic, copy) NSString *token;
@property (nonatomic, copy) NSString *platform;
@property (nonatomic, assign) long saveTime;
@property (nonatomic, copy) NSString * rong_yun_token;
@property (nonatomic, assign) NSInteger quickblox_id;
@property (nonatomic, copy) NSString *quickblox_pwd;
@property (nonatomic, copy) NSString *quickblox_login;
@end

NS_ASSUME_NONNULL_END
