//
//  DCTextView.m
//  DCProjectFile
//
//  Created  on 2023/6/7.
//

#import "DCTextView.h"

@implementation DCTextView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _disableActionMenu = NO;
    }
    return self;
}
- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    if (self.disableActionMenu) {
        return NO;
    }
    [[UIMenuController sharedMenuController] setMenuItems:nil];
    return [super canPerformAction:action withSender:sender];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    _disableActionMenu = NO;
}

- (void)setText:(NSString *)text {
    [super setText:text];
    if (self.textChangeDelegate && [self.textChangeDelegate respondsToSelector:@selector(dctextView:textDidChange:)]) {
        [self.textChangeDelegate dctextView:self textDidChange:text];
    }
}

@end
