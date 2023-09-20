//
//  DCFriendApplyModel.h
//  DCProjectFile
//
//  Created  on 2023/6/15.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DCFriendApplyModel : NSObject
@property (nonatomic, copy) NSString *avatar;

@property (nonatomic, copy) NSString *nick_name;

/// 被申请人id，
@property (nonatomic, copy) NSString *friend_id;

/// 申请人id
@property (nonatomic, copy) NSString *uid;

/// 备注信息
@property (nonatomic, copy) NSString *remark;

/// 审核信息
@property (nonatomic, copy) NSString *process_message;

/// 谁申请的谁是maker 审核的是taker
@property (nonatomic, copy) NSString *flag;

/// 1 待审核 2 已同意 3 不同意
@property (nonatomic, assign) NSInteger state;

/// 申请时间
@property (nonatomic, assign) NSInteger created_at;


@property (nonatomic, copy) NSString * id;

@end

NS_ASSUME_NONNULL_END
