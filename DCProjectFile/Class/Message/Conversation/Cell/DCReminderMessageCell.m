//
//  DCReminderMessageCell.m
//  DCProjectFile
//
//  Created  on 2023/7/10.
//

#import "DCReminderMessageCell.h"
@interface DCReminderMessageCell ()
@property (nonatomic, strong) UILabel *msgTimeLabel;
@property (nonatomic, strong) YYLabel *remindLabel;

@end

@implementation DCReminderMessageCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.contentView.transform = CGAffineTransformMakeRotation(-M_PI);
        [self.contentView addSubview:self.msgTimeLabel];
        [self.contentView addSubview:self.remindLabel];
    }
    return self;
}
- (void)setDataModel:(DCMessageContent *)model {
    self.model = model;
    CGSize txtSize = [DCReminderMessageCell textSize:model];
    
    if (model.isDisplayMsgTime) {
        self.msgTimeLabel.hidden = NO;
        self.msgTimeLabel.frame = CGRectMake(0, 0, kScreenWidth, 20);
        self.remindLabel.frame = CGRectMake(20, 30, kScreenWidth-40, txtSize.height);
        self.msgTimeLabel.text = [[DCTools convertStrToTime:model.timestamp] componentsSeparatedByString:@" "].lastObject;
    }else {
        self.msgTimeLabel.hidden = YES;
        self.remindLabel.frame = CGRectMake(20, 10, kScreenWidth-40, txtSize.height);
    }
    
    self.remindLabel.text = model.message;
    
}

+ (CGSize)sizeForMessageModel:(DCMessageContent *)model withCollectionViewWidth:(CGFloat)collectionViewWidth referenceExtraHeight:(CGFloat)extraHeight {
    return CGSizeMake(collectionViewWidth, [self textSize:model].height + (model.isDisplayMsgTime?20:0) + extraHeight);
}

+ (CGSize)textSize:(DCMessageContent *)model {
    CGSize size = [model.message textSizeIn:CGSizeMake(kScreenWidth-40, CGFLOAT_MAX) font:[UIFont systemFontOfSize:kTextFontSize]];
    return CGSizeMake(ceilf(size.width), ceilf(size.height));
}

- (YYLabel *)remindLabel {
    if (!_remindLabel) {
        _remindLabel = [[YYLabel alloc]initWithFrame:CGRectZero];
        _remindLabel.font = [UIFont systemFontOfSize:kTextFontSize];
        _remindLabel.textColor = kTextSubColor;
        _remindLabel.numberOfLines = 0;
        _remindLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _remindLabel.textAlignment = NSTextAlignmentCenter;
        _remindLabel.userInteractionEnabled = NO;
    }
    
    return _remindLabel;
}
- (UILabel *)msgTimeLabel {
    if (!_msgTimeLabel) {
        _msgTimeLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        _msgTimeLabel.font = kFontSize(12);
        _msgTimeLabel.textColor = kTextSubColor;
        _msgTimeLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _msgTimeLabel;
}
@end
