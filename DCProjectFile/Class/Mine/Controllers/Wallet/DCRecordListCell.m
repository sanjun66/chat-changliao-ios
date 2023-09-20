//
//  DCRecordListCell.m
//  DCProjectFile
//
//  Created  on 2023/9/15.
//

#import "DCRecordListCell.h"
@interface DCRecordListCell ()
@property (weak, nonatomic) IBOutlet UILabel *titLael;
@property (weak, nonatomic) IBOutlet UILabel *stateLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *amountLabel;

@end
@implementation DCRecordListCell

- (void)setModel:(DCRecordListModel *)model {
    _model = model;
    self.titLael.text = [NSString stringWithFormat:@"%@（%@）",model.type==1?@"充值":@"提现",model.coin];
    self.timeLabel.text = model.created_at;
    if (model.state==1) {
        self.stateLabel.text = @"等待审核";
    }
    if (model.state==2) {
        self.stateLabel.text = @"正在审核中";
    }
    if (model.state==3) {
        self.stateLabel.text = @"成功";
    }
    if (model.state==4) {
        self.stateLabel.text = [NSString stringWithFormat:@"失败 %@",model.reason];
    }
    
    self.amountLabel.text = [NSString stringWithFormat:@"%@%@",model.type==1?@"+":@"-",model.amount];
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
