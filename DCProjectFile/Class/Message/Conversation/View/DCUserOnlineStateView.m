//
//  DCUserOnlineStateView.m
//  DCProjectFile
//
//  Created  on 2023/9/13.
//

#import "DCUserOnlineStateView.h"
@interface DCUserOnlineStateView ()
@property (nonatomic, strong) UIView *backView;


@end
@implementation DCUserOnlineStateView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupViews];
    }
    return self;
}

- (void)setupViews {
    [self addSubview:self.backView];
    [self.backView addSubview:self.positionItem];
}

- (UIView *)backView {
    if (!_backView) {
        _backView = [[UIView alloc]initWithFrame:CGRectMake(5, 5, 60, 26)];
        _backView.layer.masksToBounds = NO;
        _backView.layer.shadowOpacity = 0.1;
        _backView.layer.shadowOffset = CGSizeZero;
        _backView.layer.shadowRadius = 5;
        
        CALayer *cornerLayer = [CALayer layer];
        cornerLayer.frame = _backView.bounds;
        cornerLayer.backgroundColor = kWhiteColor.CGColor;
        CGPathRef path = [UIBezierPath bezierPathWithRoundedRect:_backView.bounds byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(13, 13)].CGPath;
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
        [_positionItem setImage:[UIImage imageNamed:@"user_online_0"] forState:UIControlStateNormal];
        [_positionItem setImage:[UIImage imageNamed:@"user_online_1"] forState:UIControlStateSelected];
//        [_positionItem setTitleEdgeInsets:UIEdgeInsetsMake(0, 3, 0, 0)];
        [_positionItem setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 5)];
        [_positionItem setTitleColor:kTextSubColor forState:UIControlStateNormal];
        [_positionItem setTitleColor:kMainColor forState:UIControlStateSelected];
        [_positionItem setTitle:@"离线" forState:UIControlStateNormal];
        [_positionItem setTitle:@"在线" forState:UIControlStateSelected];
        _positionItem.titleLabel.font = kFontSize(11);
    }
    
    return _positionItem;
}
@end
