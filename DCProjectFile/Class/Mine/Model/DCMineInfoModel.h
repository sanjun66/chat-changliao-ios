//
//  DCMineInfoModel.h
//  DCProjectFile
//
//  Created  on 2023/7/5.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DCMineInfoModel : NSObject
@property (nonatomic, copy) NSString * uid;
@property (nonatomic, copy) NSString * sign;
@property (nonatomic, copy) NSString * area_code;
@property (nonatomic, copy) NSString * phone;

@property (nonatomic, copy) NSString * nick_name;
@property (nonatomic, copy) NSString * avatar;
@property (nonatomic, copy) NSString * address;
@property (nonatomic, copy) NSString * account;
@property (nonatomic, copy) NSString * email;
@property (nonatomic, copy) NSString * note_name;

@property (nonatomic, assign) NSInteger sex;
@property (nonatomic, assign) NSInteger age;
@property (nonatomic, assign) NSInteger apply_auth;

@property (nonatomic, assign) BOOL is_friend;
@property (nonatomic, assign) BOOL is_black;
@property (nonatomic, assign) BOOL is_disturb;
@end

NS_ASSUME_NONNULL_END
