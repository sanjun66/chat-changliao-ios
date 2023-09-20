//
//  DCMessagePswInputAlert.m
//  DCProjectFile
//
//  Created  on 2023/7/28.
//

#import "DCMessagePswInputAlert.h"
@interface DCMessagePswInputAlert()

@end

@implementation DCMessagePswInputAlert

- (void)awakeFromNib {
    [super awakeFromNib];
    
}

- (void)setActionType:(NSInteger)actionType {
    _actionType = actionType;
    self.sectetField.placeholder = (actionType==2)?@"给对方留言（选填）":@"请输入拒绝理由（选填）";
    self.titLabel.text = (actionType==2)?@"加好友":@"拒绝";
}

- (void)setIsMaker:(BOOL)isMaker {
    _isMaker = isMaker;
    self.sectetField.placeholder = isMaker?@"请输入消息密码":@"请设置消息密码";
}
- (IBAction)sureClick:(id)sender {
    if (self.actionType != 0 ) {
        if (self.inputAlertComplete) {
            self.inputAlertComplete(self.sectetField.text);
            [self removeFromSuperview];
        }
        return;
    }
    
    if (self.isMaker) {
        if ([DCTools isEmpty:self.sectetField.text]){
            return;
        }
        if (self.sectetField.text.length < 4) {
            [MBProgressHUD showTips:@"密码应大于4位"];
            return;
        }
        if (self.sectetField.text.length > 16) {
            [MBProgressHUD showTips:@"密码应小于16位"];
            return;
        }
        
        if ([self haveChinese:self.sectetField.text]) {
            [MBProgressHUD showTips:@"密码不应有汉字"];
            return;
        }
        
        if (self.inputAlertComplete) {
            self.inputAlertComplete(self.sectetField.text);
            [self removeFromSuperview];
        }
    }else {
        if (self.sectetField.text.length < 4) {
            [MBProgressHUD showTips:@"密码不可小于4位"];
            return;
        }
        if (self.sectetField.text.length > 16) {
            [MBProgressHUD showTips:@"密码不可大于16位"];
            return;
        }
        
        if ([self haveChinese:self.sectetField.text]) {
            [MBProgressHUD showTips:@"密码不能有汉字"];
            return;
        }
        if (self.inputAlertComplete) {
            self.inputAlertComplete(self.sectetField.text);
            [self removeFromSuperview];
        }
    }
    
    
}
- (IBAction)closeClick:(id)sender {
    if (self.inputAlertComplete) {
        self.inputAlertComplete(nil);
        [self removeFromSuperview];
    }
}


- (BOOL)haveChinese:(NSString *)str {
    for (int i=0; i<[str length]; i++) {
        int a = [str characterAtIndex:i];
        if (a > 0x4e00 && a < 0x9fff) {
            return YES;
        }
    }
    return NO;
}
@end
