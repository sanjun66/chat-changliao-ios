//
//  DCSearchUserModel.h
//  DCProjectFile
//
//  Created  on 2023/6/14.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DCSearchUserModel : NSObject
@property (nonatomic, copy) NSString *avatar;
@property (nonatomic, copy) NSString *nick_name;
@property (nonatomic, copy) NSString *sign;
@property (nonatomic, copy) NSString *id;
@property (nonatomic, copy) NSString *keywords;

@property (nonatomic, assign) NSInteger is_friend;

@end

NS_ASSUME_NONNULL_END
