//
//  DCMsgInputBarControl.m
//  DCProjectFile
//
//  Created  on 2023/6/6.
//

#import "DCMsgInputBarControl.h"
#import "DCChatEmojiView.h"
#import "DCPluginBoardView.h"
#import "DCVoiceRecordControl.h"
#import "DCMentionedStringRangeInfo.h"
#import "DCFriendListModel.h"

#define kEmojiViewHeight (kBottomSafe+240)
#define kInputViewMaxHeight 120
#define kInputViewMinHeight 40

@interface DCMsgInputBarControl ()<UITextViewDelegate,DCVoiceRecordControlDelegate,DCChatEmojiViewDelegate,DCPluginBoardViewDelegate>
@property (nonatomic) CGRect keyboardFrame;
@property (nonatomic) CGFloat oldBarHeight;

@property (nonatomic, strong) UIButton *switchButton;
@property (nonatomic, strong) UIButton *recordButton;
@property (nonatomic, strong) UIButton *additionalButton;

@property (nonatomic, strong) UIView *quoteView;
@property (nonatomic, strong) UILabel *quoteLabel;
@property (nonatomic, strong) DCChatEmojiView *emojiView;
@property (nonatomic, strong) DCPluginBoardView *pluginBoardView;

@property (nonatomic, strong) DCVoiceRecordControl *voiceRecordControl;

@property (nonatomic, strong) NSMutableArray *mentionedRangeInfoList;

@end

@implementation DCMsgInputBarControl

- (instancetype)initWithFrame:(CGRect)frame conversationType:(DCConversationType)conversationType {
    if (self = [super initWithFrame:frame]) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillShowNotification:)
                                                     name:UIKeyboardWillShowNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillHideNotification:)
                                                     name:UIKeyboardWillHideNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(pluginBoardViewWillInput) name:kMessagePswInputAlertWillShowNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(pluginBoardViewDidEndInput) name:kMessagePswInputAlertDidRemoveNotification
                                                   object:nil];
        [self setupSubViews];
        
        self.conversationType = conversationType;
        
        self.isMentionedEnabled = conversationType==DC_ConversationType_GROUP;
        
        self.keyboardFrame = CGRectZero;
        
        self.oldBarHeight = self.height;
    }
    return self;
}

//MARK: - 键盘通知
- (void)keyboardWillShowNotification:(NSNotification*)aNotification {
    NSDictionary *userInfo = [aNotification userInfo];
    CGRect keyboardBeginFrame = [userInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    CGRect keyboardEndFrame = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    if (!CGRectEqualToRect(keyboardBeginFrame, keyboardEndFrame)) {
        UIViewAnimationCurve animationCurve = [userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
        NSInteger animationCurveOption = (animationCurve << 16);
        
        double animationDuration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
        [UIView animateWithDuration:animationDuration delay:0.0 options:animationCurveOption animations:^{
            self.keyboardFrame = keyboardEndFrame;
            [self animationLayoutBottomBarWithStatus:KBottomBarKeyboardStatus animated:NO];
        }completion:^(BOOL finished){
            
        }];
    }
}

- (void)keyboardWillHideNotification:(NSNotification*)aNotification {
    if (self.currentBottomBarStatus == KBottomBarKeyboardStatus) {
        [self animationLayoutBottomBarWithStatus:KBottomBarDefaultStatus animated:NO];
    }
}

//MARK: - 输入框位置变化
- (void)animationLayoutBottomBarWithStatus:(KBottomBarStatus)bottomBarStatus animated:(BOOL)animated {
//    [self.pluginBoardView.extensionView setHidden:YES];
    if (animated == YES) {
        [UIView beginAnimations:@"Move_bar" context:nil];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        [UIView setAnimationDuration:0.25f];
        [UIView setAnimationDelegate:self];
        [self layoutBottomBarWithStatus:bottomBarStatus];
        [UIView commitAnimations];
    } else {
        [self layoutBottomBarWithStatus:bottomBarStatus];
    }
}

- (void)layoutBottomBarWithStatus:(KBottomBarStatus)bottomBarStatus {
//    [self.inputContainerView setBottomBarWithStatus:bottomBarStatus];
    self.currentBottomBarStatus = bottomBarStatus;
    CGRect chatInputBarRect = self.frame;
    float bottomY = [self getBoardViewBottomOriginY];
    switch (bottomBarStatus) {
        case KBottomBarDefaultStatus: {
            [self hiddenEmojiBoardView:YES pluginBoardView:YES];
            chatInputBarRect.origin.y = bottomY - self.bounds.size.height;
        } break;
        case KBottomBarKeyboardStatus: {
            [self hiddenEmojiBoardView:YES pluginBoardView:YES];
            self.emojiButton.selected = self.switchButton.selected = NO;
            self.inputTextView.text = self.inputTextView.text;
            
            //bottomY里面已经去掉了屏幕底部安全距离
            if (self.keyboardFrame.size.height > 0) {
                //手机系统键盘弹起时，键盘的高度也包含了屏幕底部安全距离，相当于减掉了两次屏幕底部安全距离，需要再加回去
                chatInputBarRect.origin.y = bottomY - self.bounds.size.height - self.keyboardFrame.size.height + kBottomSafe;
            }else{
               //使用外接键盘时手机系统键盘并未弹起
                chatInputBarRect.origin.y = bottomY - self.bounds.size.height;
            }
        } break;
        case KBottomBarPluginStatus: {
            [self pluginBoardView];
            if (self.groupModel) {
                self.pluginBoardView.groupModel = self.groupModel;
            }
            [self hiddenEmojiBoardView:YES pluginBoardView:NO];
            self.emojiButton.selected = self.switchButton.selected = NO;
            chatInputBarRect.origin.y = bottomY - self.bounds.size.height - self.pluginBoardView.bounds.size.height  + kBottomSafe;
        } break;
        case KBottomBarEmojiStatus: {
            [self emojiView];
            [self hiddenEmojiBoardView:NO pluginBoardView:YES];
            chatInputBarRect.origin.y = bottomY - self.bounds.size.height - self.emojiView.bounds.size.height + kBottomSafe;
        } break;
        case KBottomBarRecordStatus: {
            [self hiddenEmojiBoardView:YES pluginBoardView:YES];
            chatInputBarRect.origin.y = bottomY - self.bounds.size.height;
        } break;
        default:
            break;
    }
    [self setFrame:chatInputBarRect];
    if (self.delegate && [self.delegate respondsToSelector:@selector(chatInputBar:shouldChangeFrame:)]) {
        [self.delegate chatInputBar:self shouldChangeFrame:chatInputBarRect];
    }
}
- (void)hiddenEmojiBoardView:(BOOL)hiddenEmojiBoardView
             pluginBoardView:(BOOL)hiddenPluginBoardView {
    if (self.emojiView) {
        [self.emojiView setHidden:hiddenEmojiBoardView];
        if (!hiddenEmojiBoardView) {
            self.emojiView.frame = CGRectMake(0, [self getBoardViewBottomOriginY] - kEmojiViewHeight + kBottomSafe, self.width, kEmojiViewHeight);
        }
        [self checkEmojiSendButtonState];
    }
    
    if (self.pluginBoardView) {
        [self.pluginBoardView setHidden:hiddenPluginBoardView];
        if (!hiddenPluginBoardView) {
            self.pluginBoardView.frame = CGRectMake(0, [self getBoardViewBottomOriginY] - kEmojiViewHeight + kBottomSafe,
                                                    self.bounds.size.width, kEmojiViewHeight);
        }
    }
    
}

- (void)setupRecordButton:(BOOL)needShow {
    self.recordButton.hidden = !needShow;
    self.inputTextView.hidden = needShow;
    if (needShow) {
        self.y += (self.height-40);
        self.height -= (self.height-40);
    }else {
        if (self.oldBarHeight != self.height) {
            self.y -= (self.oldBarHeight-40);
            self.height += (self.oldBarHeight-40);
        }
    }
}
- (float)getBoardViewBottomOriginY {
    return kScreenHeight - kBottomSafe - kNavHeight;
}

//MARK: - button点击事件

- (void)switchInputBoxOrRecord:(UIButton *)sender {
    sender.selected = !sender.selected;
    self.emojiButton.selected = NO;
    if (sender.isSelected) {
        [self setupRecordButton:YES];
        if (self.currentBottomBarStatus == KBottomBarKeyboardStatus) {
            [self.inputTextView resignFirstResponder];
        }
        [self animationLayoutBottomBarWithStatus:KBottomBarRecordStatus animated:NO];
    }else {
        [self setupRecordButton:NO];
        [self.inputTextView becomeFirstResponder];
    }
}

- (void)didTouchEmojiDown:(UIButton *)sender {
    sender.selected = !sender.selected;
    self.switchButton.selected = NO;
    [self setupRecordButton:NO];
    if (sender.selected) {
        if (self.currentBottomBarStatus == KBottomBarKeyboardStatus) {
            self.currentBottomBarStatus = KBottomBarEmojiStatus;
            [self.inputTextView resignFirstResponder];
        }
        [self animationLayoutBottomBarWithStatus:KBottomBarEmojiStatus animated:NO];
    }else {
        [self.inputTextView becomeFirstResponder];
    }
}

- (void)didTouchAddtionalDown:(UIButton *)sender {
    if (self.currentBottomBarStatus == KBottomBarPluginStatus) {return;}
    [self.inputTextView resignFirstResponder];
    [self animationLayoutBottomBarWithStatus:KBottomBarPluginStatus animated:NO];
    
}


- (void)voiceRecordButtonTouchDown:(UIButton *)sender {
    sender.backgroundColor = HEXCOLOR(0xe0e2e3);
    
    [self didTouchRecordButtonEvent:UIControlEventTouchDown];
}

- (void)voiceRecordButtonTouchUpInside:(UIButton *)sender {
    sender.backgroundColor = HEXCOLOR(0xffffff);
    
    [self didTouchRecordButtonEvent:UIControlEventTouchUpInside];
}

- (void)voiceRecordButtonTouchCancel:(UIButton *)sender {
    sender.backgroundColor = HEXCOLOR(0xffffff);
    
    [self didTouchRecordButtonEvent:UIControlEventTouchCancel];
}

- (void)voiceRecordButtonTouchDragExit:(UIButton *)sender {
    sender.backgroundColor = HEXCOLOR(0xffffff);
    
    [self didTouchRecordButtonEvent:UIControlEventTouchDragExit];
}

- (void)voiceRecordButtonTouchDragEnter:(UIButton *)sender {
    sender.backgroundColor = HEXCOLOR(0xe0e2e3);
    
    [self didTouchRecordButtonEvent:UIControlEventTouchDragEnter];
}

- (void)voiceRecordButtonTouchUpOutside:(UIButton *)sender {
    sender.backgroundColor = HEXCOLOR(0xffffff);
    [self didTouchRecordButtonEvent:UIControlEventTouchUpOutside];
}

#pragma mark - Private Methods
- (void)didTouchRecordButtonEvent:(UIControlEvents)event {
    switch (event) {
    case UIControlEventTouchDown: {
        [self.voiceRecordControl onBeginRecordEvent];
    } break;
    case UIControlEventTouchUpInside: {
        [self.voiceRecordControl onEndRecordEvent];
    } break;
    case UIControlEventTouchDragExit: {
        [self.voiceRecordControl dragExitRecordEvent];
    } break;
    case UIControlEventTouchUpOutside: {
        [self.voiceRecordControl onCancelRecordEvent];

    } break;
    case UIControlEventTouchDragEnter: {
        [self.voiceRecordControl dragEnterRecordEvent];
    } break;
    case UIControlEventTouchCancel: {
        [self.voiceRecordControl onEndRecordEvent];
    } break;
    default:
        break;
    }
}

- (void)cancelVoiceRecord {
    [self.voiceRecordControl onCancelRecordEvent];
}

- (void)endVoiceRecord {
    [self.voiceRecordControl onEndRecordEvent];
}



#pragma mark - DCVoiceRecordControlDelegate
- (BOOL)recordWillBegin{
//    if ([self.delegate respondsToSelector:@selector(recordWillBegin)]) {
//        RCLogF(@"recordWillBegin:==============> %d", [self.delegate recordWillBegin]);
//        return [self.delegate recordWillBegin];
//    }
    return YES;
}

- (void)voiceRecordControlDidBegin:(DCVoiceRecordControl *)voiceRecordControl {
//    if ([self.delegate respondsToSelector:@selector(recordDidBegin)]) {
//        [self.delegate recordDidBegin];
//    }
}

- (void)voiceRecordControlDidCancel:(DCVoiceRecordControl *)voiceRecordControl {
//    if ([self.delegate respondsToSelector:@selector(recordDidCancel)]) {
//        [self.delegate recordDidCancel];
//    }
}

- (void)voiceRecordControl:(DCVoiceRecordControl *)voiceRecordControl
                    didEnd:(NSData *)recordData
                  duration:(long)duration
                     error:(NSError *)error {
    if (recordData) {
        [[DCSocketClient sharedInstance] createVoiceMsg:self.targetId voiceData:recordData duration:duration];
    }
    
//    if ([self.delegate respondsToSelector:@selector(recordDidEnd:duration:error:)]) {
//        [self.delegate recordDidEnd:recordData duration:duration error:nil];
//    }
}

//MARK: - textView代理

- (void)textViewDidChange:(UITextView *)textView {
    [self checkEmojiSendButtonState];
    CGSize size = [self.inputTextView sizeThatFits:CGSizeMake(self.inputTextView.frame.size.width, kInputViewMaxHeight)];
    CGFloat oldHeight = self.frame.size.height;
    CGFloat newHeight = size.height;
    
    if(newHeight > kInputViewMaxHeight){
        newHeight = kInputViewMaxHeight;
    }
    
    if(newHeight < kInputViewMinHeight){
        newHeight = kInputViewMinHeight;
    }
    
    DCLog(@"%@",NSStringFromCGSize(size));
    
    if(oldHeight == newHeight){
        return;
    }
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        self.y -= (newHeight - oldHeight);
        self.height += (newHeight - oldHeight);
        self.inputTextView.height += (newHeight - oldHeight);
    } completion:^(BOOL finished) {
        self.oldBarHeight = self.height;
        if (self.delegate && [self.delegate respondsToSelector:@selector(chatInputBar:shouldChangeFrame:)]) {
            [self.delegate chatInputBar:self shouldChangeFrame:self.frame];
        }
    }];
}


- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]){
        NSString *formatString =
            [textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if (formatString.length > 0) {
            if (self.mentionedRangeInfoList.count > 0) {
                NSMutableArray *uids = [NSMutableArray array];
                [self.mentionedRangeInfoList enumerateObjectsUsingBlock:^(DCMentionedStringRangeInfo *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    [uids addObject:obj.userId];
                }];
                [self.delegate chatInputBar:self didSendMessage:self.inputTextView.text mentionedUserIds:[uids componentsJoinedByString:@","]];
            }else {
                [self.delegate chatInputBar:self didSendMessage:self.inputTextView.text mentionedUserIds:nil ];
            }
            textView.text = @"";
            [self textViewDidChange:textView];
            [self.mentionedRangeInfoList removeAllObjects];
        }
        return NO;
    }
    
    BOOL shouldUseDefaultChangeText = [self willUpdateInputTextMetionedInfo:text range:range];
    return shouldUseDefaultChangeText;
}

- (void)checkEmojiSendButtonState {
    if (self.emojiView) {
        self.emojiView.sendButton.backgroundColor = [DCTools isEmpty:self.inputTextView.text]?[kWhiteColor colorWithAlphaComponent:0.9]:kMainColor;
    }
}

- (void)pluginBoardViewMakeCall:(QBRTCConferenceType)conferenceType {
    if ([self.delegate respondsToSelector:@selector(chatInputBar:sendCall:)]) {
        [self.delegate chatInputBar:self sendCall:conferenceType];
    }
}
- (void)pluginBoardViewWillInput {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)pluginBoardViewDidEndInput {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShowNotification:) name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHideNotification:) name:UIKeyboardWillHideNotification object:nil];
}

//MARK: - @提醒功能
- (void)addMentionedUser:(DCUserInfo *)userInfo {
    [self insertMentionedUser:userInfo symbolRequset:YES];
}

- (BOOL)willUpdateInputTextMetionedInfo:(NSString *)text range:(NSRange)range{
    BOOL shouldUseDefaultChangeText = YES;
    if (self.isMentionedEnabled) {
        //记录变化的范围
        NSInteger changedLocation = 0;
        NSInteger changedLength = 0;

        //当长度是0 说明是删除字符
        if (text.length == 0) {
            for (DCMentionedStringRangeInfo *mentionedInfo in [self.mentionedRangeInfoList copy]) {
                NSRange mentionedRange = mentionedInfo.range;
                //如果删除的光标在@信息的最后，删除这个@信息
                if (range.length == 1 && (mentionedRange.location + mentionedRange.length == range.location + 1)) {
                    shouldUseDefaultChangeText = NO;
                    [self.inputTextView.textStorage deleteCharactersInRange:mentionedRange];
                    range.location = range.location - mentionedRange.length + 1;
                    range.length = 0;
                    self.inputTextView.selectedRange = NSMakeRange(mentionedRange.location, 0);

                    changedLocation = mentionedInfo.range.location;
                    changedLength = -(NSInteger)mentionedInfo.range.length;

                    [self.mentionedRangeInfoList removeObject:mentionedInfo];
                    break;
                } else if (mentionedRange.location <= range.location &&
                           range.location < mentionedRange.location + mentionedRange.length) {
                    [self.mentionedRangeInfoList removeObject:mentionedInfo];
                    //不能break，否则整块删除会遗漏
                }
            }

            if (changedLength == 0) {
                //如果删除的字符不在@信息 字符中，记录变化的位置和长度
                changedLocation = range.location + 1;
                changedLength = -(NSInteger)range.length;
            }
            [self textViewDidChange:self.inputTextView];
        } else {
            if ([text isEqualToString:@"@"]) {
                if ([self shouldTriggerMentionedChoose:self.inputTextView range:range]) {
                    __weak typeof(self) weakSelf = self;
                    
                    [self.delegate chatInputBar:self onMentionedUser:^(NSArray * _Nonnull selUsers) {
                        [selUsers enumerateObjectsUsingBlock:^(DCFriendItem *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                            DCUserInfo *user = [[DCUserInfo alloc]init];
                            user.name = [DCTools isEmpty:obj.remark]?obj.name:obj.remark;
                            user.userId = obj.friend_id;
                            user.portraitUri = obj.avatar;
                            user.quickbloxId = obj.quickblox_id;
                            [weakSelf addMentionedUser:user];
                        }];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [weakSelf animationLayoutBottomBarWithStatus:(KBottomBarKeyboardStatus) animated:YES];
                        });
                    }];
                }
            }

            //输入内容变化，遍历所有@信息，如果输入的字符起始位置在@信息中，移除这个@信息，否则根据变化情况更新@信息中的range
            for (DCMentionedStringRangeInfo *mentionedInfo in [self.mentionedRangeInfoList copy]) {
                NSRange strRange = mentionedInfo.range;
                if ((range.location > strRange.location) && (range.location < (strRange.location + strRange.length))) {
                    [self.mentionedRangeInfoList removeObject:mentionedInfo];
                    break;
                }
            }
            changedLocation = range.location;
            changedLength = text.length - range.length;
        }

        [self updateAllMentionedRangeInfo:changedLocation length:changedLength];
    }
    return shouldUseDefaultChangeText;
}
- (void)insertMentionedUser:(DCUserInfo *)userInfo symbolRequset:(BOOL)symbolRequset {
    if (!self.isMentionedEnabled || userInfo.userId == nil) {
        return;
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        //获取光标位置
        NSUInteger cursorPosition = self.inputTextView.selectedRange.location;
        if (cursorPosition > self.inputTextView.textStorage.length) {
            cursorPosition = self.inputTextView.textStorage.length;
        }
        //@位置
        NSUInteger mentionedPosition;

        //@的内容
        NSString *insertContent = nil;
        NSInteger changeRangeLength;
        if (symbolRequset) {
            if (userInfo.name.length > 0) {
                insertContent = [NSString stringWithFormat:@"@%@ ", userInfo.name];
            } else {
                insertContent = [NSString stringWithFormat:@"@%@ ", userInfo.userId];
            }
            mentionedPosition = cursorPosition;
            changeRangeLength = [insertContent length];
        } else {
            if (userInfo.name.length > 0) {
                insertContent = [NSString stringWithFormat:@"%@ ", userInfo.name];
            } else {
                insertContent = [NSString stringWithFormat:@"%@ ", userInfo.userId];
            }
            mentionedPosition = (cursorPosition >= 1) ? (cursorPosition - 1) : 0;
            changeRangeLength = [insertContent length] + 1;
        }

        NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:insertContent];
        [attStr addAttribute:NSFontAttributeName
                       value:self.inputTextView.font
                       range:NSMakeRange(0, insertContent.length)];
        [attStr addAttribute:NSForegroundColorAttributeName
                       value:kTextTitColor
                       range:NSMakeRange(0, insertContent.length)];
        [self.inputTextView.textStorage insertAttributedString:attStr atIndex:cursorPosition];
        self.inputTextView.selectedRange = NSMakeRange(cursorPosition + insertContent.length, 0);
        [self updateAllMentionedRangeInfo:cursorPosition length:insertContent.length];

        DCMentionedStringRangeInfo *mentionedStrInfo = [[DCMentionedStringRangeInfo alloc] init];
        mentionedStrInfo.content = insertContent;
        mentionedStrInfo.userId = userInfo.userId;
        mentionedStrInfo.range = NSMakeRange(mentionedPosition, changeRangeLength);
        [self.mentionedRangeInfoList addObject:mentionedStrInfo];

        [self textViewDidChange:self.inputTextView];
        if ([self.inputTextView.delegate respondsToSelector:@selector(textView:shouldChangeTextInRange:replacementText:)]) {
            [self.inputTextView.delegate textView:self.inputTextView shouldChangeTextInRange: self.inputTextView.selectedRange replacementText:insertContent];
        }
    });
}
//遍历@列表，根据修改字符的范围更新@信息的range
- (void)updateAllMentionedRangeInfo:(NSInteger)changedLocation length:(NSInteger)changedLength {
    for (DCMentionedStringRangeInfo *mentionedInfo in self.mentionedRangeInfoList) {
        if (mentionedInfo.range.location >= changedLocation) {
            mentionedInfo.range = NSMakeRange(mentionedInfo.range.location + changedLength, mentionedInfo.range.length);
        }
    }
}
- (BOOL)shouldTriggerMentionedChoose:(UITextView *)textView range:(NSRange)range {
    if (range.location == 0) {
        return YES;
    } else if (!isalnum([textView.text characterAtIndex:range.location - 1])) {
        //@前是数字和字母才不弹出
        return YES;
    }
    return NO;
}
//MARK: - 子视图
- (void)setupSubViews {
    self.backgroundColor = kBackgroundColor;
    [self addSubview:self.switchButton];
    [self addSubview:self.inputTextView];
    [self addSubview:self.recordButton];
    [self addSubview:self.emojiButton];
    [self addSubview:self.additionalButton];
    [self addSubview:self.quoteView];
    [self setupViewLayount];
}

- (void)setupViewLayount {
    self.inputTextView.frame = CGRectMake(52, 4, self.width-52-12-32-8-32-8, 32);
    
    [self.switchButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.offset (-4);
        make.size.mas_equalTo (32);
        make.left.offset (12);
    }];

    [self.additionalButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.switchButton);
        make.right.offset (-12);
        make.size.equalTo(self.switchButton);
    }];

    [self.emojiButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo (self.switchButton);
        make.right.equalTo(self.additionalButton.mas_left).offset (-8);
        make.size.equalTo (self.switchButton);
    }];
//
//    [self.inputTextView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(self.switchButton.mas_right).offset (8);
//        make.centerY.offset (0);
//        make.right.equalTo (self.emojiButton.mas_left).offset (-8);
//        make.height.mas_equalTo (32);
//    }];
//
    [self.recordButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.switchButton.mas_right).offset (8);
        make.centerY.offset (0);
        make.right.equalTo (self.emojiButton.mas_left).offset (-8);
        make.height.mas_equalTo (32);
    }];
}



- (UIButton *)switchButton {
    if (!_switchButton) {
        _switchButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_switchButton setImage:[UIImage imageNamed:@"inputbar_voice"] forState:UIControlStateNormal];
        [_switchButton setImage:[UIImage imageNamed:@"inputbar_keyboard"] forState:UIControlStateSelected];
        [_switchButton addTarget:self action:@selector(switchInputBoxOrRecord:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _switchButton;
}

- (UIButton *)emojiButton {
    if (!_emojiButton) {
        _emojiButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_emojiButton setImage:[UIImage imageNamed:@"inputbar_emoji"] forState:UIControlStateNormal];
        [_emojiButton setImage:[UIImage imageNamed:@"inputbar_keyboard"] forState:UIControlStateSelected];
        [_emojiButton addTarget:self action:@selector(didTouchEmojiDown:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _emojiButton;
}

- (UIButton *)additionalButton {
    if (!_additionalButton) {
        _additionalButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_additionalButton setImage:[UIImage imageNamed:@"inputbar_add"] forState:UIControlStateNormal];
        [_additionalButton addTarget:self action:@selector(didTouchAddtionalDown:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _additionalButton;
}

- (UITextView *)inputTextView {
    if (!_inputTextView) {
        _inputTextView = [[UITextView alloc] initWithFrame:CGRectZero];
        _inputTextView.delegate = self;
        UIEdgeInsets textEdge = self.inputTextView.textContainerInset;
        textEdge.left = 5;
        textEdge.right = 5;
        _inputTextView.textContainerInset = textEdge;
        [_inputTextView setExclusiveTouch:YES];
        [_inputTextView setTextColor:kTextTitColor];
        [_inputTextView setFont:[UIFont systemFontOfSize:15]];
        [_inputTextView setReturnKeyType:UIReturnKeySend];
        _inputTextView.backgroundColor = kWhiteColor;
        _inputTextView.enablesReturnKeyAutomatically = YES;
        _inputTextView.layer.cornerRadius = 8;
        _inputTextView.layer.masksToBounds = YES;
        [_inputTextView setAccessibilityLabel:@"chat_input_textView"];
    }
    return _inputTextView;
}
- (UIButton *)recordButton {
    if (!_recordButton) {
        _recordButton = [[UIButton alloc] initWithFrame:CGRectZero];
        [_recordButton setExclusiveTouch:YES];
        [_recordButton setHidden:YES];
        [_recordButton setTitle:@"按住说话" forState:UIControlStateNormal];
        _recordButton.titleLabel.font = [UIFont systemFontOfSize:15];
        [_recordButton setTitle:@"上划取消"
                       forState:UIControlStateHighlighted];
        [_recordButton setTitleColor:kTextTitColor forState:UIControlStateNormal];
        _recordButton.backgroundColor = kWhiteColor;
        [_recordButton addTarget:self
                          action:@selector(voiceRecordButtonTouchDown:)
                forControlEvents:UIControlEventTouchDown];
        [_recordButton addTarget:self
                          action:@selector(voiceRecordButtonTouchUpInside:)
                forControlEvents:UIControlEventTouchUpInside];
        [_recordButton addTarget:self
                          action:@selector(voiceRecordButtonTouchUpOutside:)
                forControlEvents:UIControlEventTouchUpOutside];
        [_recordButton addTarget:self
                          action:@selector(voiceRecordButtonTouchDragExit:)
                forControlEvents:UIControlEventTouchDragExit];
        [_recordButton addTarget:self
                          action:@selector(voiceRecordButtonTouchDragEnter:)
                forControlEvents:UIControlEventTouchDragEnter];
        [_recordButton addTarget:self
                          action:@selector(voiceRecordButtonTouchCancel:)
                forControlEvents:UIControlEventTouchCancel];
        _recordButton.layer.cornerRadius = 8;
        _recordButton.layer.masksToBounds = YES;
    }
    return _recordButton;
}

- (DCChatEmojiView *)emojiView {
    if (!_emojiView) {
        _emojiView = [[DCChatEmojiView alloc]initWithFrame:CGRectMake(0, kScreenHeight, kScreenWidth, kEmojiViewHeight)];
        _emojiView.hidden = YES;
        _emojiView.targetId = self.targetId;
        _emojiView.delegate = self;
        [self.superview addSubview:_emojiView];
    }
    
    return _emojiView;
}

- (DCPluginBoardView *)pluginBoardView {
    if (!_pluginBoardView) {
        _pluginBoardView = [[DCPluginBoardView alloc]initWithFrame:CGRectMake(0, kScreenHeight, kScreenWidth, kEmojiViewHeight)];
        _pluginBoardView.hidden = YES;
        _pluginBoardView.delegate = self;
        _pluginBoardView.targetId = self.targetId;
        _pluginBoardView.conversationType = self.conversationType;
        [self.superview addSubview:_pluginBoardView];
    }
    
    return _pluginBoardView;
}


- (DCVoiceRecordControl *)voiceRecordControl {
    if (!_voiceRecordControl) {
        _voiceRecordControl = [[DCVoiceRecordControl alloc] initWithConversationType:DC_ConversationType_PRIVATE];
        _voiceRecordControl.delegate = self;
    }
    return _voiceRecordControl;
}

- (NSMutableArray *)mentionedRangeInfoList {
    if (!_mentionedRangeInfoList) {
        _mentionedRangeInfoList = [[NSMutableArray alloc] init];
    }
    return _mentionedRangeInfoList;
}



- (void)emojiViewDidInputText:(nonnull NSString *)text {
    if (nil == text) {
        [self.inputTextView deleteBackward];
    } else {
        NSString *replaceString = text;
        if (replaceString.length < 5000) {
            NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:replaceString];
            [attStr addAttribute:NSFontAttributeName
                           value:self.inputTextView.font
                           range:NSMakeRange(0, replaceString.length)];
            [attStr addAttribute:NSForegroundColorAttributeName
                           value:kTextTitColor
                           range:NSMakeRange(0, replaceString.length)];
            NSInteger cursorPosition;
            if (self.inputTextView.selectedTextRange) {
                cursorPosition = self.inputTextView.selectedRange.location;
            } else {
                cursorPosition = 0;
            }
            //获取光标位置
            if (cursorPosition > self.inputTextView.textStorage.length)
                cursorPosition = self.inputTextView.textStorage.length;
            [self.inputTextView.textStorage insertAttributedString:attStr atIndex:cursorPosition];
            //输入表情触发文本框变化，更新@信息的range
            if ([self.inputTextView.delegate respondsToSelector:@selector(textView:shouldChangeTextInRange:replacementText:)]) {
                [self.inputTextView.delegate textView:self.inputTextView shouldChangeTextInRange:self.inputTextView.selectedRange replacementText:text];
            }
            
            NSRange range;
            range.location = self.inputTextView.selectedRange.location + text.length;
            range.length = 0;
            self.inputTextView.selectedRange = range;
        }
    }
    
    UITextView *textView = self.inputTextView;
    CGRect line = [textView caretRectForPosition:textView.selectedTextRange.start];
    CGFloat overflow =
    line.origin.y + line.size.height - (textView.contentOffset.y + textView.bounds.size.height -
                                        textView.contentInset.bottom - textView.contentInset.top);
    if (overflow > 0) {
        // We are at the bottom of the visible text and introduced a line feed,
        // scroll down (iOS 7 does not do it)
        // Scroll caret to visible area
        CGPoint offset = textView.contentOffset;
        offset.y += overflow + 7; // leave 7 pixels margin
        // Cannot animate with setContentOffset:animated: or caret will not appear
        __weak typeof(textView) weakTextView = textView;
        [UIView animateWithDuration:.2
                         animations:^{
            [weakTextView setContentOffset:offset];
        }];
        [self textViewDidChange:textView];
    }
    [self checkEmojiSendButtonState];
}

- (void)emojiViewDidSendMessage {
    if (![DCTools isEmpty:self.inputTextView.text]) {
        if (self.mentionedRangeInfoList.count > 0) {
            NSMutableArray *uids = [NSMutableArray array];
            [self.mentionedRangeInfoList enumerateObjectsUsingBlock:^(DCMentionedStringRangeInfo *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [uids addObject:obj.userId];
            }];
            [self.delegate chatInputBar:self didSendMessage:self.inputTextView.text mentionedUserIds:[uids componentsJoinedByString:@","]];
        }else {
            [self.delegate chatInputBar:self didSendMessage:self.inputTextView.text mentionedUserIds:nil];
        }
        
        self.inputTextView.text = @"";
        [self textViewDidChange:self.inputTextView];
        [self.mentionedRangeInfoList removeAllObjects];
    }
}

- (void)emojiViewDidTapDelete {
    [self.inputTextView deleteBackward];
    [self willUpdateInputTextMetionedInfo:@"" range:self.inputTextView.selectedRange];
}
@end
