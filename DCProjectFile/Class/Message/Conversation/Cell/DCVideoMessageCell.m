//
//  DCVideoMessageCell.m
//  DCProjectFile
//
//  Created  on 2023/6/29.
//

#import "DCVideoMessageCell.h"
#import "DCPieProgressView.h"

@interface DCVideoMessageCell ()
@property (nonatomic, strong) UIImageView *playIcon;
@property (nonatomic, strong) UIView *coverView;
@property (nonatomic, strong) DCPieProgressView *progressView;
@end

@implementation DCVideoMessageCell
#pragma mark - Life Cycle
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initialize];
    }
    return self;
}



+ (CGSize)sizeForMessageModel:(DCMessageContent *)model withCollectionViewWidth:(CGFloat)collectionViewWidth referenceExtraHeight:(CGFloat)extraHeight {
    CGSize imageSize = [self getThumbnailImageSize:model];
    CGFloat messagecontentview_height = imageSize.height;
    messagecontentview_height += extraHeight;
    return CGSizeMake(collectionViewWidth, messagecontentview_height + (model.isDisplayMsgTime?20:0) +((model.conversationType==DC_ConversationType_GROUP && model.messageDirection==DC_MessageDirection_RECEIVE)?20:0));
}

- (void)setDataModel:(DCMessageContent *)model {
    if (model.message_type == 2 && model.extra.type == 2) {
        [super setDataModel:model];
        self.nicknameLabel.hidden = (self.model.conversationType==DC_ConversationType_PRIVATE || self.model.messageDirection == DC_MessageDirection_SEND);
        
        CGSize imageSize = [[self class] getThumbnailImageSize:model];
        CGRect rect = self.messageContentView.frame;
        rect.size = imageSize;
        
        self.messageContentView.frame = CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
        self.pictureView.frame = CGRectMake(0, 0, rect.size.width, rect.size.height);
        self.coverView.frame = CGRectMake(0, 0, rect.size.width, rect.size.height);
        self.progressView.frame = CGRectMake(imageSize.width/2-18, imageSize.height/2-18, 36, 36);
        self.playIcon.frame = CGRectMake(imageSize.width/2-18, imageSize.height/2-18, 36, 36);
        
        self.progressView.hidden = YES;
        
        if (model.msgSentStatus == DC_SentStatus_SENDING) {
            self.playIcon.hidden = YES;
            self.coverView.hidden = NO;
        }else {
            self.playIcon.hidden = NO;
            self.coverView.hidden = YES;
        }
        NSString *ext = model.extra.path.pathExtension;
        
        NSString *imgName = [model.extra.path stringByReplacingOccurrencesOfString:ext withString:@"png"];
        UIImage *localImage = [DCFileManager getMessageImage:imgName];
        if (localImage) {
            self.pictureView.image = localImage;
        }else {
            [self.pictureView sd_setImageWithURL:[NSURL URLWithString:model.extra.cover] placeholderImage:kPlaceholderImage completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
                if (image) {
                    [DCFileManager saveMessageFile:[UIImage lubanCompressImage:image] fileName:[DCFileManager fileName:imgName]];
                }
            }];
        }
        [self setCellAutoLayout];
    }

}

- (void)setProgress:(CGFloat)progress {
    _progress = progress;
    self.progressView.progress = progress;
    if (progress >= 1) {
        self.coverView.hidden = YES;
        self.playIcon.hidden = NO;
    }
}

- (void)initialize {
    
    [self.messageContentView addSubview:self.pictureView];
    [self.messageContentView addSubview:self.coverView];
    [self.messageContentView addSubview:self.playIcon];
    [self.coverView addSubview:self.progressView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(progressChanged:) name:kVideoUploadProgressChangedNotificaiton object:nil];
}

- (void)progressChanged:(NSNotification*)aNotification {
    NSString *uuid = [aNotification.userInfo objectForKey:@"uuid"];
    if ([uuid isEqualToString:self.model.uuid]) {
        CGFloat p = [aNotification.object floatValue];
        DCLog(@"当前进度----%f",p);
//        dispatch_async(dispatch_get_main_queue(), ^{
//            self.progress = [aNotification.object floatValue];
//        });
    }
}


+ (CGSize)getThumbnailImageSize:(DCMessageContent *)model {
    //图片消息最小值为 100 X 100，最大值为 240 X 240
    // 重新梳理规则，如下：
    // 1、宽高任意一边小于 100 时，如：20 X 40 ，则取最小边，按比例放大到 100 进行显示，如最大边超过240 时，居中截取 240
    // 进行显示
    // 2、宽高都小于 240 时，大于 100 时，如：120 X 140 ，则取最长边，按比例放大到 240 进行显示
    // 3、宽高任意一边大于240时，分两种情况：
    //(1）如果宽高比没有超过 2.4，等比压缩，取长边 240 进行显示。
    //(2）如果宽高比超过 2.4，等比缩放（压缩或者放大），取短边 100，长边居中截取 240 进行显示。
    
    CGSize imageSize = CGSizeMake(model.extra.weight, model.extra.height);
    CGFloat imageMaxLength =  120;
    CGFloat imageMinLength =  50;
    if (imageSize.width == 0 || imageSize.height == 0) {
        return CGSizeMake(imageMaxLength, imageMinLength);
    }
    CGFloat imageWidth = 0;
    CGFloat imageHeight = 0;
    if (imageSize.width < imageMinLength || imageSize.height < imageMinLength) {
        return [self p_getSizeForBelowStandard:imageSize imageMinLength:imageMinLength imageMaxLength:imageMaxLength];
    } else if (imageSize.width < imageMaxLength && imageSize.height < imageMaxLength &&
               imageSize.width >= imageMinLength && imageSize.height >= imageMinLength) {
        if (imageSize.width > imageSize.height) {
            imageWidth = imageMaxLength;
            imageHeight = imageMaxLength * imageSize.height / imageSize.width;
        } else {
            imageHeight = imageMaxLength;
            imageWidth = imageMaxLength * imageSize.width / imageSize.height;
        }
    } else if (imageSize.width >= imageMaxLength || imageSize.height >= imageMaxLength) {
        return [self p_getSizeForAboveStandard:imageSize imageMinLength:imageMinLength imageMaxLength:imageMaxLength];
    }
    return CGSizeMake(imageWidth, imageHeight);
}

+ (CGSize)p_getSizeForBelowStandard:(CGSize)imageSize imageMinLength:(CGFloat)imageMinLength imageMaxLength:(CGFloat)imageMaxLength{
    CGFloat imageWidth = 0;
    CGFloat imageHeight = 0;
    if (imageSize.width < imageSize.height) {
        imageWidth = imageMinLength;
        imageHeight = imageMinLength * imageSize.height / imageSize.width;
        if (imageHeight > imageMaxLength) {
            imageHeight = imageMaxLength;
        }
    } else {
        imageHeight = imageMinLength;
        imageWidth = imageMinLength * imageSize.width / imageSize.height;
        if (imageWidth > imageMaxLength) {
            imageWidth = imageMaxLength;
        }
    }
    return CGSizeMake(imageWidth, imageHeight);
}

+ (CGSize)p_getSizeForAboveStandard:(CGSize)imageSize imageMinLength:(CGFloat)imageMinLength imageMaxLength:(CGFloat)imageMaxLength{
    CGFloat imageWidth = 0;
    CGFloat imageHeight = 0;
    if (imageSize.width > imageSize.height) {
        if (imageSize.width / imageSize.height < imageMaxLength / imageMinLength) {
            imageWidth = imageMaxLength;
            imageHeight = imageMaxLength * imageSize.height / imageSize.width;
        } else {
            imageHeight = imageMinLength;
            imageWidth = imageMinLength * imageSize.width / imageSize.height;
            if (imageWidth > imageMaxLength) {
                imageWidth = imageMaxLength;
            }
        }
    } else {
        if (imageSize.height / imageSize.width < imageMaxLength / imageMinLength) {
            imageHeight = imageMaxLength;
            imageWidth = imageMaxLength * imageSize.width / imageSize.height;
        } else {
            imageWidth = imageMinLength;
            imageHeight = imageMinLength * imageSize.height / imageSize.width;
            if (imageHeight > imageMaxLength) {
                imageHeight = imageMaxLength;
            }
        }
    }
    return CGSizeMake(imageWidth, imageHeight);
}


- (UIImageView *)pictureView{
    if (!_pictureView) {
        _pictureView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _pictureView.layer.masksToBounds = YES;
        _pictureView.layer.cornerRadius = 6;
    }
    return _pictureView;
}
- (UIImageView *)playIcon {
    if (!_playIcon) {
        _playIcon = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"play_btn_normal"]];
    }
    return _playIcon;
}

- (UIView *)coverView {
    if (!_coverView) {
        _coverView = [[UIView alloc]initWithFrame:CGRectZero];
        _coverView.layer.cornerRadius = 6;
        _coverView.layer.masksToBounds = YES;
        _coverView.backgroundColor = [kBlackColor colorWithAlphaComponent:0.5];
    }
    return _coverView;
}


- (DCPieProgressView *)progressView {
    if (!_progressView) {
        _progressView = [[DCPieProgressView alloc]initWithFrame:CGRectZero];
        _progressView.progressColor = [kWhiteColor colorWithAlphaComponent:0.75];
        _progressView.lineWidth = 0.5;
        _progressView.lineColor = kWhiteColor;
    }
    return _progressView;
}
@end
