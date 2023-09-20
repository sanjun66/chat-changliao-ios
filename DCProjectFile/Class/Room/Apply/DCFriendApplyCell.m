//
//  DCFriendApplyCell.m
//  DCProjectFile
//
//  Created  on 2023/6/15.
//

#import "DCFriendApplyCell.h"

@interface DCFriendApplyCell ()
@property (weak, nonatomic) IBOutlet UIImageView *avatar;
@property (weak, nonatomic) IBOutlet UILabel *nickname;
@property (weak, nonatomic) IBOutlet UILabel *remark;
@property (weak, nonatomic) IBOutlet UILabel *stateLabel;
@property (weak, nonatomic) IBOutlet UIView *makerView;
@property (weak, nonatomic) IBOutlet UIButton *refuse;
@property (weak, nonatomic) IBOutlet UIButton *accept;

@end

@implementation DCFriendApplyCell

- (void)awakeFromNib {
    [super awakeFromNib];
    UIView *selectedBackgroundView = [[UIView alloc]init];
    selectedBackgroundView.backgroundColor = [kMainColor colorWithAlphaComponent:0.05];
    self.selectedBackgroundView = selectedBackgroundView;
}

- (void)setModel:(DCFriendApplyModel *)model {
    _model = model;
    
    if ([model.flag isEqualToString:@"taker"]) {
        if (model.state == 1) {
            self.stateLabel.text = @"等待验证";
            self.stateLabel.textColor = kTextSubColor;
            self.makerView.hidden = NO;
            self.stateLabel.hidden = YES;
        }else if (model.state==2) {
            self.stateLabel.text = @"已同意";
            self.makerView.hidden = YES;
            self.stateLabel.hidden = NO;
            self.stateLabel.textColor = kMainColor;
            self.stateLabel.hidden = NO;
        }else {
            self.stateLabel.text = @"已拒绝";
            self.stateLabel.hidden = NO;
            self.makerView.hidden = YES;
            self.stateLabel.textColor = HEX(@"FF4A50");
        }
    }else {
        self.makerView.hidden = YES;
        if (model.state == 1) {
            self.stateLabel.text = @"等待验证";
            self.stateLabel.textColor = kTextSubColor;
        }else if (model.state==2) {
            self.stateLabel.text = @"对方已同意";
            self.stateLabel.textColor = kMainColor;
        }else {
            self.stateLabel.text = @"对方已拒绝";
            self.stateLabel.textColor = HEX(@"FF4A50");
        }
    }
    
    if (model.state==1 || model.state==2) {
        self.remark.text = model.remark;
    }else {
        self.remark.text = model.process_message;
    }
    
    [self.avatar sd_setImageWithURL:[NSURL URLWithString:model.avatar]];
    self.nickname.text = model.nick_name;
    
    
}
- (IBAction)acceptClick:(UIButton *)sender {
    if (self.actionBlock) {
        self.actionBlock(self.model, sender.tag);
    }
}
- (IBAction)refuseClick:(UIButton *)sender {
    if (self.actionBlock) {
        self.actionBlock(self.model, sender.tag);
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
