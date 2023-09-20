//
//  DCMsgPositionedView.m
//  DCProjectFile
//
//  Created  on 2023/8/23.
//

#import "DCMsgPositionedView.h"
@interface DCMsgPositionedView ()
@property (nonatomic, strong) UIView *backView;
@property (nonatomic, strong) UIButton *positionItem;

@end

@implementation DCMsgPositionedView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupViews];
    }
    return self;
}

- (void)positionMsgAction:(id)sender {
    if ([self.delegate respondsToSelector:@selector(positionMessageLocaltionWithActionType:)]) {
        [self.delegate positionMessageLocaltionWithActionType:self.actionType];
    }
}

- (void)setNoticeString:(NSString *)noticeString {
    _noticeString = noticeString;
    [self.positionItem setTitle:noticeString forState:UIControlStateNormal];
}

- (void)setupViews {
    [self addSubview:self.backView];
    [self.backView addSubview:self.positionItem];
}

- (UIView *)backView {
    if (!_backView) {
        _backView = [[UIView alloc]initWithFrame:CGRectMake(5, 5, 125, 36)];
        _backView.layer.masksToBounds = NO;
        _backView.layer.shadowOpacity = 0.1;
        _backView.layer.shadowOffset = CGSizeZero;
        _backView.layer.shadowRadius = 5;
        
        CALayer *cornerLayer = [CALayer layer];
        cornerLayer.frame = _backView.bounds;
        cornerLayer.backgroundColor = kWhiteColor.CGColor;
        CGPathRef path = [UIBezierPath bezierPathWithRoundedRect:_backView.bounds byRoundingCorners:UIRectCornerTopLeft|UIRectCornerBottomLeft cornerRadii:CGSizeMake(18, 18)].CGPath;
        CAShapeLayer *lay = [CAShapeLayer layer];
        lay.path = path;
        cornerLayer.mask = lay;
        [_backView.layer addSublayer:cornerLayer];
        
    }
    return _backView;
}

- (UIButton *)positionItem {
    if (!_positionItem) {
        _positionItem = [UIButton buttonWithType:UIButtonTypeCustom];
        _positionItem.frame = self.backView.bounds;
        [_positionItem setImage:[UIImage imageNamed:@"arrow_top"] forState:UIControlStateNormal];
        [_positionItem setTitleEdgeInsets:UIEdgeInsetsMake(0, 3, 0, 0)];
        [_positionItem setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 3)];
        [_positionItem setTitleColor:kMainColor forState:UIControlStateNormal];
//        [_positionItem setTitle:@"113条新消息" forState:UIControlStateNormal];
        _positionItem.titleLabel.font = kFontSize(13);
        [_positionItem addTarget:self action:@selector(positionMsgAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _positionItem;
}
@end
