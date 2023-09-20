//
//  SCQRCodeVC.h
//  yunbaolive
//
//  Created by mac on 2020/7/16.
//  Copyright © 2020 cat. All rights reserved.
//

#import "DCBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface SCQRCodeVC : DCBaseViewController
@property (nonatomic, copy) void(^scanBlock)(NSString *result);
@end

NS_ASSUME_NONNULL_END
