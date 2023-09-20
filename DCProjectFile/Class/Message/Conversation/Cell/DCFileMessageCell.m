//
//  DCFileMessageCell.m
//  DCProjectFile
//
//  Created  on 2023/7/4.
//

#import "DCFileMessageCell.h"
#define FILE_CONTENT_HEIGHT 69.f

@interface DCFileMessageCell ()
/*!
 显示文件名的Label
 */
@property (strong, nonatomic) UILabel *nameLabel;

/*!
 显示文件大小的Label
 */
@property (strong, nonatomic) UILabel *sizeLabel;

/*!
 文件类型的ImageView
 */
@property (strong, nonatomic) UIImageView *typeIconView;

@end

@implementation DCFileMessageCell
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
    return CGSizeMake(collectionViewWidth, FILE_CONTENT_HEIGHT+extraHeight + (model.isDisplayMsgTime?20:0) +((model.conversationType==DC_ConversationType_GROUP && model.messageDirection==DC_MessageDirection_RECEIVE)?20:0));
}

- (void)setDataModel:(DCMessageContent *)model {
    [super setDataModel:model];
    
    self.nicknameLabel.hidden = (self.model.conversationType==DC_ConversationType_PRIVATE || self.model.messageDirection == DC_MessageDirection_SEND);
    
    CGFloat maxWidth = kScreenWidth *0.637+7;
    CGRect rect = self.messageContentView.frame;
    
    rect.size = CGSizeMake(maxWidth, FILE_CONTENT_HEIGHT);
    
    self.messageContentView.frame = rect;
    
    self.bubbleBackgroundView.frame = self.messageContentView.bounds;
    
    self.nameLabel.frame = CGRectMake(15, 0, maxWidth - 90, 40);
    
    self.sizeLabel.frame = CGRectMake(15, 40, maxWidth - 90, 30);
    
    self.typeIconView.frame = CGRectMake(maxWidth-68, 11, 48, 48);
    
    if (self.model.messageDirection == DC_MessageDirection_RECEIVE) {
        self.bubbleBackgroundView.image = [UIImage imageNamed:@"msg_bubble_receive"];
        self.nameLabel.textColor = HEX(@"#1C2340");
        self.sizeLabel.textColor = [HEX(@"#1C2340") colorWithAlphaComponent:0.8];
    }else {
        self.bubbleBackgroundView.image = [UIImage imageNamed:@"msg_bubble_sent"];
        self.nameLabel.textColor = kWhiteColor;
        self.sizeLabel.textColor = [kWhiteColor colorWithAlphaComponent:0.8];
    }
    UIImage *image = self.bubbleBackgroundView.image;
    self.bubbleBackgroundView.image = [self.bubbleBackgroundView.image
        resizableImageWithCapInsets:UIEdgeInsetsMake(image.size.height -5, image.size.width * 0.5,
                                                     5, image.size.width * 0.5)];
    
    
    
    self.nameLabel.text = model.extra.path.lastPathComponent;
    
    self.sizeLabel.text = [self getReadableStringForFileSize:model.extra.size];
    
    NSString *type = [model.extra.path componentsSeparatedByString:@"."].lastObject;
    
    self.typeIconView.image = [UIImage imageNamed:[self getFileTypeIcon:type]];
    
    
    [self setCellAutoLayout];
}

- (void)initialize {
    [self showBubbleBackgroundView:YES];
    [self.messageContentView addSubview:self.nameLabel];
    [self.messageContentView addSubview:self.sizeLabel];
    [self.messageContentView addSubview:self.typeIconView];
}

#pragma mark - Getter
- (UILabel *)nameLabel{
    if(!_nameLabel){
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [_nameLabel setFont:[UIFont systemFontOfSize:15]];
        _nameLabel.numberOfLines = 2;
        _nameLabel.textColor = HEXCOLOR(0x11f2c);
        _nameLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
        
    }
    return _nameLabel;
}

- (UILabel *)sizeLabel{
    if (!_sizeLabel) {
        _sizeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [_sizeLabel setFont:[UIFont systemFontOfSize:13]];
        _sizeLabel.textColor = HEXCOLOR(0xc7cbce);
    }
    return _sizeLabel;
}

- (UIImageView *)typeIconView{
    if (!_typeIconView) {
        _typeIconView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 48, 48)];
        _typeIconView.clipsToBounds = YES;
    }
    return _typeIconView;
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
