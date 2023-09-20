//
//  DCUserInfoVC.h
//  DCProjectFile
//
//  Created  on 2023/5/29.
//

#import "DCBaseViewController.h"
#import "DCFriendListModel.h"
#import "DCUserInfo.h"
#import "DCGroupDataModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface DCUserInfoVC : DCBaseViewController
@property (nonatomic, strong) DCFriendItem *friendItem;

@property (nonatomic, copy) NSString *toUid;
@property (nonatomic, assign) NSInteger role;
@property (nonatomic, assign) BOOL isFromPriveteChat;
@property (nonatomic, assign) BOOL isFromGroupChat;

@property (nonatomic, strong) DCGroupMember *member;
@property (nonatomic, copy) void (^groupMuteBlock)(DCGroupMember *selMember);
@end

NS_ASSUME_NONNULL_END
