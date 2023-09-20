//
//  DCGroupQRCodeVC.m
//  DCProjectFile
//
//  Created  on 2023/9/1.
//

#import "DCGroupQRCodeVC.h"

@interface DCGroupQRCodeVC ()
@property (nonatomic, strong) UIImageView *backView;

@end

@implementation DCGroupQRCodeVC

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"群二维码名片";
    [self UIConfig];
    [self rightBarButtonItemWithString:@"保存"];
    
}

- (void)rightBarButtonAction {
    UIImage *localImage = [UIImage getImageFromView:self.backView];
    UIImageWriteToSavedPhotosAlbum(localImage, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
    
}
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    NSString *msg = nil ;
    if(error){
        msg = @"保存失败" ;
    }else{
        msg = @"保存成功" ;
    }
    [MBProgressHUD showTips:msg];
}
- (void)UIConfig {
    UIImageView *imageView = [[UIImageView alloc]init];
    imageView.layer.cornerRadius = 12;
    imageView.clipsToBounds = YES;
    imageView.userInteractionEnabled = YES;
    imageView.backgroundColor = kWhiteColor;
    [self.view addSubview:imageView];
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.offset (WIDTH_SCALE(43)+kNavHeight);
        make.centerX.offset (0);
        make.size.mas_equalTo (CGSizeMake(WIDTH_SCALE(292), WIDTH_SCALE(372)));
    }];
    self.backView = imageView;
    
    UIImageView *userIcon = [[UIImageView alloc]init];
    userIcon.layer.cornerRadius = 10;
    userIcon.clipsToBounds = YES;
    userIcon.contentMode = UIViewContentModeScaleAspectFill;
    [imageView addSubview:userIcon];
    [userIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.offset (WIDTH_SCALE(20));
        make.left.offset (WIDTH_SCALE(20));
        make.size.mas_equalTo (CGSizeMake(WIDTH_SCALE(60), WIDTH_SCALE(60)));
    }];
    [userIcon sd_setImageWithURL:[NSURL URLWithString:self.groupData.group_info.avatar]];
    
    UILabel *nickName = [[UILabel alloc]init];
    nickName.font = kFontSize(18);
    nickName.textColor = HEX(@"#4B4A53");
    nickName.text = self.groupData.group_info.name;
    nickName.lineBreakMode = NSLineBreakByTruncatingMiddle;
    [imageView addSubview:nickName];
    [nickName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(userIcon);
        make.left.equalTo (userIcon.mas_right).offset (12);
        make.right.offset (-10);
    }];
    
    NSDictionary *parms = @{@"appName":kAppName,@"groupId":self.groupData.group_info.groupId, @"groupName":self.groupData.group_info.name ,@"uid":kUser.uid, @"type":@(2)};
    NSString *json = [DCTools jsonString:parms];
    
    UIImageView *codeImage = [[UIImageView alloc]init];
    codeImage.image = [self generateQRCodeWithString:json Size:WIDTH_SCALE(92)];
    [imageView addSubview:codeImage];
    [codeImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo (userIcon.mas_bottom).offset (WIDTH_SCALE(20));
        make.centerX.equalTo (imageView);
        make.size.mas_equalTo (CGSizeMake(WIDTH_SCALE(220), WIDTH_SCALE(220)));
    }];

    UILabel *tipLabel = [[UILabel alloc]init];
    tipLabel.font = kFontSize(12);
    tipLabel.textColor = HEX(@"#7F807F");
    tipLabel.text = @"扫一扫上面的二维码图案，加入群聊";
    tipLabel.textAlignment = NSTextAlignmentCenter;
    [imageView addSubview:tipLabel];
    [tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.offset (0);
        make.bottom.offset (-WIDTH_SCALE(16));
        make.width.mas_equalTo (WIDTH_SCALE(250));
        make.height.mas_equalTo (WIDTH_SCALE(17));
    }];
}
#pragma mark -- 生成二维码
// 生成二维码
- (UIImage *)generateQRCodeWithString:(NSString *)string Size:(CGFloat)size
{
    //创建过滤器
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    //过滤器恢复默认
    [filter setDefaults];
    //给过滤器添加数据<字符串长度893>
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    [filter setValue:data forKey:@"inputMessage"];
    //获取二维码过滤器生成二维码
    CIImage *image = [filter outputImage];
    UIImage *img = [self createNonInterpolatedUIImageFromCIImage:image WithSize:size];
    return img;
}

//二维码清晰
- (UIImage *)createNonInterpolatedUIImageFromCIImage:(CIImage *)image WithSize:(CGFloat)size
{
    CGRect extent = CGRectIntegral(image.extent);
    CGFloat scale = MIN(size/CGRectGetWidth(extent), size/CGRectGetHeight(extent));
    
    //创建bitmap
    size_t width = CGRectGetWidth(extent)*scale;
    size_t height = CGRectGetHeight(extent)*scale;
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceGray();
    CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, cs, (CGBitmapInfo)kCGImageAlphaNone);
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef bitmapImage = [context createCGImage:image fromRect:extent];
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
    CGContextScaleCTM(bitmapRef, scale, scale);
    CGContextDrawImage(bitmapRef, extent, bitmapImage);
    
    //保存图片
    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
    CGContextRelease(bitmapRef);
    CGImageRelease(bitmapImage);
    return [UIImage imageWithCGImage:scaledImage];
}

@end
