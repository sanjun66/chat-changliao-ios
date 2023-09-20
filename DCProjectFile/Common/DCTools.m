//
//  DCTools.m
//  DCProjectFile
//
//  Created  on 2023/2/28.
//

#import "DCTools.h"

@implementation DCTools
+ (NSString *)getCurrentTimes {

    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    NSDate *datenow = [NSDate date];
    NSString *currentTimeString = [formatter stringFromDate:datenow];
    return currentTimeString;

}
+ (NSString *)jsonString:(NSDictionary *)dic{
    NSError *err;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:0 error:&err];
    
    NSString *jsonString;
    if (!jsonData) {
        NSLog(@"%@",err);
    }else{
        jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    return jsonString;
}
+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString
{
    if (jsonString == nil) {
        return nil;
    }

    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err)
    {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}
+ (NSString *)cTimestampFromString:(NSString *)theTime {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"YYYY-MM-dd"];
    NSDate* dateTodo = [formatter dateFromString:theTime];
    NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)[dateTodo timeIntervalSince1970]];
    return timeSp;
}

+ (NSString *)timeStringFromTimestamp:(NSInteger)timestamp {

    NSDate *confromTimesp = [NSDate dateWithTimeIntervalSince1970:timestamp];

    NSDateFormatter *dateFormat = [[NSDateFormatter alloc]init];

    [dateFormat setDateFormat:@"yyyy-MM-dd"];

    NSString *string=[dateFormat stringFromDate:confromTimesp];

    return string;

}
+ (NSString *)dateTimeDifferenceWithStartTime:(NSString *)startTime endTime:(NSString *)endTime{
    NSDateFormatter *date = [[NSDateFormatter alloc]init];
    [date setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *startD =[date dateFromString:startTime];
    NSDate *endD = [date dateFromString:endTime];
    NSTimeInterval start = [startD timeIntervalSince1970]*1;
    NSTimeInterval end = [endD timeIntervalSince1970]*1;
    NSTimeInterval value = end - start;
    int second = (int)value %60;//秒
    int minute = (int)value /60%60;
    int house = (int)value % (24 * 3600)/3600;
    int day = (int)value / (24 * 3600);
    NSString *str;
    if (day != 0) {
        str = [NSString stringWithFormat:@"共%d天%d小时%d分",day,house,minute];
    }else if (day==0 && house != 0) {
        str = [NSString stringWithFormat:@"共%d小时%d分",house,minute];
    }else if (day== 0 && house== 0 && minute!=0) {
        str = [NSString stringWithFormat:@"共%d分",minute];
    }else{
        str = [NSString stringWithFormat:@"共%d秒",second];
    }
    return str;

}

//时间戳变为格式时间
+ (NSString *)convertStrToTime:(long long)timeStr{
    
    NSDate *confromTimesp = [NSDate dateWithTimeIntervalSince1970:timeStr/1000];

    NSDateFormatter *dateFormat = [[NSDateFormatter alloc]init];

    [dateFormat setDateFormat:@"MM-dd HH:mm"];

    NSString *string=[dateFormat stringFromDate:confromTimesp];

    return string;

}
+ (NSString *)timeAgo:(int)timestamp withPublishDynamic:(BOOL)isPublishDynamic{
    int seconds = timestamp/1000;
    
    int year = seconds/(60*60*24*365);
    if (year > 0) {
        return @"一年前";
    }
    
    int month = seconds/(60*60*24*30);
    if (month > 0) {
        return [NSString stringWithFormat:@"%d月前",month];
    }
    
    int day = seconds/(60*60*24);
    if (day > 0) {
        return [NSString stringWithFormat:@"%d天前",day];
    }
    
    int hour = seconds/(60*60);
    if (hour > 0) {
        return [NSString stringWithFormat:@"%d小时前",hour];
    }
    
    int mitues = seconds/60;
    if (mitues>0) {
        return [NSString stringWithFormat:@"%d分钟前",mitues];
    }
    
    return isPublishDynamic ? @"刚刚发布" : @"刚刚在线";
}


+ (BOOL) isEmpty:(NSString *) str {
    
    if (!str) {
        
        return true;
        
    } else {
        
        NSCharacterSet *set = [NSCharacterSet whitespaceAndNewlineCharacterSet];
        
        NSString *trimedString = [str stringByTrimmingCharactersInSet:set];
        
        if ([trimedString length] == 0) {
            
            return true;
            
        } else {
            
            return false;
            
        }
        
    }
    
}

// 获取当前时间戳
+ (NSString *)getCurrentTimestamp {
    NSDate *date = [NSDate dateWithTimeIntervalSinceNow:0]; // 获取当前时间0秒后的时间
    NSTimeInterval time = [date timeIntervalSince1970]*1000;// *1000 是精确到毫秒(13位),不乘就是精确到秒(10位)
    NSString *timeString = [NSString stringWithFormat:@"%.0f", time];
    return timeString;
}

//判断输入的手机号是否是有效的
+ (BOOL)isValidateMobile:(NSString *)phoneNumber
{
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"^[1][3,4,5,6,7,8,9]\\d{9}$" options:NSRegularExpressionCaseInsensitive error:&error];

    NSTextCheckingResult *result = [regex firstMatchInString:phoneNumber options:0 range:NSMakeRange(0, [phoneNumber length])];
    if (result) {
        return YES;
    }
    return NO;
}
+ (BOOL)isValidateEmail:(NSString*)email {

    NSString *emailRegex =@"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";

    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];

    return [emailTest evaluateWithObject:email];
}
//  判断是否有特殊字符
+ (BOOL)isHaveSpechars:(NSString *)password {

    NSString *validPhoneNum = @"^[A-Za-z0-9\u4E00-\u9FA5_-]+$";
    NSPredicate *posswordTest  = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",validPhoneNum];
    return [posswordTest evaluateWithObject:password];
}
//  判断是否是纯数字
+ (BOOL)isPureNumandCharacters:(NSString *)string
{
    string = [string stringByTrimmingCharactersInSet:[NSCharacterSet decimalDigitCharacterSet]];
    if(string.length > 0)
    {
        return NO;
    }
    return YES;
}
//  判断是否是纯字母
+ (BOOL)isAllLetter:(NSString *)string
{
    NSString *validPhoneNum = @"^[A-Za-z]+$";
    NSPredicate *posswordTest  = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",validPhoneNum];
    return [posswordTest evaluateWithObject:string];
}
//  判断名称中是否有特殊字符
+ (BOOL)isHaveOtherStr:(NSString *)userNameStr {
    
    NSString *regex = @"[a-zA-Z0-9\u4e00-\u9fa5][a-zA-Z0-9\u4e00-\u9fa5]*";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return [pred evaluateWithObject:userNameStr];
}
// 获取当前活动的navigationcontroller
+ (UINavigationController *)navigationViewController
{
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    if ([window.rootViewController isKindOfClass:[UINavigationController class]])
    {
        return (UINavigationController *)window.rootViewController;
    }
    else if ([window.rootViewController isKindOfClass:[UITabBarController class]])
    {
        UIViewController *selectVc = [((UITabBarController *)window.rootViewController) selectedViewController];
        if ([selectVc isKindOfClass:[UINavigationController class]])
        {
            return (UINavigationController *)selectVc;
        }
    }
    return nil;
}

//递归
+ (UINavigationController *)getCurrentNCFrom:(UIViewController *)vc
{
    if ([vc isKindOfClass:[UITabBarController class]]) {
        UINavigationController *nc = ((UITabBarController *)vc).selectedViewController;
        return [self getCurrentNCFrom:nc];
    }
    else if ([vc isKindOfClass:[UINavigationController class]]) {
        if (((UINavigationController *)vc).presentedViewController) {
            return [self getCurrentNCFrom:((UINavigationController *)vc).presentedViewController];
        }
        return [self getCurrentNCFrom:((UINavigationController *)vc).topViewController];
    }
    else if ([vc isKindOfClass:[UIViewController class]]) {
        if (vc.presentedViewController) {
            return [self getCurrentNCFrom:vc.presentedViewController];
        }
        else {
            return vc.navigationController;
        }
    }
    else {
        NSAssert(0, @"未获取到导航控制器");
        return nil;
    }
}

// 获取当前viewcontroller
+ (UIViewController *)topViewController {
    if ([NSThread isMainThread]) {
        return [self visibleViewControllerIfExist:UIApplication.sharedApplication.delegate.window.rootViewController];
    } else {
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        __block UIViewController *controller = nil;
        dispatch_async(dispatch_get_main_queue(), ^{
            controller = [self visibleViewControllerIfExist:UIApplication.sharedApplication.delegate.window.rootViewController];
            dispatch_semaphore_signal(semaphore);
        });
        dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, 200 * NSEC_PER_MSEC));
        return controller;
    }
}

+ (UIViewController *)visibleViewControllerIfExist:(UIViewController *)controller {
    
    if (controller.presentedViewController) {
        return [self visibleViewControllerIfExist:controller.presentedViewController];
    }
    if ([controller isKindOfClass:[UINavigationController class]]) {
        return [self visibleViewControllerIfExist:((UINavigationController *)controller).visibleViewController];
    }
    if ([controller isKindOfClass:[UITabBarController class]]) {
        return [self visibleViewControllerIfExist:((UITabBarController *)controller).selectedViewController];
    }
    if (controller.isViewLoaded && controller.view.window) {
        controller.view.backgroundColor = [UIColor clearColor];
        return controller;
    } else {
        return nil;
    }
}

#pragma mark - 设置上图下文字
+(UIButton*)setUpImgDownText:(UIButton *)btn {
    /*
     多处使用，不要随意更改，
     */
    //计算字体的大小，如果titleLabel的宽度小于字体的宽度，则是没显示全，给label宽度赋值
    CGSize textSize = [btn.titleLabel.text sizeWithAttributes:@{NSFontAttributeName:btn.titleLabel.font}];
    CGSize frameSize = CGSizeMake(ceilf(textSize.width), ceilf(textSize.height));
    
    CGFloat titleWidth = btn.titleLabel.frame.size.width;
    if (titleWidth < frameSize.width) {
        titleWidth = frameSize.width;
    }
    
    CGFloat totalH = btn.imageView.frame.size.height + btn.titleLabel.frame.size.height;
    CGFloat spaceH = 7;
    //设置按钮图片偏移
    UIEdgeInsets imageEdgeInsets = UIEdgeInsetsMake(-(totalH - btn.imageView.frame.size.height),0.0, 0.0, -titleWidth);
    [btn setImageEdgeInsets:imageEdgeInsets];
    
    //设置按钮标题偏移
    UIEdgeInsets titleEdgeInsets = UIEdgeInsetsMake(spaceH, -btn.imageView.frame.size.width, -(totalH - btn.titleLabel.frame.size.height),0.0);
    [btn setTitleEdgeInsets:titleEdgeInsets];
    
    return btn;
}

//自定义间距上图下文字
+(UIButton*)setUpImgDownText:(UIButton *)btn space:(CGFloat)space {
    
    CGFloat totalH = btn.imageView.frame.size.height + btn.titleLabel.frame.size.height;
    CGFloat spaceH = space;
    //设置按钮图片偏移
    [btn setImageEdgeInsets:UIEdgeInsetsMake(-(totalH - btn.imageView.frame.size.height),0.0, 0.0, -btn.titleLabel.frame.size.width)];
    //设置按钮标题偏移
    [btn setTitleEdgeInsets:UIEdgeInsetsMake(spaceH, -btn.imageView.frame.size.width, -(totalH - btn.titleLabel.frame.size.height),0.0)];
    
    return btn;
}

#pragma mark - 检查为空
+(BOOL)isNull:(NSString *)str {
    if ([str isEqual:@"<null>"]||[str isEqual:@"(null)"]||[str isKindOfClass:[NSNull class]]||str.length==0) {
        return YES;
    }
    return NO;
}

+ (void)setLineSpace:(CGFloat)lineSpace withText:(NSString *)text inLabel:(UILabel *)label {
    if (!text || !label) {
        return;
    }
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = lineSpace;  //设置行间距
    paragraphStyle.lineBreakMode = label.lineBreakMode;
    paragraphStyle.alignment = label.textAlignment;
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:text];
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [text length])];
    label.attributedText = attributedString;
}
// 获取视频第一帧
+ (UIImage*) getVideoPreViewImage:(NSURL *)path {
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:path options:nil];
    AVAssetImageGenerator *assetGen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    
    assetGen.appliesPreferredTrackTransform = YES;
    CMTime time = CMTimeMakeWithSeconds(0.0, 600);
    NSError *error = nil;
    CMTime actualTime;
    CGImageRef image = [assetGen copyCGImageAtTime:time actualTime:&actualTime error:&error];
    UIImage *videoImage = [[UIImage alloc] initWithCGImage:image];
    CGImageRelease(image);
    return videoImage;
}



+ (HXPhotoManager *)photoManager:(NSUInteger)photoNum isVideo:(BOOL)isVideo{
    HXPhotoManager *_manager = [[HXPhotoManager alloc]initWithType:isVideo ? HXPhotoManagerSelectedTypeVideo : HXPhotoManagerSelectedTypePhoto];
    _manager.configuration.livePhotoAutoPlay = NO;
    _manager.configuration.cameraPhotoJumpEdit = NO;
    _manager.configuration.photoStyle = HXPhotoStyleInvariant;
    _manager.configuration.customCameraType = isVideo ? HXPhotoCustomCameraTypeVideo : HXPhotoCustomCameraTypePhoto;
    _manager.configuration.creationDateSort = YES;// 照片列表是否按照片创建日期排序
    _manager.configuration.specialModeNeedHideVideoSelectBtn = YES;// 只针对 照片、视频不能同时选并且视频只能选择1个的时候隐藏掉视频cell右上角的选择按钮
    _manager.configuration.supportRotation = NO;//是否支持旋转  默认YES
    _manager.configuration.maxNum = photoNum;
    _manager.configuration.photoMaxNum = photoNum;
    _manager.configuration.reverseDate = YES;// 照片列表倒序
    _manager.configuration.navigationTitleColor = kTextTitColor;
    _manager.configuration.navigationTitleArrowColor = kTextTitColor;
    _manager.configuration.previewSelectedBtnBgColor = kTextTitColor;
    _manager.configuration.themeColor = kMainColor;
    _manager.configuration.hideOriginalBtn = YES;// 是否隐藏原图按钮 默认 NO
    _manager.configuration.openCamera = ![DCCallManager sharedInstance].isCallBusy;
    _manager.configuration.requestImageAfterFinishingSelection = YES;
    _manager.configuration.videoMaximumSelectDuration = 60*60;
    
    if (@available(iOS 13.0, *)) {
        _manager.configuration.statusBarStyle = UIStatusBarStyleDarkContent;
    }
    _manager.configuration.navigationBar = ^(UINavigationBar *navigationBar, UIViewController *viewController) {
        [navigationBar setBackgroundImage:[UIImage createImageWithColor:kWhiteColor] forBarMetrics:UIBarMetricsDefault];
        [navigationBar setShadowImage:[UIImage new]];
        [navigationBar setTranslucent:NO];

        UIImage *image = [[UIImage imageNamed:@"back_black"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        navigationBar.backIndicatorImage = image;
        navigationBar.backIndicatorTransitionMaskImage = image;

        UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
        viewController.navigationItem.backBarButtonItem = item;
        viewController.navigationItem.rightBarButtonItem.tintColor = kTextTitColor;
    };
    return _manager;
}


+ (void)animationForView:(UIView *)view {
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    animation.duration = 0.5;
    animation.removedOnCompletion = YES;
    animation.fillMode = kCAFillModeForwards;
    NSMutableArray *values = [NSMutableArray array];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.1, 1.1, 1.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1.0)]];
    animation.values = values;
    [view.layer addAnimation:animation forKey:nil];
}

+ (NSString *)callDurationFromSeconds:(CGFloat)duration {
    
    int hour = floor(duration/3600.f);
    
    int minute = floor((duration - hour*3600.f)/60.f);
    
    int seconds = duration - hour*3600 - minute * 60;
    
    NSString *str1 = @"00";
    if (hour >= 10) {
        str1 = [NSString stringWithFormat:@"%d",hour];
    }else {
        str1 = [NSString stringWithFormat:@"0%d",hour];
    }
    
    NSString *str2 = @"00";
    if (minute >= 10) {
        str2 = [NSString stringWithFormat:@"%d",minute];
    }else {
        str2 = [NSString stringWithFormat:@"0%d",minute];
    }
    
    NSString *str3 = @"00";
    if (seconds >= 10) {
        str3 = [NSString stringWithFormat:@"%d",seconds];
    }else {
        str3 = [NSString stringWithFormat:@"0%d",seconds];
    }
    
    
    return hour>0?[NSString stringWithFormat:@"%@:%@:%@",str1,str2,str3]:[NSString stringWithFormat:@"%@:%@",str2,str3];
}


// 校验身份证号码是否正确 返回BOOL值
+ (BOOL)verifyIDCardString:(NSString *)idCardString {
    NSString *regex = @"^[1-9]\\d{5}(18|19|([23]\\d))\\d{2}((0[1-9])|(10|11|12))(([0-2][1-9])|10|20|30|31)\\d{3}[0-9Xx]$";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    BOOL isRe = [predicate evaluateWithObject:idCardString];
    if (!isRe) {
         //身份证号码格式不对
        return NO;
    }
    //加权因子 7, 9, 10, 5, 8, 4, 2, 1, 6, 3, 7, 9, 10, 5, 8, 4, 2
    NSArray *weightingArray = @[@"7", @"9", @"10", @"5", @"8", @"4", @"2", @"1", @"6", @"3", @"7", @"9", @"10", @"5", @"8", @"4", @"2"];
    //校验码 1, 0, 10, 9, 8, 7, 6, 5, 4, 3, 2
    NSArray *verificationArray = @[@"1", @"0", @"10", @"9", @"8", @"7", @"6", @"5", @"4", @"3", @"2"];
    
    NSInteger sum = 0;//保存前17位各自乖以加权因子后的总和
    for (int i = 0; i < weightingArray.count; i++) {//将前17位数字和加权因子相乘的结果相加
        NSString *subStr = [idCardString substringWithRange:NSMakeRange(i, 1)];
        sum += [subStr integerValue] * [weightingArray[i] integerValue];
    }
    
    NSInteger modNum = sum % 11;//总和除以11取余
    NSString *idCardMod = verificationArray[modNum]; //根据余数取出校验码
    NSString *idCardLast = [idCardString.uppercaseString substringFromIndex:17]; //获取身份证最后一位
    
    if (modNum == 2) {//等于2时 idCardMod为10  身份证最后一位用X表示10
        idCardMod = @"X";
    }
    if ([idCardLast isEqualToString:idCardMod]) { //身份证号码验证成功
        return YES;
    } else { //身份证号码验证失败
        return NO;
    }
}


// 校验姓名是否正确 返回BOOL值
+ (BOOL)verifyRealNameString:(NSString *)realNameString{
    NSString *realNamePattern = @"^[\u4e00-\u9fa5]{0,}";//字数不限,只允许是汉字
    NSPredicate *realNamePredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",realNamePattern];
    if(![realNamePredicate evaluateWithObject:realNameString]){
        return NO;
    }
    return YES;
}

//字符串计算，宽度和字号大小，返回其所占高度
+ (CGFloat)heightForTextString:(NSString *)textString width:(CGFloat)width font:(UIFont *)font{
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    [style setLineBreakMode:NSLineBreakByWordWrapping];
    [style setLineSpacing:6];//调整行间距
    CGSize detailSize = [textString boundingRectWithSize:CGSizeMake(width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:font,NSParagraphStyleAttributeName:style} context:nil].size;
    return detailSize.height;
}


/** 电话号码正则 */
+ (NSRegularExpression *)regexPhoneNumber
{
    static NSRegularExpression *regex;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        regex = [NSRegularExpression regularExpressionWithPattern:@"(\\d{3,4}[- ]\\d{7,8})|(\\d{7,500})" options:kNilOptions error:NULL];
    });
    return regex;
}

/** 链接正则 */
+ (NSRegularExpression *)regexLinkUrl
{
    static NSRegularExpression *regex;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        regex = [NSRegularExpression regularExpressionWithPattern:@"((http[s]{0,1}|ftp)://[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)|(www.[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)" options:kNilOptions error:NULL];
    });
    return regex;
}


//字符串计算，高度和字号大小，返回其所占宽度
+ (CGSize)returnSizeWithText:(NSString*)text
                        font:(UIFont *)font
                      height:(CGFloat)height
{
    if (!text || text.length == 0) {
        /// 可能是空
        text = @"";
    }
    
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:font,NSFontAttributeName, nil];
    NSStringDrawingOptions options = NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading;
    CGSize size = [text boundingRectWithSize:CGSizeMake(MAXFLOAT, height) options:options attributes:dic context:nil].size;
    return size;
}



+ (UIImage *)getLaunchImage{

   CGSize viewSize = [UIScreen mainScreen].bounds.size;
   NSString *launchImage = nil;

   NSArray* imagesDict = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"UILaunchImages"];
   for (NSDictionary* dict in imagesDict)
   {
       CGSize imageSize = CGSizeFromString(dict[@"UILaunchImageSize"]);

       // 横屏改成 @"Landscape"
       if (CGSizeEqualToSize(imageSize, viewSize) && [@"Portrait" isEqualToString:dict[@"UILaunchImageOrientation"]])
       {
           launchImage = dict[@"UILaunchImageName"];
       }
   }
   return [UIImage imageNamed:launchImage];
}

+ (UIViewController *)actionSheet:(NSArray*)titles complete:(void(^)(int idx))block {
    if (titles.count <=0 ) return nil;
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    for (int i=0; i<titles.count; i++) {
        UIAlertAction *action = [UIAlertAction actionWithTitle:titles[i] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            block(i);
        }];
        [action setValue:kMainColor forKey:@"_titleTextColor"];
        [alert addAction:action];
    }
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [cancel setValue:kTextSubColor forKey:@"_titleTextColor"];
    [alert addAction:cancel];
    
    return alert;
}

+ (NSString *)uniquelyIdentifies {
    CFUUIDRef uuid = CFUUIDCreate(nil);
    NSString *uuidString = (__bridge_transfer NSString*)CFUUIDCreateString(nil, uuid);
    CFRelease(uuid);
    NSString *uuidStr = [[uuidString stringByReplacingOccurrencesOfString:@"-" withString:@""] lowercaseString];
    NSString *name = [NSString stringWithFormat:@"%@",uuidStr];
    
    NSString *fileName = @"";
    NSDate *nowDate = [NSDate date];
    NSString *dateStr = [NSString stringWithFormat:@"%ld", (long)[nowDate timeIntervalSince1970]];
    NSString *numStr = [NSString stringWithFormat:@"%d",arc4random()%10000];
    fileName = [fileName stringByAppendingString:@"sc"];
    fileName = [fileName stringByAppendingString:dateStr];
    fileName = [fileName stringByAppendingString:numStr];
    
    return [NSString stringWithFormat:@"iOS_%@%@",name,fileName];
}

+ (NSString *)uploadFileNamePre {
    NSString *time = [DCTools getCurrentTimes];
    NSString *time1 = [time componentsSeparatedByString:@" "].firstObject;
    NSString *time2 = [time1 stringByReplacingOccurrencesOfString:@"-" withString:@"/"];
    
    CFUUIDRef uuid = CFUUIDCreate(nil);
    NSString *uuidString = (__bridge_transfer NSString*)CFUUIDCreateString(nil, uuid);
    CFRelease(uuid);
    NSString *uuidStr = [[uuidString stringByReplacingOccurrencesOfString:@"-" withString:@""] lowercaseString];
    NSString *name = [NSString stringWithFormat:@"%@",uuidStr];
    
    NSDate *nowDate = [NSDate date];
    NSString *dateStr = [NSString stringWithFormat:@"%ld", (long)[nowDate timeIntervalSince1970]];
    
    return [NSString stringWithFormat:@"%@/%@_%@",time2, dateStr,[NSString md5String:name]];
}

//MARK: - 加解密
+ (NSString *)AESEncrypt:(NSString *)inString {
    return [MIUAES MIUAESEncrypt:inString mode:kCCModeCBC key:kAesKey keySize:MIUKeySizeAES128 iv:kAesIv padding:MIUCryptorPKCS7Padding];
}
+ (NSString *)AESDecrypt:(NSString *)inString {
    return [MIUAES MIUAESDecrypt:inString mode:kCCModeCBC key:kAesKey keySize:MIUKeySizeAES128 iv:kAesIv padding:MIUCryptorPKCS7Padding];;
}

// 是否为群的id
+ (BOOL)isGroupId:(NSString *)targetId {
    return [targetId hasPrefix:@"group"];
}
@end
