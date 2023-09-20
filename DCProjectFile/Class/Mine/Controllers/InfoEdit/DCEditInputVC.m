//
//  DCEditInputVC.m
//  DCProjectFile
//
//  Created  on 2023/7/10.
//

#import "DCEditInputVC.h"

@interface DCEditInputVC ()<UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UILabel *lengthLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *containerHeight;
@property (nonatomic, assign) int maxTextLength;
@property (nonatomic, assign) NSString *preText;

@end

@implementation DCEditInputVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.textView.placeholderColor = kTextSubColor;
    // 添加UITextView监听
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textViewDidChange) name:UITextViewTextDidChangeNotification object:nil];
    switch (self.inputType) {
        case KTextInputTypeNickName:
            self.preText = @"昵称";
            self.maxTextLength = 8;
            break;
        case KTextInputTypeNoteName:
            self.preText = @"备注名";
            self.maxTextLength = 8;
            break;
        case KTextInputTypeGroupName:
            self.preText = @"群名称";
            self.maxTextLength = 20;
            break;
        case KTextInputTypeGroupNotice:
            self.preText = @"群公告";
            self.maxTextLength = 200;
            self.containerHeight.constant = 200;
            break;
            
        default:
            break;
    }
    self.navigationItem.title = [NSString stringWithFormat:@"修改%@",self.preText];
    self.textView.placeholder = [NSString stringWithFormat:@"请输入%@",self.preText];
    self.lengthLabel.text = [NSString stringWithFormat:@"0/%ld", self.maxTextLength];
    
}

- (void)textViewDidChange {
    NSInteger maxLength = self.maxTextLength;
    NSString *toBeString = self.textView.text;
    
    // 获取高亮部分
    UITextRange *selectedRange = [self.textView markedTextRange];
    UITextPosition *position = [self.textView positionFromPosition:selectedRange.start offset:0];
    if (!position || !selectedRange) {
        if (toBeString.length>maxLength) {
            NSRange rangeIndex = [toBeString rangeOfComposedCharacterSequencesForRange:NSMakeRange(0, maxLength)];
            [MBProgressHUD showTips:[NSString stringWithFormat:@"%@不可以超过%ld个字",self.preText, maxLength]];
            if (rangeIndex.length == 1) {
                self.textView.text = [toBeString substringToIndex:maxLength];
            }else {
                NSRange rangeRange = [toBeString rangeOfComposedCharacterSequencesForRange:NSMakeRange(0, maxLength)];
                self.textView.text = [toBeString substringWithRange:rangeRange];
            }
        }
    }
    
    self.lengthLabel.text = [NSString stringWithFormat:@"%ld/%ld",self.textView.text.length , maxLength];
}
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {

    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}

- (IBAction)confirmButtonClick:(id)sender {
    if ([DCTools isEmpty:self.textView.text] && self.inputType!=KTextInputTypeNoteName) {
        return;
    }
    
    self.editInputBlock(self.textView.text);
    [self.navigationController popViewControllerAnimated:YES];
}

@end
