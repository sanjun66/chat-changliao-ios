//
//  DCInCallBottomView.m
//  DCProjectFile
//
//  Created  on 2023/7/25.
//

#import "DCInCallBottomView.h"
@interface DCInCallBottomView()

@property (weak, nonatomic) IBOutlet UIButton *speakerButton;
@property (weak, nonatomic) IBOutlet UILabel *speakerLabel;

@property (weak, nonatomic) IBOutlet UIButton *micButton;
@property (weak, nonatomic) IBOutlet UILabel *micLabel;
@property (weak, nonatomic) IBOutlet UIButton *cameraButton;
@property (weak, nonatomic) IBOutlet UILabel *cameraLabel;

@property (weak, nonatomic) IBOutlet UIView *speakerView;
@property (weak, nonatomic) IBOutlet UIView *micView;
@property (weak, nonatomic) IBOutlet UIView *cameraView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topMargin;

@end

@implementation DCInCallBottomView

- (void)setConferenceType:(QBRTCConferenceType)conferenceType {
    _conferenceType = conferenceType;
    BOOL isVideo = conferenceType==QBRTCConferenceTypeVideo;
    if (!isVideo) {
        self.speakerButton.selected = YES;
        self.speakerLabel.text = @"扬声器已关";
        self.topMargin.constant = 10;
        self.cameraView.hidden = YES;
    }else {
        [self.speakerButton setImage:[UIImage imageNamed:@"call_switch"] forState:UIControlStateNormal];
        [self.speakerButton setImage:[UIImage imageNamed:@"call_switch"] forState:UIControlStateSelected];
        self.speakerLabel.text = @"切换摄像头";
    }
}

- (IBAction)hangupClick:(id)sender {
    if ([self.delegate respondsToSelector:@selector(botViewClose)]) {
        [self.delegate botViewClose];
    }
}
- (IBAction)switchCameraClick:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(botViewSwitchCamera:)]) {
        sender.selected = !sender.selected;
        [self.delegate botViewSwitchCamera:sender.isSelected];
    }
    
}
- (IBAction)labaClick:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (self.conferenceType == QBRTCConferenceTypeAudio) {
        self.speakerLabel.text = sender.isSelected?@"扬声器已关":@"扬声器已开";
        [self.delegate botViewChangeOutputChannel:sender.isSelected];
    }else {
        [self.delegate botViewSwitchCamera:sender.isSelected];
    }
}
- (IBAction)micClick:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(botViewChangeMicEnable:)]) {
        sender.selected = !sender.selected;
        self.micLabel.text = sender.isSelected?@"麦克风已关":@"麦克风已开";
        [self.delegate botViewChangeMicEnable:sender.isSelected];
    }
    
}
- (IBAction)cameraClick:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(botViewChangeCameraEnable:)]) {
        sender.selected = !sender.selected;
        self.cameraLabel.text = sender.isSelected?@"摄像头已关":@"摄像头已开";
        [self.delegate botViewChangeCameraEnable:sender.isSelected];
    }
}


@end
