//
//  DCMsgInputBarControl.h
//  DCProjectFile
//
//  Created  on 2023/6/6.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class DCMsgInputBarControl;

@protocol DCMsgInputBarControlDelegate <NSObject>

@required
/// 当输入框位置发生变化时调用
- (void)chatInputBar:(DCMsgInputBarControl *)chatInputBar shouldChangeFrame:(CGRect)frame;
/// 点击发送按钮时调用
- (void)chatInputBar:(DCMsgInputBarControl *)chatInputBar didSendMessage:(NSString *)message mentionedUserIds:(nullable NSString *)uids;
/// 发起视频邀请
- (void)chatInputBar:(DCMsgInputBarControl *)chatInputBar sendCall:(QBRTCConferenceType)conferenceType;

- (void)chatInputBar:(DCMsgInputBarControl *)chatInputBar onMentionedUser:(void(^)(NSArray *selUsers))complete;
@end


@interface DCMsgInputBarControl : UIView
@property (nonatomic, copy) NSString *targetId;
@property (nonatomic, assign) DCConversationType conversationType;
@property (nonatomic, strong) UIButton *emojiButton;
@property (nonatomic, weak) id <DCMsgInputBarControlDelegate>delegate;
@property (nonatomic, assign) KBottomBarStatus currentBottomBarStatus;
@property (nonatomic, strong) UITextView *inputTextView;
@property (nonatomic, assign) BOOL isMentionedEnabled;
@property (nonatomic, strong) DCGroupDataModel *groupModel;
- (instancetype)initWithFrame:(CGRect)frame conversationType:(DCConversationType)conversationType;

- (void)animationLayoutBottomBarWithStatus:(KBottomBarStatus)bottomBarStatus animated:(BOOL)animated;

/*!
 撤销录音
 */
- (void)cancelVoiceRecord;

/*!
 结束录音
 */
- (void)endVoiceRecord;

- (void)addMentionedUser:(DCUserInfo *)userInfo;
@end




NS_ASSUME_NONNULL_END
