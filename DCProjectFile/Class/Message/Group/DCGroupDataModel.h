//
//  DCGroupDataModel.h
//  DCProjectFile
//
//  Created  on 2023/7/11.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@interface DCGroupNotica : NSObject

@end
@interface DCGroupInfo : NSObject
@property (nonatomic, copy) NSString *groupId;
@property (nonatomic, copy) NSString *avatar;
// 群主id
@property (nonatomic, copy) NSString *uid;
@property (nonatomic, copy) NSString *describe;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *dismissed_at;

@property (nonatomic, assign) BOOL is_mute;
@property (nonatomic, assign) BOOL is_dismiss;
@property (nonatomic, assign) NSInteger max_num;
/// 管理员最多几个
@property (nonatomic, assign) NSInteger max_manager;
/// 群管理员说明字段
@property (nonatomic, copy) NSString * manager_explain;
/// 判断是否可以音频通话 0不可以 1可以
@property (nonatomic, assign) BOOL is_audio;
/// 判断是否拥有音频权限  0没有 1有
/// 我在此群中的角色 0-普通群员 1-群主 2-管理员
@property (nonatomic, assign) NSInteger role;

@property (nonatomic, assign) BOOL audio;
@property (nonatomic, assign) BOOL is_disturb;
@property (nonatomic, copy) NSString *audio_expire;
@end

@interface DCGroupMember : NSObject
@property (nonatomic, copy) NSString *avatar;
@property (nonatomic, copy) NSString *uid;
@property (nonatomic, copy) NSString *notes;
@property (nonatomic, assign) BOOL is_mute;
@property (nonatomic, assign) BOOL is_disturb;
@property (nonatomic, assign) NSInteger quickblox_id;

// 在群中的角色 0-普通群员 1-群主 2-管理员
@property (nonatomic, assign) NSInteger role;

@end

@interface DCGroupDataModel : NSObject
@property (nonatomic, strong) DCGroupInfo *group_info;
@property (nonatomic, strong) NSArray <DCGroupMember*>*group_member;
@property (nonatomic, strong) NSArray <DCGroupNotica*>*group_notice;
@property (nonatomic, assign) NSInteger code;
@end

NS_ASSUME_NONNULL_END
