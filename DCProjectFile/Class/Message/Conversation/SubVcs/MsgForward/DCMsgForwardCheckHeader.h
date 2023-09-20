//
//  DCMsgForwardCheckHeader.h
//  DCProjectFile
//
//  Created  on 2023/9/6.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol DCMsgForwardCheckHeaderDelegate <NSObject>

- (void)msgForwardHeaderSelectorWith:(NSInteger)action;

@end
@interface DCMsgForwardCheckHeader : UIView
@property (nonatomic, weak) id <DCMsgForwardCheckHeaderDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
