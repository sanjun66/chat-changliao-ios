//
//  DCWebKitVC.h
//  DCProjectFile
//
//  Created  on 2023/7/5.
//

#import "DCBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface DCWebKitVC : DCBaseViewController
@property (nonatomic, copy) NSString *titleStr;
@property (nonatomic, copy) NSString *jumpUrl;
@property (nonatomic, copy) NSString *localPath;
@end

NS_ASSUME_NONNULL_END
