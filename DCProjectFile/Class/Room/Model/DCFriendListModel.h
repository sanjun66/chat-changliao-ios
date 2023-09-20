//
//  DCFriendListModel.h
//  DCProjectFile
//
//  Created  on 2023/6/20.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DCFriendItem : NSObject
@property (nonatomic, copy) NSString *remark;
@property (nonatomic, copy) NSString *avatar;
@property (nonatomic, copy) NSString *account;
@property (nonatomic, copy) NSString *sign;
@property (nonatomic, copy) NSString *friend_id;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) NSInteger group_id;
@property (nonatomic, assign) NSInteger state;
@property (nonatomic, assign) NSInteger quickblox_id;

@property (nonatomic, assign) BOOL is_black;
@property (nonatomic, assign) BOOL is_disturb;
@property (nonatomic, assign) BOOL isSel;

@end

@interface DCFriendListModel : NSObject
@property (nonatomic, copy) NSString *group_name;
@property (nonatomic, strong) NSArray <DCFriendItem*>*group_list;
@end

NS_ASSUME_NONNULL_END
