

#import "YYAnimatedImageView+XYExtension.h"

@implementation YYAnimatedImageView (XYExtension)

+(void)load
{
    // hook：钩子函数
    Method method1 = class_getInstanceMethod(self, @selector(displayLayer:));
    
    Method method2 = class_getInstanceMethod(self, @selector(dx_displayLayer:));
    method_exchangeImplementations(method1, method2);
}

-(void)dx_displayLayer:(CALayer *)layer {
    
    if ([UIImageView instancesRespondToSelector:@selector(displayLayer:)]) {
        [super displayLayer:layer];
    }
    
}

@end
