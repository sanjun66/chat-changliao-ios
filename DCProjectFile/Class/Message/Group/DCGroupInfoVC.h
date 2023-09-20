//
//  DCGroupInfoVC.h
//  DCProjectFile
//
//  Created  on 2023/7/11.
//

#import "DCBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface DCGroupInfoVC : DCBaseViewController
@property (nonatomic, strong) DCGroupDataModel *groupData;
@property (nonatomic, copy) NSString *groupId;

@end

NS_ASSUME_NONNULL_END
