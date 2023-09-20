//
//  DCInCallTopView.m
//  DCProjectFile
//
//  Created  on 2023/7/25.
//

#import "DCInCallTopView.h"

@implementation DCInCallTopView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self createSubviews];
    }
    return self;
}


- (void)createSubviews {
    UIButton *exist = [UIButton buttonWithType:UIButtonTypeCustom];
    [exist setImage:[UIImage imageNamed:@"call_enterSmall"] forState:UIControlStateNormal];
    exist.frame = CGRectMake(10, self.height-44, 44, 44);
    [exist addTarget:self action:@selector(existClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:exist];
    
    UILabel *duraLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.width/2-100, self.height-44, 200, 44)];
    duraLabel.font = kFontSize(18);
    duraLabel.textColor = kWhiteColor;
    duraLabel.text = @"00:00";
    duraLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:duraLabel];
    self.durationLabel = duraLabel;
}
- (void)existClick {
    if ([self.delegate respondsToSelector:@selector(onTopViewSmallWindow)]) {
        [self.delegate onTopViewSmallWindow];
    }
}
- (IBAction)emterSmallClick:(id)sender {
    if ([self.delegate respondsToSelector:@selector(onTopViewSmallWindow)]) {
        [self.delegate onTopViewSmallWindow];
    }
}


@end
