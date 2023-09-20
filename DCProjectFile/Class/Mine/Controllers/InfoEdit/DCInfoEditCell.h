//
//  DCInfoEditCell.h
//  DCProjectFile
//
//  Created  on 2023/7/10.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DCInfoEditCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titLabel;
@property (weak, nonatomic) IBOutlet UILabel *descLabel;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImgView;
@property (weak, nonatomic) IBOutlet UIImageView *arrow;
@property (weak, nonatomic) IBOutlet UISwitch *switchView;
@property (nonatomic, copy) void (^switchViewBlock)(DCInfoEditCell *selCell , BOOL isOn);
@property (nonatomic, copy) void (^changeStateBlock)(UISwitch *switchView);
@end

NS_ASSUME_NONNULL_END
