//
//  DCTextView.h
//  DCProjectFile
//
//  Created  on 2023/6/7.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class DCTextView;

@protocol DCTextViewDelegate <NSObject>

@optional
- (void)dctextView:(DCTextView *)textView textDidChange:(NSString *)text;

@end

@interface DCTextView : UITextView
/*!
 是否关闭菜单

 @discussion 默认值为NO。
 */
@property (nonatomic, assign) BOOL disableActionMenu;

@property (nonatomic, weak) id<DCTextViewDelegate> textChangeDelegate;
@end

NS_ASSUME_NONNULL_END
