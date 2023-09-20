//
//  DCInfoEditCell.m
//  DCProjectFile
//
//  Created  on 2023/7/10.
//

#import "DCInfoEditCell.h"
@interface DCInfoEditCell ()

@end

@implementation DCInfoEditCell
- (IBAction)clickSwitchView:(UISwitch *)sender {
    NSLog(@"%@",@(sender.isOn));
    if (self.switchViewBlock) {
        self.switchViewBlock(self,sender.isOn);
    }
    if (self.changeStateBlock) {
        self.changeStateBlock(sender);
    }
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
