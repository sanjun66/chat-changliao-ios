//
//  DCTextMessageCell.m
//  DCProjectFile
//
//  Created  on 2023/6/7.
//

#import "DCTextMessageCell.h"


#define kContentMaxWidth (kScreenWidth*0.6)

@implementation DCTextMessageCell
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
- (void)initialize {
    [self showBubbleBackgroundView:YES];
    [self.messageContentView addSubview:self.textLabel];
}

+ (CGSize)sizeForMessageModel:(DCMessageContent *)model withCollectionViewWidth:(CGFloat)collectionViewWidth referenceExtraHeight:(CGFloat)extraHeight {
    CGSize size = [model.message textSizeIn:CGSizeMake(collectionViewWidth*0.6, CGFLOAT_MAX) font:[UIFont systemFontOfSize:kTextFontSize]];
    CGFloat __height = size.height + 22;
    
    if (model.isDisplayMsgTime) {
        __height += 20;
    }
    
    if (model.conversationType==DC_ConversationType_GROUP && model.messageDirection==DC_MessageDirection_RECEIVE) {
        __height += 20;
    }
    
    return CGSizeMake(collectionViewWidth, __height+extraHeight);
    
}

- (void)setDataModel:(DCMessageContent *)model {
    [super setDataModel:model];
    [self setAutoLayout];
}

- (void)setAutoLayout{
    CGSize size = [self textSize];
    self.nicknameLabel.hidden = (self.model.conversationType==DC_ConversationType_PRIVATE || self.model.messageDirection == DC_MessageDirection_SEND);
    
    CGRect rect = self.messageContentView.frame;
    rect.size.width = (size.width + 25 < 36)?36:size.width + 25;
    rect.size.height = size.height + 22;
    self.messageContentView.frame = rect;
    
    self.bubbleBackgroundView.frame = self.messageContentView.bounds;
    
    self.textLabel.text = self.model.message;
    
    if (self.model.messageDirection == DC_MessageDirection_RECEIVE) {
        self.bubbleBackgroundView.image = [UIImage imageNamed:@"msg_bubble_receive"];
        self.textLabel.textColor = HEX(@"#1C2340");
        self.textLabel.frame = CGRectMake(15, 11, size.width, size.height);
    }else {
        self.bubbleBackgroundView.image = [UIImage imageNamed:@"msg_bubble_sent"];
        self.textLabel.textColor = kWhiteColor;
        self.textLabel.frame = CGRectMake(10, 11, size.width, size.height);
    }
    
    UIImage *image = self.bubbleBackgroundView.image;
    self.bubbleBackgroundView.image = [self.bubbleBackgroundView.image
        resizableImageWithCapInsets:UIEdgeInsetsMake(image.size.height-5, image.size.width * 0.5,
                                                     5, image.size.width * 0.5)];
    
    [self setCellAutoLayout];
}

- (CGSize)textSize{
    CGSize size = [self.model.message textSizeIn:CGSizeMake(kContentMaxWidth, CGFLOAT_MAX) font:[UIFont systemFontOfSize:kTextFontSize]];
    
    return CGSizeMake(ceilf(size.width), ceilf(size.height));
}
- (UILabel *)textLabel {
    if (!_textLabel) {
        _textLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        _textLabel.font = [UIFont systemFontOfSize:kTextFontSize];
        _textLabel.textColor = kTextTitColor;
        _textLabel.numberOfLines = 0;
        _textLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _textLabel.textAlignment = NSTextAlignmentLeft;
        _textLabel.userInteractionEnabled = YES;
    }
    
    return _textLabel;
}
@end
