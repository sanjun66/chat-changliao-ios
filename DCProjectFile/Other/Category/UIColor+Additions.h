//
//  UIColor+Additions.h
//  DCProjectFile
//
//  Created  on 2023/2/28.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIColor (Additions)
+ (UIColor *)colorWithHexString: (NSString *)color;
+ (UIColor *)colorWithHexString: (NSString *)color alpha:(CGFloat)alpha;
+ (UIColor *)colorWithHex:(UInt32)hex;

+ (CAGradientLayer *)setGradualChangingColor:(UIView *)view fromColor:(UIColor *)fromHexColor toColor:(UIColor *)toHexColor;
@end

NS_ASSUME_NONNULL_END
