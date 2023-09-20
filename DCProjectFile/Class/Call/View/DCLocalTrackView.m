//
//  DCLocalTrackView.m
//  DCProjectFile
//
//  Created  on 2023/7/25.
//

#import "DCLocalTrackView.h"

@implementation DCLocalTrackView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.avatar];
    }
    return self;
}


- (void)layoutSubviews {
    [super layoutSubviews];
    self.avatar.frame = self.bounds;
}
- (UIImageView *)avatar {
    if (!_avatar) {
        _avatar = [[UIImageView alloc]init];
        _avatar.contentMode = UIViewContentModeScaleAspectFill;
        _avatar.layer.masksToBounds = YES;
        _avatar.userInteractionEnabled = NO;
        _avatar.hidden = YES;
    }
    return _avatar;
}
@end
