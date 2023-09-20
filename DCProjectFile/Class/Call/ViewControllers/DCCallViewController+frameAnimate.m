//
//  DCCallViewController+frameAnimate.m
//  DCProjectFile
//
//  Created  on 2023/7/26.
//

#import "DCCallViewController+frameAnimate.h"

@implementation DCCallViewController (frameAnimate)
- (void)existSmallWindow {
    if (self.session.conferenceType == QBRTCConferenceTypeVideo) {
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.view.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
            self.localView.frame = self.view.bounds;
            self.videoCapture.previewLayer.frame = self.localView.bounds;
        } completion:^(BOOL finished) {
            self.remoteView.hidden = NO;
            self.dragEnable = NO;
            self.localView.userInteractionEnabled = YES;
            
            self.topView.hidden = NO;
            self.botView.hidden = NO;
            [self showSubview];
            [UIApplication.sharedApplication.keyWindow.rootViewController.view bringSubviewToFront:self.view];
        }];
    }else {
        
        self.smlView.hidden = YES;
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.view.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
            self.smlView.frame = CGRectMake(0, 0, 76, 76);
        } completion:^(BOOL finished) {
            self.dragEnable = NO;
            self.topView.hidden = NO;
            self.botView.hidden = NO;
            self.waitingView.hidden = NO;
            [UIApplication.sharedApplication.keyWindow.rootViewController.view bringSubviewToFront:self.view];
        }];
    }
}
- (void)enterSmallWindow {
    if (self.mainViewID != self.localView.userID) {
        self.remoteView.frame = self.localView.frame;
        self.localView.frame = self.view.bounds;
        self.videoCapture.previewLayer.frame = self.localView.bounds;
        
        [self.view bringSubviewToFront:self.remoteView];
        [self.view sendSubviewToBack:self.localView];
        
        self.mainViewID = self.localView.userID;
        self.localView.dragEnable = NO;
        self.remoteView.dragEnable = YES;
    }

    self.remoteView.hidden = YES;
    self.topView.hidden = YES;
    self.botView.hidden = YES;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideSubview) object:nil];
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.view.frame = CGRectMake(kScreenWidth-93, kStatusBarHeight+60, 93, 165);
        self.localView.frame = self.view.bounds;
        self.videoCapture.previewLayer.frame = self.localView.bounds;
        
    } completion:^(BOOL finished) {
        self.dragEnable = YES;
        self.localView.userInteractionEnabled = NO;
        [UIApplication.sharedApplication.keyWindow.rootViewController.view bringSubviewToFront:self.view];
    }];
}
- (void)enterAudioSmall {
    self.waitingView.hidden = YES;
    self.topView.hidden = YES;
    self.botView.hidden = YES;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideSubview) object:nil];
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.view.frame = CGRectMake(kScreenWidth-76, kStatusBarHeight+60, 76, 76);
        self.smlView.frame = CGRectMake(0, 0, 76, 76);
    } completion:^(BOOL finished) {
        self.dragEnable = YES;
        self.smlView.hidden = NO;
        [UIApplication.sharedApplication.keyWindow.rootViewController.view bringSubviewToFront:self.view];
    }];
}
- (void)hideSubview {
    self.isShowing = NO;
    [UIView animateWithDuration:0.2 animations:^{
        self.botView.y = kScreenHeight;
        self.topView.y = self.view.y-kTopViewH;
    } completion:^(BOOL finished) {
        
    }];
}

- (void)showSubview {
    self.isShowing = YES;
    [UIView animateWithDuration:0.2 animations:^{
        self.botView.y = kScreenHeight-self.bottomViewHeight;
        self.topView.y = 0;
    } completion:^(BOOL finished) {
        [self performSelector:@selector(hideSubview) afterDelay:5];
        
    }];
}


- (void)localViewToMain:(NSInteger)selUid {
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
//                    [self.remoteView setSize:self.localView.size];
        self.remoteView.frame = self.localView.frame;
        
        self.localView.frame = self.view.bounds;
        self.videoCapture.previewLayer.frame = self.localView.bounds;
        
        [self.view bringSubviewToFront:self.remoteView];
        [self.view sendSubviewToBack:self.localView];
    } completion:^(BOOL finished) {
        self.remoteView.dragEnable = YES;
        self.localView.dragEnable = NO;
        self.mainViewID = selUid;
    }];
}

- (void)remoteViewToMain:(NSInteger)selUid {
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.localView.frame = self.remoteView.frame;
        self.videoCapture.previewLayer.frame = self.localView.bounds;
        self.remoteView.frame = self.view.bounds;
        
        [self.view bringSubviewToFront:self.localView];
        [self.view sendSubviewToBack:self.remoteView];
    } completion:^(BOOL finished) {
        self.remoteView.dragEnable = NO;
        self.localView.dragEnable = YES;
        self.mainViewID = selUid;
    }];
}

- (void)closeCallPage {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideSubview) object:nil];
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.view.y = kScreenHeight;
    } completion:^(BOOL finished) {
        [self.view removeAllSubviews];
        [self.view removeFromSuperview];
        [self removeFromParentViewController];
        [DCCallManager sharedInstance].isCallBusy = NO;
        [DCCallManager sharedInstance].callUid = nil;
        [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    }];
}
@end
