//
//  DCUserHeaderView.h
//  DCProjectFile
//
//  Created  on 2023/5/29.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class DCMineInfoModel;
@interface DCUserHeaderView : UIView
@property (nonatomic, strong) DCMineInfoModel *infoModel;
@property (nonatomic, assign) BOOL isFromGroupChat;
@end

NS_ASSUME_NONNULL_END
