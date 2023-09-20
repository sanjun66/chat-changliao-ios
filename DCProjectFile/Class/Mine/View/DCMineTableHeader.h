//
//  DCMineTableHeader.h
//  DCProjectFile
//
//  Created  on 2023/5/24.
//

#import <UIKit/UIKit.h>
#import "DCMineInfoModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface DCMineTableHeader : UIView
@property (nonatomic, strong) DCMineInfoModel *infoModel;
@property (nonatomic, copy) void (^didTapPortraitBlock)(void);
@end

NS_ASSUME_NONNULL_END
