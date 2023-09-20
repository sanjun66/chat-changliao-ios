//
//  DCGroupCreateVC.h
//  DCProjectFile
//
//  Created  on 2023/7/6.
//

#import "DCBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface DCGroupCreateVC : DCBaseViewController
@property (nonatomic, copy) void (^createGroupBlock)(NSArray *selItems);
@property (nonatomic, strong) NSArray <DCGroupMember *>*members;
@property (nonatomic, assign) BOOL isDelUser;
@property (nonatomic, assign) BOOL isCallInvited;
@property (nonatomic, assign) BOOL isMentionedUser;
@property (nonatomic, assign) NSInteger role;
@property (nonatomic, assign) NSInteger maxNumber;
@property (nonatomic, assign) BOOL isSetManager;
@property (nonatomic, assign) BOOL isForwardMsg;

@end

NS_ASSUME_NONNULL_END
