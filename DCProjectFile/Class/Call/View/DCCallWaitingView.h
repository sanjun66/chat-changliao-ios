//
//  DCCallWaitingView.h
//  DCProjectFile
//
//  Created  on 2023/7/25.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol DCCallWaitingViewDelegate <NSObject>

- (void)waitingViewOnAcceptCall;
- (void)waitingViewOnRefuseCall;

@optional
- (void)waitingViewOnCancelCall;
- (void)waitingViewOnTapControll;

@end
@interface DCCallWaitingView : UIView
@property (nonatomic, weak) id <DCCallWaitingViewDelegate> delegate;
@property (strong, nonatomic) NSArray<DCUserInfo*>*members;
@property (nonatomic, copy) NSString *fromUid;
@property (nonatomic, assign) QBRTCConferenceType conferenceType;

@property (strong, nonatomic) NSArray<DCUserInfo*>*inviteMembers;
@property (nonatomic, assign) BOOL isMultit;

- (void)hideSubviews;

@end

NS_ASSUME_NONNULL_END
