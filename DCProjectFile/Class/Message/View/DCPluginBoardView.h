//
//  DCPluginBoardView.h
//  DCProjectFile
//
//  Created  on 2023/6/13.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol DCPluginBoardViewDelegate <NSObject>

- (void)pluginBoardViewMakeCall:(QBRTCConferenceType)conferenceType;
- (void)pluginBoardViewWillInput;
- (void)pluginBoardViewDidEndInput;
@end
@interface DCPluginBoardView : UIView
@property (nonatomic, copy) NSString *targetId;
@property (nonatomic, assign) DCConversationType conversationType;
@property (nonatomic, strong) DCGroupDataModel *groupModel;
@property (nonatomic, weak) id <DCPluginBoardViewDelegate> delegate;
@end


@interface DCPluginBoardCell : UICollectionViewCell
@property (nonatomic, strong) NSDictionary *itemData;

@end
NS_ASSUME_NONNULL_END
