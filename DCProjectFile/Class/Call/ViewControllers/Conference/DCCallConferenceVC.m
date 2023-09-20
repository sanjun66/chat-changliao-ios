//
//  DCCallConferenceVC.m
//  DCProjectFile
//
//  Created  on 2023/8/1.
//

#import "DCCallConferenceVC.h"
#import "DCLocalTrackView.h"
#import "DCRemoteTrackView.h"

#define kItemW (kScreenWidth/2)
#define kItemH (kScreenWidth/2)

@interface DCCallConferenceVC ()
@property (strong, nonatomic) DCLocalTrackView *localView;
@property (nonatomic, strong) NSMutableDictionary <NSNumber* , UIView*>*viewDictionary;
@property (nonatomic, assign) NSInteger mainUid;
@property (nonatomic, assign) CGFloat startPointY;
@end

@implementation DCCallConferenceVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    [self.view addSubview:self.localView];
//    [self.viewDictionary setObject:self.localView forKey:@(self.localView.userID)];
//    [self onRemoteUserComing:@(arc4random()%20+1)];
//    [self onRemoteUserComing:@(arc4random()%20+1)];
//    [self onRemoteUserComing:@(arc4random()%20+1)];
//
//    [self relayoutRemoteViewFrame];
//    [self setupBackground];
    
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(100, 100, kScreenWidth/2, kScreenWidth/2*(4/3))];
    view.backgroundColor = [kBlackColor colorWithAlphaComponent:0.5];
    [self.view addSubview:view];
    
    
}
- (void)setupBackground {
    UIImageView *imgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    imgView.contentMode = UIViewContentModeScaleAspectFill;
    imgView.clipsToBounds = YES;
    [imgView sd_setImageWithURL:[NSURL URLWithString:[DCUserManager sharedManager].currentUserInfo.portraitUri]];
    [self.view addSubview:imgView];
    
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVisualEffectView *visualEffectView = [[UIVisualEffectView alloc]initWithEffect:blurEffect];
    visualEffectView.frame = imgView.bounds;
    [imgView addSubview:visualEffectView];
}

- (void)relayoutRemoteViewFrame {
    
    NSInteger total = self.viewDictionary.count;

    self.startPointY = kItemH;
    if (total>2) {
        self.startPointY = kItemH/2;
    }
    [self.viewDictionary.allValues enumerateObjectsUsingBlock:^(UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.frame = CGRectMake(kItemW*(idx%2), self.startPointY + kItemH*(idx/2), kItemW, kItemH);
        if (total==3 && idx==2) {
            obj.frame = CGRectMake(kItemW*(idx%2)+kItemW/2, self.startPointY + kItemH*(idx/2), kItemW, kItemH);
        }
    }];
    
}


- (void)onTapTrackView:(UIView *)tapView {
    NSInteger uid ;
    if ([tapView isKindOfClass:[DCRemoteTrackView class]]) {
        uid = ((DCRemoteTrackView *)tapView).userID;
    }else {
        uid = ((DCLocalTrackView *)tapView).userID;
    }
    if (self.mainUid==uid) {
        self.mainUid = 0;
        [self relayoutRemoteViewFrame];
        return;
    }
    self.mainUid = uid;
    
    tapView.frame = CGRectMake(0, kItemW/2, kItemW*2, kItemH*2);
    
    CGFloat itemW = (kScreenWidth/(self.viewDictionary.count-1));
    
    CGFloat startPointX = 0;
    if (self.viewDictionary.count==2) {
        startPointX = kItemW/2;
        itemW = kItemW;
    }
    
    __block NSInteger idx = 0;
    
    
    [self.viewDictionary enumerateKeysAndObjectsUsingBlock:^(NSNumber * _Nonnull key, UIView * _Nonnull obj, BOOL * _Nonnull stop) {
        if (self.mainUid != key.integerValue) {
            
            obj.frame = CGRectMake(startPointX + idx * itemW, CGRectGetMaxY(tapView.frame), itemW, itemW);
            idx += 1;
        }
    }];
    
}
- (void)onRemoteUserComing:(NSNumber*)uid {
    DCRemoteTrackView *remoteView = [[DCRemoteTrackView alloc]init];
    remoteView.dragEnable = NO;
    remoteView.userID = uid.integerValue;
    remoteView.backgroundColor = UIColor.systemOrangeColor;
    [self.view addSubview:remoteView];
    remoteView.clickRemoteVideoViewBlock = ^(DCRemoteTrackView * _Nonnull selView) {
        [self onTapTrackView:selView];
    };
    [self.viewDictionary setObject:remoteView forKey:uid];
    
    [self relayoutRemoteViewFrame];
    
}

- (DCLocalTrackView *)localView {
    if (!_localView) {
        _localView = [[DCLocalTrackView alloc]initWithFrame:CGRectZero];
        _localView.freeRect = CGRectMake(10, kStatusBarHeight, kScreenWidth-20, kScreenHeight-kStatusBarHeight-kBottomSafe);
        _localView.userID = kUser.quickblox_id;
        _localView.backgroundColor = UIColor.systemTealColor;
        _localView.dragEnable = NO;
        _localView.isKeepBounds = YES;
        
        __weak typeof(self) weakSelf = self;
        _localView.clickDragViewBlock = ^(WMDragView *dragView) {
            __strong typeof(weakSelf)self = weakSelf;
            [self onTapTrackView:dragView];
        };
    }
    return _localView;
}

- (NSMutableDictionary *)viewDictionary {
    if (!_viewDictionary) {
        _viewDictionary = [NSMutableDictionary dictionary];
    }
    return _viewDictionary;
}

@end
