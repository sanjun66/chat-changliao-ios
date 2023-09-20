//
//  DCChatEmojiView.h
//  DCProjectFile
//
//  Created  on 2023/6/12.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol DCChatEmojiViewDelegate <NSObject>

- (void)emojiViewDidInputText:(NSString *)text;
- (void)emojiViewDidTapDelete;
- (void)emojiViewDidSendMessage;

@end
@interface DCChatEmojiView : UIView
@property (nonatomic, weak) id <DCChatEmojiViewDelegate>delegate;

@property (nonatomic, copy) NSString *targetId;
@property (nonatomic, strong) UIButton *sendButton;
@property (nonatomic, strong) UIScrollView *emojiBackgroundView;
@end



@interface DCChatEmojiCell : UICollectionViewCell
@property (nonatomic, strong)UILabel *emojiLabel;

@end

NS_ASSUME_NONNULL_END
