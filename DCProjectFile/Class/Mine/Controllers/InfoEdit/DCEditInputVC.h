//
//  DCEditInputVC.h
//  DCProjectFile
//
//  Created  on 2023/7/10.
//

#import "DCBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface DCEditInputVC : DCBaseViewController
@property (nonatomic, copy) void (^editInputBlock)(NSString *text);
@property (nonatomic, assign) KTextInputType inputType;
@end

NS_ASSUME_NONNULL_END
