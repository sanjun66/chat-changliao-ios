
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (Additions)

+ (instancetype)xib;

- (id) initWithParent:(UIView *)parent;
+ (id) viewWithParent:(UIView *)parent;
-(void)removeAllSubViews;
- (void)setBackgroundImage:(UIImage*)image;
- (UIImage*)toImage;

/**  设置圆角  */
- (void)rounded:(CGFloat)cornerRadius;

/**  设置圆角和边框  */
- (void)rounded:(CGFloat)cornerRadius width:(CGFloat)borderWidth color:(UIColor *)borderColor;

/**  设置边框  */
- (void)border:(CGFloat)borderWidth color:(UIColor *)borderColor;

/**   给哪几个角设置圆角  */
-(void)round:(CGFloat)cornerRadius RectCorners:(UIRectCorner)rectCorner;

/**  设置阴影  */
-(void)shadow:(UIColor *)shadowColor opacity:(CGFloat)opacity radius:(CGFloat)radius offset:(CGSize)offset;


// Position of the top-left corner in superview's coordinates
@property CGPoint position;
@property CGFloat x;
@property CGFloat y;
@property CGFloat top;
@property CGFloat bottom;
@property CGFloat left;
@property CGFloat right;
@property (nonatomic) CGFloat centerX;
@property (nonatomic) CGFloat centerY;

// makes hiding more logical
@property BOOL    visible;


// Setting size keeps the position (top-left corner) constant
@property CGSize size;
@property CGFloat width;
@property CGFloat height;

/**
 设置镂空遮罩视图，该方法本质上是设置maskView
 如果寄宿图的内容有更新，需要手动再调用setter方法

 @param view 遮罩视图
 */
- (void)setSubtractMaskView:(UIView *)view;

/**
 获取镂空遮罩视图，用于动态修改遮罩的一些属性

 @return 遮罩视图
 */
- (UIView *)subtractMaskView;

@property(nonatomic,assign) IBInspectable CGFloat cornerRadius;
@property(nonatomic,assign) IBInspectable CGFloat borderWidth;
@property(nonatomic,assign) IBInspectable UIColor *borderColor;

@end

@interface UIImageView (MFAdditions)

- (void) setImageWithName:(NSString *)name;

@end


NS_ASSUME_NONNULL_END
