//
//  DCSearchUserCell.m
//  DCProjectFile
//
//  Created  on 2023/6/14.
//

#import "DCSearchUserCell.h"
@interface DCSearchUserCell ()
@property (weak, nonatomic) IBOutlet UIImageView *avatar;
@property (weak, nonatomic) IBOutlet UILabel *nickName;
@property (weak, nonatomic) IBOutlet UIButton *addButton;

@end

@implementation DCSearchUserCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
- (void)setModel:(DCSearchUserModel *)model {
    _model = model;
    [self.avatar sd_setImageWithURL:[NSURL URLWithString:model.avatar]];
    self.nickName.text = model.nick_name;
    self.addButton.hidden = model.is_friend;
}
- (IBAction)addUser:(id)sender {
    if (self.applyFriendBlock) {
        self.applyFriendBlock(self.model);
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
