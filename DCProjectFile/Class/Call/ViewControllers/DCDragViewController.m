//
//  DCDragViewController.m
//  DCProjectFile
//
//  Created  on 2023/7/24.
//

#import "DCDragViewController.h"
#import "DCRemoteTrackView.h"
#import "DCLocalTrackView.h"

@interface DCDragViewController ()<UIGestureRecognizerDelegate>
@property (nonatomic, assign) CGPoint startPoint;
@property (nonatomic, assign) CGRect freeRect;
@property (nonatomic, assign) BOOL isKeepBounds;

@end

@implementation DCDragViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.freeRect = CGRectMake(0, kStatusBarHeight, kScreenWidth, kScreenHeight-kStatusBarHeight-kBottomSafe);
    self.isKeepBounds = YES;
    self.dragEnable = NO;
    
    [self addGes];
    
    
}

- (void)reportCallState:(NSInteger)state {
    [[DCRequestManager sharedManager] requestWithMethod:@"POST" url:@"api/talkState" parameters:@{@"id":[DCCallManager sharedInstance].callUid , @"state":@(state)} success:^(id  _Nullable result) {
            
    } failure:^(NSError * _Nonnull error) {
        
    }];
}

- (void)dragAction:(UIPanGestureRecognizer *)pan {
    if (!self.dragEnable) return;
    
    switch (pan.state) {
        case UIGestureRecognizerStateBegan:
            [pan setTranslation:CGPointZero inView:self.view];
            self.startPoint = [pan translationInView:self.view];
            break;
            
            
        case UIGestureRecognizerStateChanged:
        {
            CGPoint point = [pan translationInView:self.view];
            CGFloat dx = point.x - self.startPoint.x;
            CGFloat dy = point.y - self.startPoint.y;
            CGPoint newCenter = CGPointMake(self.view.centerX + dx, self.view.centerY + dy);
            self.view.center = newCenter;
            [pan setTranslation:CGPointZero inView:self.view];
        }
            break;
            
        case UIGestureRecognizerStateEnded:
            [self keepBounds];
            break;
        default:
            break;
    }
}

- (void)keepBounds {
    //中心点判断
    float centerX = self.freeRect.origin.x+(self.freeRect.size.width - self.view.frame.size.width)/2;
    CGRect rect = self.view.frame;
    if (self.isKeepBounds==NO) {//没有黏贴边界的效果
        if (self.view.frame.origin.x < self.freeRect.origin.x) {
            CGContextRef context = UIGraphicsGetCurrentContext();
            [UIView beginAnimations:@"leftMove" context:context];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
            [UIView setAnimationDuration:0.5];
            rect.origin.x = self.freeRect.origin.x;
            self.view.frame = rect;
            [UIView commitAnimations];
        } else if(self.freeRect.origin.x+self.freeRect.size.width < self.view.frame.origin.x+self.view.frame.size.width){
            CGContextRef context = UIGraphicsGetCurrentContext();
            [UIView beginAnimations:@"rightMove" context:context];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
            [UIView setAnimationDuration:0.5];
            rect.origin.x = self.freeRect.origin.x+self.freeRect.size.width-self.view.frame.size.width;
            self.view.frame = rect;
            [UIView commitAnimations];
        }
    }else if(self.isKeepBounds==YES){//自动粘边
        if (self.view.frame.origin.x< centerX) {
            CGContextRef context = UIGraphicsGetCurrentContext();
            [UIView beginAnimations:@"leftMove" context:context];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
            [UIView setAnimationDuration:0.5];
            rect.origin.x = self.freeRect.origin.x;
            self.view.frame = rect;
            [UIView commitAnimations];
        } else {
            CGContextRef context = UIGraphicsGetCurrentContext();
            [UIView beginAnimations:@"rightMove" context:context];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
            [UIView setAnimationDuration:0.5];
            rect.origin.x =self.freeRect.origin.x+self.freeRect.size.width - self.view.frame.size.width;
            self.view.frame = rect;
            [UIView commitAnimations];
        }
    }
    
    if (self.view.frame.origin.y < self.freeRect.origin.y) {
        CGContextRef context = UIGraphicsGetCurrentContext();
        [UIView beginAnimations:@"topMove" context:context];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [UIView setAnimationDuration:0.5];
        rect.origin.y = self.freeRect.origin.y;
        self.view.frame = rect;
        [UIView commitAnimations];
    } else if(self.freeRect.origin.y+self.freeRect.size.height< self.view.frame.origin.y+self.view.frame.size.height){
        CGContextRef context = UIGraphicsGetCurrentContext();
        [UIView beginAnimations:@"bottomMove" context:context];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [UIView setAnimationDuration:0.5];
        rect.origin.y = self.freeRect.origin.y+self.freeRect.size.height-self.view.frame.size.height;
        self.view.frame = rect;
        [UIView commitAnimations];
    }
}

- (void)tapSmallViewAction:(UITapGestureRecognizer *)tap {
    if (self.dragEnable && tap.state==UIGestureRecognizerStateEnded) {
        [self existSmallWindow];
    }
}
- (void)existSmallWindow {
    
}
- (void)addGes {
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(dragAction:)];
    panGestureRecognizer.minimumNumberOfTouches = 1;
    panGestureRecognizer.maximumNumberOfTouches = 1;
    panGestureRecognizer.delegate = self;
    [self.view addGestureRecognizer:panGestureRecognizer];
    
    
    UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapSmallViewAction:)];
    [self.view addGestureRecognizer:tapGes];
}


@end
