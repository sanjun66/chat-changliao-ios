//
//  DCMsgForwardCheckVC.h
//  DCProjectFile
//
//  Created  on 2023/9/6.
//

#import "DCBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface DCMsgForwardCheckVC : DCBaseViewController
@property (nonatomic, strong, nullable) NSArray <DCMessageContent *> *forwardMsgs;
@property (nonatomic, assign) NSInteger forwardAction;
@end

NS_ASSUME_NONNULL_END
