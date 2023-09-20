//
//  DCMsgForwardCheckHeader.m
//  DCProjectFile
//
//  Created  on 2023/9/6.
//

#import "DCMsgForwardCheckHeader.h"


@implementation DCMsgForwardCheckHeader

- (IBAction)friendClick:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(msgForwardHeaderSelectorWith:)]) {
        [self.delegate msgForwardHeaderSelectorWith:1];
    }
}

- (IBAction)groupClick:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(msgForwardHeaderSelectorWith:)]) {
        [self.delegate msgForwardHeaderSelectorWith:2];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
