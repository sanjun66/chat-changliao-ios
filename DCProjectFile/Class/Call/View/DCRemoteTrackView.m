//
//  DCRemoteTrackView.m
//  DCProjectFile
//
//  Created  on 2023/7/25.
//

#import "DCRemoteTrackView.h"
@interface DCRemoteTrackView ()<UIGestureRecognizerDelegate>
@property (nonatomic,strong) UIPanGestureRecognizer *panGestureRecognizer;
@property (nonatomic, assign) CGPoint startPoint;
@property (nonatomic, assign) CGRect freeRect;
@property (nonatomic, assign) BOOL isKeepBounds;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;
@end
@implementation DCRemoteTrackView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.videoGravity = AVLayerVideoGravityResizeAspectFill;
        [self setUp];
        [self addSubview:self.avatar];
        [self.avatar addSubview:self.lodingView];
        [self.lodingView addSubview:self.activityIndicatorView];
        [self.activityIndicatorView startAnimating];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.avatar.frame = self.bounds;
    self.lodingView.frame = self.avatar.bounds;
    self.activityIndicatorView.frame = self.lodingView.bounds;
}
- (UIImageView *)avatar {
    if (!_avatar) {
        _avatar = [[UIImageView alloc]init];
        _avatar.contentMode = UIViewContentModeScaleAspectFill;
        _avatar.layer.masksToBounds = YES;
        _avatar.userInteractionEnabled = NO;
        _avatar.hidden = YES;
    }
    return _avatar;
}
- (UIView *)lodingView {
    if (!_lodingView) {
        _lodingView = [[UIView alloc]init];
        _lodingView.backgroundColor = [UIColor.blackColor colorWithAlphaComponent:0.5];
    }
    return _lodingView;
}
- (UIActivityIndicatorView *)activityIndicatorView {
    if (!_activityIndicatorView) {
        _activityIndicatorView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    }
    return _activityIndicatorView;
}
- (void) setUp {
    self.freeRect = CGRectMake(10, kStatusBarHeight, kScreenWidth-20, kScreenHeight-kStatusBarHeight-kBottomSafe);
    self.isKeepBounds = YES;
    self.dragEnable = YES;
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickDragView)];
    [self addGestureRecognizer:singleTap];
    
    //添加移动手势可以拖动
    self.panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragAction:)];
    self.panGestureRecognizer.minimumNumberOfTouches = 1;
    self.panGestureRecognizer.maximumNumberOfTouches = 1;
    self.panGestureRecognizer.delegate = self;
    [self addGestureRecognizer:self.panGestureRecognizer];
}

-(void)dragAction:(UIPanGestureRecognizer *)pan{
    if(self.dragEnable==NO)return;
    switch (pan.state) {
        case UIGestureRecognizerStateBegan:{//开始拖动
            //注意完成移动后，将translation重置为0十分重要。否则translation每次都会叠加
            [pan setTranslation:CGPointZero inView:self];
            //保存触摸起始点位置
            self.startPoint = [pan translationInView:self];
            break;
        }
        case UIGestureRecognizerStateChanged:{//拖动中
            //计算位移 = 当前位置 - 起始位置
            CGPoint point = [pan translationInView:self];
            float dx;
            float dy;
            dx = point.x - self.startPoint.x;
            dy = point.y - self.startPoint.y;
            
            //计算移动后的view中心点
            CGPoint newCenter = CGPointMake(self.center.x + dx, self.center.y + dy);
            //移动view
            self.center = newCenter;
            //  注意完成上述移动后，将translation重置为0十分重要。否则translation每次都会叠加
            [pan setTranslation:CGPointZero inView:self];
            break;
        }
        case UIGestureRecognizerStateEnded:{//拖动结束
            [self keepBounds];
            break;
        }
        default:
            break;
    }
}
//点击事件
-(void)clickDragView{
    if (self.clickRemoteVideoViewBlock) {
        self.clickRemoteVideoViewBlock(self);
    }
}
//黏贴边界效果
- (void)keepBounds{
    //中心点判断
    float centerX = self.freeRect.origin.x+(self.freeRect.size.width - self.frame.size.width)/2;
    CGRect rect = self.frame;
    if (self.isKeepBounds==NO) {//没有黏贴边界的效果
        if (self.frame.origin.x < self.freeRect.origin.x) {
            CGContextRef context = UIGraphicsGetCurrentContext();
            [UIView beginAnimations:@"leftMove" context:context];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
            [UIView setAnimationDuration:0.5];
            rect.origin.x = self.freeRect.origin.x;
            self.frame = rect;
            [UIView commitAnimations];
        } else if(self.freeRect.origin.x+self.freeRect.size.width < self.frame.origin.x+self.frame.size.width){
            CGContextRef context = UIGraphicsGetCurrentContext();
            [UIView beginAnimations:@"rightMove" context:context];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
            [UIView setAnimationDuration:0.5];
            rect.origin.x = self.freeRect.origin.x+self.freeRect.size.width-self.frame.size.width;
            self.frame = rect;
            [UIView commitAnimations];
        }
    }else if(self.isKeepBounds==YES){//自动粘边
        if (self.frame.origin.x< centerX) {
            CGContextRef context = UIGraphicsGetCurrentContext();
            [UIView beginAnimations:@"leftMove" context:context];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
            [UIView setAnimationDuration:0.5];
            rect.origin.x = self.freeRect.origin.x;
            self.frame = rect;
            [UIView commitAnimations];
        } else {
            CGContextRef context = UIGraphicsGetCurrentContext();
            [UIView beginAnimations:@"rightMove" context:context];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
            [UIView setAnimationDuration:0.5];
            rect.origin.x =self.freeRect.origin.x+self.freeRect.size.width - self.frame.size.width;
            self.frame = rect;
            [UIView commitAnimations];
        }
    }
    
    if (self.frame.origin.y < self.freeRect.origin.y) {
        CGContextRef context = UIGraphicsGetCurrentContext();
        [UIView beginAnimations:@"topMove" context:context];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [UIView setAnimationDuration:0.5];
        rect.origin.y = self.freeRect.origin.y;
        self.frame = rect;
        [UIView commitAnimations];
    } else if(self.freeRect.origin.y+self.freeRect.size.height< self.frame.origin.y+self.frame.size.height){
        CGContextRef context = UIGraphicsGetCurrentContext();
        [UIView beginAnimations:@"bottomMove" context:context];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [UIView setAnimationDuration:0.5];
        rect.origin.y = self.freeRect.origin.y+self.freeRect.size.height-self.frame.size.height;
        self.frame = rect;
        [UIView commitAnimations];
    }
}

@end
