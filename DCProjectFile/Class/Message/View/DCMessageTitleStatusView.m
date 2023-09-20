//
//  DCMessageTitleStatusView.m
//  DCProjectFile
//
//  Created  on 2023/6/28.
//

#import "DCMessageTitleStatusView.h"
@interface DCMessageTitleStatusView ()
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftMargin;
@end


@implementation DCMessageTitleStatusView

- (void)setStatus:(KSocketStatus)status {
    _status = status;
    switch (status) {
        case KSocketDefaultStatus:
        {
            [self.activityView stopAnimating];
            self.activityView.hidden = YES;
            self.titleLabel.text = @"消息";
            self.leftMargin.constant = -20;
        }
            break;
            
        case KSocketConnectingStatus:
        {
            [self.activityView startAnimating];
            self.activityView.hidden = NO;
            self.titleLabel.text = @"连接中···";
            self.leftMargin.constant = 10;
        }
            break;
            
        case KSocketReceivingStatus:
        {
            [self.activityView startAnimating];
            self.activityView.hidden = NO;
            self.titleLabel.text = @"接收中···";
            self.leftMargin.constant = 10;
        }
            break;
            
        case KSocketNetworkFailStatus:
        {
            [self.activityView stopAnimating];
            self.activityView.hidden = YES;
            self.titleLabel.text = @"未连接";
            self.leftMargin.constant = -20;
        }
            break;
            
        case KSocketUnknowFailStatus:
        {
            [self.activityView stopAnimating];
            self.activityView.hidden = YES;
            self.titleLabel.text = @"未连接";
            self.leftMargin.constant = -20;
        }
            break;
            
        default:
            
            break;
    }
}
@end
