//
//  DCUserInfo.h
//  DCProjectFile
//
//  Created  on 2023/6/7.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DCUserInfo : NSObject
/*!
 用户 ID
 */
@property (nonatomic, copy) NSString *userId;

/*!
 用户名称
 */
@property (nonatomic, copy) NSString *name;

/*!
 用户头像的 URL
 */
@property (nonatomic, copy, nullable) NSString *portraitUri;

/*!
 用户备注
 */
@property (nonatomic, copy, nullable) NSString *alias;

/**
 用户信息附加字段
 */
@property (nonatomic, copy, nullable) NSString *extra;


@property (nonatomic, assign) NSInteger quickbloxId;

/*!
 用户信息的初始化方法

 @param userId      用户 ID
 @param username    用户名称
 @param portrait    用户头像的 URL
 @return            用户信息对象
 */
- (instancetype)initWithUserId:(NSString *)userId name:(nullable NSString *)username portrait:(nullable NSString *)portrait;

@end

NS_ASSUME_NONNULL_END
