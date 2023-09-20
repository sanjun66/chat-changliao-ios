//
//  DCMessagePswInputAlert.h
//  DCProjectFile
//
//  Created  on 2023/7/28.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DCMessagePswInputAlert : UIView
@property (nonatomic, assign) BOOL isMaker;
/// 2= 添加好友 3=拒绝添加
@property (nonatomic, assign) NSInteger actionType;

@property (weak, nonatomic) IBOutlet UILabel *titLabel;

@property (weak, nonatomic) IBOutlet UIView *backView;
@property (weak, nonatomic) IBOutlet UITextField *sectetField;
@property (nonatomic, copy) void (^inputAlertComplete)( NSString * _Nullable text);
@end

NS_ASSUME_NONNULL_END
