//
//  DCGroupInfoHeader.h
//  DCProjectFile
//
//  Created  on 2023/7/12.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DCGroupInfoHeader : UIView
@property (nonatomic, strong) DCGroupDataModel *groupData;
@property (nonatomic, copy) NSString *groupId;
@property (nonatomic, assign) BOOL isGroupOwner;
@property (nonatomic, copy) void (^operateCompleteBlock)(void);
@end

NS_ASSUME_NONNULL_END
