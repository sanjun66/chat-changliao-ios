//
//  DCRechargeVC.m
//  DCProjectFile
//
//  Created  on 2023/9/15.
//

#import "DCRechargeVC.h"

@interface DCRechargeVC ()
@property (weak, nonatomic) IBOutlet UILabel *noticeLabel;

@property (weak, nonatomic) IBOutlet UIView *backView;
@property (weak, nonatomic) IBOutlet UIImageView *qrImgView;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;

@end

@implementation DCRechargeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.title = @"充值";
    [self requestRechargeDatas];
}

- (void)requestRechargeDatas {
    [[DCRequestManager sharedManager] requestWithMethod:@"POST" url:@"api/userAddress" parameters:nil success:^(id  _Nullable result) {
        if ([result isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dict = (NSDictionary *)result;
            NSString *address = dict[@"address"];
            NSString *currency = dict[@"currency"];
            self.qrImgView.image = [self generateQRCodeWithString:address Size:200];
            self.addressLabel.text = address;
            self.noticeLabel.text = currency;
        }
    } failure:^(NSError * _Nonnull error) {
        
    }];
}

- (IBAction)saveClick:(id)sender {
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

- (IBAction)copyClick:(id)sender {
    if ([DCTools isEmpty:self.addressLabel.text]) {
        [MBProgressHUD showTips:@"未获取到地址，请退出重试"];
        return;
    }
    
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = self.addressLabel.text;
    [MBProgressHUD showTips:@"复制成功"];
    
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
