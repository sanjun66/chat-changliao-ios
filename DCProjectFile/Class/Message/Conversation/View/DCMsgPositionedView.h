//
//  DCMsgPositionedView.h
//  DCProjectFile
//
//  Created  on 2023/8/23.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol DCMsgPositionedViewDelegate <NSObject>

- (void)positionMessageLocaltionWithActionType:(NSInteger)actionType;


@end
@interface DCMsgPositionedView : UIView
@property (nonatomic, copy) NSString *noticeString;
@property (nonatomic, assign) NSInteger actionType;
@property (nonatomic, weak) id <DCMsgPositionedViewDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
