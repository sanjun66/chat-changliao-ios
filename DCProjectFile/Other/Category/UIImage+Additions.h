//
//  UIImage+Additions.h
//  DCProjectFile
//
//  Created  on 2023/2/28.
//

#import <UIKit/UIKit.h>
#import <Accelerate/Accelerate.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (Additions)
/**
 *  加载不被渲染的图片
 */
+ (UIImage *)imageWithOriginalRenderingMode:(NSString *)imageName;

/**
 *  返回拉伸图片
 */
+ (UIImage *)resizedImage:(NSString *)name;
/**
 *  用颜色返回一张图片
 */
+ (UIImage *)createImageWithColor:(UIColor*) color;

/**
 *  带边框的图片
 *
 *  @param name        图片名字
 *  @param borderWidth 边框宽度
 *  @param borderColor 边框颜色
 */
+ (instancetype)circleImageWithName:(NSString *)name borderWidth:(CGFloat)borderWidth borderColor:(UIColor *)borderColor;

/**
 *  带边框的图片
 *
 *  @param image        图片
 *  @param borderWidth 边框宽度
 *  @param borderColor 边框颜色
 */
+ (instancetype)circleImageWithImage:(UIImage *)image borderWidth:(CGFloat)borderWidth borderColor:(UIColor *)borderColor;


/**
 *  获取屏幕截图
 *
 *  @return 屏幕截图图像
 */
+ (UIImage *)screenShot;


/**
 *  等比例缩放图片
 *
 *  @return 屏幕截图图像
 */
+ (UIImage *) mzImageWithImageSimple:(UIImage*)image scaledToSize:(CGSize) newSizel;
+ (UIImage *) drawImage:(UIImage *)image bySize:(CGSize)aSize;
+ (UIImage *) imageCompressForSize:(UIImage *)sourceImage targetSize:(CGSize)size;
// 按大小缩放
+ (UIImage *) thumbnailWithImageWithoutScale:(UIImage *)image size:(CGSize)asize ;

// 按宽度等比例缩放
+ (UIImage *) imageCompressForWidth:(UIImage *)sourceImage targetWidth:(CGFloat)defineWidth;



// 缩放到指定大小
+ (UIImage*)imageCompressWithSimple:(UIImage*)image scaledToSize:(CGSize)size;


// 模糊
+ (UIImage *)mohuImage:(UIImage *)image ;


+ (UIImage*)clipImageWithImage:(UIImage*)image inRect:(CGRect)rect ;

// 高斯模糊效果
+(UIImage *)coreBlurImage:(UIImage *)image withBlurNumber:(CGFloat)blur;


// 截取指定区域的图片
+ (UIImage*)imageFromView:(UIView *)view rect:(CGRect)rect;

+ (UIImage *)getImageFromView:(UIView *)orgView;

// 高斯模糊
+ (UIImage*)imageBlurImage:(UIImage *)image withBlurNumber:(CGFloat)blur;

// 图片合成
+ (UIImage *)cerateImageFromImage:(UIImage *)image
                    withMaskImage:(UIImage *)mask;

+ (NSData *)lubanCompressImage:(UIImage *)image;
+ (NSData *)lubanCompressImage:(UIImage *)image withMask:(NSString *)maskName;
+ (NSData *)lubanCompressImage:(UIImage *)image withCustomImage:(NSString *)imageName;
@end

NS_ASSUME_NONNULL_END
