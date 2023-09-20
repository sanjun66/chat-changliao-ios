//
//  DCForwardMsgBaseCell.m
//  DCProjectFile
//
//  Created  on 2023/9/7.
//

#import "DCForwardMsgBaseCell.h"
#define kMsgContentWidth (kScreenWidth-82)

@implementation DCForwardMsgBaseCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [self.msgContentView addSubview:self.pictureView];
    
    UILongPressGestureRecognizer *longPress =
    [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressedMessageContentView:)];
    [self.msgContentView addGestureRecognizer:longPress];

    UITapGestureRecognizer *tap =
        [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapMessageContentView)];
    tap.numberOfTapsRequired = 1;
    tap.numberOfTouchesRequired = 1;
    [self.msgContentView addGestureRecognizer:tap];
    
}

- (void)didTapMessageContentView{
    if ([self.delegate respondsToSelector:@selector(didTapMessageCell:)]) {
        [self.delegate didTapMessageCell:self.model];
    }
}

- (void)longPressedMessageContentView:(id)sender {
    
    UILongPressGestureRecognizer *press = (UILongPressGestureRecognizer *)sender;
    if (press.state == UIGestureRecognizerStateEnded) {
        return;
    } else if (press.state == UIGestureRecognizerStateBegan) {
        [self.delegate didLongTouchMessageCell:self.model inView:self.msgContentView];
    }
}



- (void)setModel:(DCMessageContent *)model {
    _model = model;
    
    [[DCUserManager sharedManager] getConversationData:DC_ConversationType_PRIVATE targerId:model.from_uid completion:^(DCUserInfo * _Nonnull userInfo) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.userAvatar sd_setImageWithURL:[NSURL URLWithString:userInfo.portraitUri] placeholderImage:[UIImage imageNamed:@"default_portrait_msg"]];
            self.nicknameLabel.text = userInfo.name;
        });
    }];
    
    self.timeLabel.text = [DCTools convertStrToTime:(model.timestamp)];
    
    if (model.message_type==2 && (model.extra.type==2 || model.extra.type==3)) {
        self.msgTextLabel.hidden = YES;
        self.pictureView.hidden = YES;
        self.extraView.hidden = NO;
        
        if (model.extra.type==2) {
            NSString *ext = model.extra.path.pathExtension;
            self.extraTitle.text = @"视频";
            self.extraDesc.text = [DCTools callDurationFromSeconds:model.extra.duration];
            
            NSString *imgName = [model.extra.path stringByReplacingOccurrencesOfString:ext withString:@"png"];
            UIImage *localImage = [DCFileManager getMessageImage:imgName];
            if (localImage) {
                self.extraIcon.image = localImage;
            }else {
                [self.extraIcon sd_setImageWithURL:[NSURL URLWithString:model.extra.cover] placeholderImage:kPlaceholderImage completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
                    if (image) {
                        [DCFileManager saveMessageFile:[UIImage lubanCompressImage:image] fileName:[DCFileManager fileName:imgName]];
                    }
                }];
            }
        }else {
            self.extraTitle.text = model.extra.path.lastPathComponent;
            
            self.extraDesc.text = [self getReadableStringForFileSize:model.extra.size];
            
            NSString *type = [model.extra.path componentsSeparatedByString:@"."].lastObject;
            
            self.extraIcon.image = [UIImage imageNamed:[self getFileTypeIcon:type]];
        }
    }else if (model.message_type==1) {
        self.pictureView.hidden = YES;
        self.extraView.hidden = YES;
        self.msgTextLabel.hidden = NO;
        self.msgTextLabel.text = model.message;
        
    }else if (model.message_type==2 && model.extra.type==1) {
        self.pictureView.hidden = NO;
        self.extraView.hidden = YES;
        self.msgTextLabel.hidden = YES;
        
        UIImage *localImage = [DCFileManager getMessageImage:model.extra.path];
        if (localImage) {
            self.pictureView.image = localImage;
        }else {
            [self.pictureView sd_setImageWithURL:[NSURL URLWithString:model.extra.url] placeholderImage:kPlaceholderImage completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
                if (image) {
                    [DCFileManager saveMessageFile:UIImageJPEGRepresentation(image, 1) fileName:[DCFileManager fileName:model.extra.path]];
                }
                
            }];
        }
        
        
        if (model.extra.weight > kMsgContentWidth) {
            self.pictureView.frame = CGRectMake(0, 0, kMsgContentWidth, model.extra.height * kMsgContentWidth / model.extra.weight);
        }else {
            self.pictureView.frame = CGRectMake(0, 0, model.extra.weight, model.extra.height);
        }
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (UIImageView *)pictureView{
    if (!_pictureView) {
        _pictureView = [[UIImageView alloc] initWithFrame:CGRectZero];
    }
    return _pictureView;
}


- (NSString *)getFileTypeIcon:(NSString *)fileType {
    //把后缀名强制改为小写
    fileType = [fileType lowercaseString];
    if ([fileType isEqualToString:@"png"] || [fileType isEqualToString:@"jpg"] || [fileType isEqualToString:@"bmp"] ||
        [fileType isEqualToString:@"cod"] || [fileType isEqualToString:@"gif"] || [fileType isEqualToString:@"jpe"] ||
        [fileType isEqualToString:@"jpeg"] || [fileType isEqualToString:@"jfif"] || [fileType isEqualToString:@"svg"] ||
        [fileType isEqualToString:@"tif"] || [fileType isEqualToString:@"tiff"] || [fileType isEqualToString:@"ras"] ||
        [fileType isEqualToString:@"ico"] ||
        [fileType isEqualToString:@"pgm"] || [fileType isEqualToString:@"pnm"] || [fileType isEqualToString:@"ppm"] ||
        [fileType isEqualToString:@"xbm"] || [fileType isEqualToString:@"xpm"] || [fileType isEqualToString:@"xwd"] ||
        [fileType isEqualToString:@"rgb"]) {
        return @"PictureFile";
    } else if ([fileType isEqualToString:@"log"] || [fileType isEqualToString:@"txt"] ||
               [fileType isEqualToString:@"html"] || [fileType isEqualToString:@"stm"] ||
               [fileType isEqualToString:@"uls"] || [fileType isEqualToString:@"bas"] ||
               [fileType isEqualToString:@"c"] || [fileType isEqualToString:@"h"] ||
               [fileType isEqualToString:@"rtf"] || [fileType isEqualToString:@"sct"] ||
               [fileType isEqualToString:@"tsv"] || [fileType isEqualToString:@"htt"] ||
               [fileType isEqualToString:@"htc"] || [fileType isEqualToString:@"etx"] ||
               [fileType isEqualToString:@"vcf"]) {
        return @"TextFile";
    } else if ([fileType isEqualToString:@"mp3"] || [fileType isEqualToString:@"au"] ||
               [fileType isEqualToString:@"snd"] || [fileType isEqualToString:@"mid"] ||
               [fileType isEqualToString:@"rmi"] || [fileType isEqualToString:@"aif"] ||
               [fileType isEqualToString:@"aifc"] || [fileType isEqualToString:@"m3u"] ||
               [fileType isEqualToString:@"ra"] || [fileType isEqualToString:@"ram"] ||
               [fileType isEqualToString:@"wav"] || [fileType isEqualToString:@"wma"]) {
        return @"Mp3File";
    } else if ([fileType isEqualToString:@"pdf"]) {
        return @"PdfFile";
    } else if ([fileType isEqualToString:@"doc"] || [fileType isEqualToString:@"docx"] ||
               [fileType isEqualToString:@"dot"] || [fileType isEqualToString:@"dotx"]) {
        return @"WordFile";
    } else if ([fileType isEqualToString:@"xls"] || [fileType isEqualToString:@"xlsx"] ||
               [fileType isEqualToString:@"xlc"] || [fileType isEqualToString:@"xlm"] ||
               [fileType isEqualToString:@"xla"] || [fileType isEqualToString:@"xlt"] ||
               [fileType isEqualToString:@"xlw"]) {
        return @"ExcelFile";
    } else if ([fileType isEqualToString:@"mp4"] || [fileType isEqualToString:@"mov"] ||
               [fileType isEqualToString:@"rmvb"] || [fileType isEqualToString:@"avi"] ||
               [fileType isEqualToString:@"mp2"] || [fileType isEqualToString:@"xpa"] ||
               [fileType isEqualToString:@"xpe"] || [fileType isEqualToString:@"mpeg"] ||
               [fileType isEqualToString:@"mpg"] || [fileType isEqualToString:@"mpv2"] ||
               [fileType isEqualToString:@"qt"] || [fileType isEqualToString:@"lsf"] ||
               [fileType isEqualToString:@"lsx"] || [fileType isEqualToString:@"asf"] ||
               [fileType isEqualToString:@"asr"] || [fileType isEqualToString:@"asx"] ||
               [fileType isEqualToString:@"wmv"] || [fileType isEqualToString:@"movie"]) {
        return @"VideoFile";
    } else if ([fileType isEqualToString:@"ppt"] || [fileType isEqualToString:@"pptx"]) {
        return @"pptFile";
    } else if ([fileType isEqualToString:@"pages"]) {
        return @"Pages";
    } else if ([fileType isEqualToString:@"numbers"]) {
        return @"Numbers";
    } else if ([fileType isEqualToString:@"key"]) {
        return @"Keynote";
    } else {
        return @"OtherFile";
    }
}

- (NSString *)getReadableStringForFileSize:(long long)byteSize {
    if (byteSize < 0) {
        return @"0 B";
    } else if (byteSize < 1024) {
        return [NSString stringWithFormat:@"%lld B", byteSize];
    } else if (byteSize < 1024 * 1024) {
        double kSize = (double)byteSize / 1024;
        return [NSString stringWithFormat:@"%.2f KB", kSize];
    } else if (byteSize < 1024 * 1024 * 1024) {
        double kSize = (double)byteSize / (1024 * 1024);
        return [NSString stringWithFormat:@"%.2f MB", kSize];
    } else {
        double kSize = (double)byteSize / (1024 * 1024 * 1024);
        return [NSString stringWithFormat:@"%.2f GB", kSize];
    }
}


@end
