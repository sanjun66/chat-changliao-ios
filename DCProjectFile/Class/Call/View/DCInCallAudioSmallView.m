//
//  DCInCallAudioSmallView.m
//  DCProjectFile
//
//  Created  on 2023/7/27.
//

#import "DCInCallAudioSmallView.h"

@implementation DCInCallAudioSmallView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self createSubview];
        self.backgroundColor = UIColor.whiteColor;
    }
    return self;
}

- (void)createSubview {
    
    UIImageView *imgView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"call_dianhua"]];
    imgView.frame = CGRectMake(self.width/2-16, 12, 32, 32);
    [self addSubview:imgView];
    
    UILabel *duraLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 44, self.width, 32)];
    duraLabel.font = kFontSize(18);
    duraLabel.textColor = kMainColor;
    duraLabel.text = @"00:00";
    duraLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:duraLabel];
    self.durationLabel = duraLabel;
}
@end
