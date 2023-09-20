//
//  DCTools.h
//  DCProjectFile
//
//  Created  on 2023/2/28.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DCTools : NSObject
/// 获取当前时间
+ (NSString *)getCurrentTimes;

/// 获取当前时间戳
+ (NSString *)getCurrentTimestamp;

/// 字典转json
+ (NSString *)jsonString:(NSDictionary *)dic;

/// json 转字典
+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString;

/// 字符串转时间戳
+ (NSString *)cTimestampFromString:(NSString *)theTime;

/// 时间戳转字符串
+ (NSString *)timeStringFromTimestamp:(NSInteger)timestamp;

/// 获取两个时间戳的时间差
+ (NSString *)dateTimeDifferenceWithStartTime:(NSString *)startTime endTime:(NSString *)endTime;

/// 时间戳变为格式时间
+ (NSString *)convertStrToTime:(long long)timeStr;

/// 获取多久以前
+ (NSString *)timeAgo:(int)timestamp withPublishDynamic:(BOOL)isPublishDynamic;

/// 判断输入的手机号是否是有效的
+ (BOOL)isValidateMobile:(NSString *)phoneNumber;

+ (BOOL)isValidateEmail:(NSString*)email;

/// 判断是否有特殊字符
+ (BOOL)isHaveSpechars:(NSString *)password;


/// 判断是否是纯数字
+ (BOOL)isPureNumandCharacters:(NSString *)string;

/// 判断是否是纯字母
+ (BOOL)isAllLetter:(NSString *)string;

/// 判断名称中是否有特殊字符
+ (BOOL)isHaveOtherStr:(NSString *)userNameStr;

/// 判断空字符串
+ (BOOL) isEmpty:(NSString *) str;


/// 获取导航
+ (UINavigationController *)navigationViewController;

/// 获取viewcontroller
+ (UIViewController *)topViewController;

/** 设置上图下文字 */
+(UIButton*)setUpImgDownText:(UIButton *)btn;

/// 自定义间距上图下文字
+(UIButton*)setUpImgDownText:(UIButton *)btn space:(CGFloat)space;

/// 设置label行间距
+ (void)setLineSpace:(CGFloat)lineSpace withText:(NSString *)text inLabel:(UILabel *)label;

// 获取视频第一帧图片
+ (UIImage*) getVideoPreViewImage:(NSURL *)path;




+ (HXPhotoManager *)photoManager:(NSUInteger)photoNum isVideo:(BOOL)isVideo;



//添加简单的弹窗缓冲效果
+ (void)animationForView:(UIView *)view;

/// 秒转00:00:00类型
+ (NSString *)callDurationFromSeconds:(CGFloat)duration;

// 校验身份证号码是否正确 返回BOOL值
+ (BOOL)verifyIDCardString:(NSString *)idCardString;

// 校验姓名是否正确 返回BOOL值
+ (BOOL)verifyRealNameString:(NSString *)realNameString;

//字符串计算，宽度和字号大小，返回其所占高度
+ (CGFloat)heightForTextString:(NSString *)textString width:(CGFloat)width font:(UIFont *)font;

/** 电话号码正则, 7到23 位数字 */
+ (NSRegularExpression *)regexPhoneNumber;

/** 链接正则 */
+ (NSRegularExpression *)regexLinkUrl;


//字符串计算，高度和字号大小，返回其所占宽度
+ (CGSize)returnSizeWithText:(NSString*)text
                        font:(UIFont *)font
                      height:(CGFloat)height;


+ (UIImage *)getLaunchImage;


+ (UIViewController *)actionSheet:(NSArray*)titles complete:(void(^)(int idx))block;

+ (NSString *)uniquelyIdentifies;

+ (NSString *)uploadFileNamePre;

+ (NSString *)AESEncrypt:(NSString *)inString;
+ (NSString *)AESDecrypt:(NSString *)inString;

// 是否为群的id
+ (BOOL)isGroupId:(NSString *)targetId;
@end

NS_ASSUME_NONNULL_END
