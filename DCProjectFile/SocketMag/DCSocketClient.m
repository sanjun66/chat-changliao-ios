//
//  DCSocketClient.m
//  DCProjectFile
//
//  Created  on 2023/6/19.
//

#import "DCSocketClient.h"
#import "DCSocketClient+MsgSend.h"
#import "DCSocketClient+MsgReceive.h"

#import "GCDConstant.h"
#import <objc/runtime.h>

#define MAX_REPEAT_CONNECT_NUMBER         2   // 失败立即重连次数
#define REPEAT_CONNECT_INTERVAL           3   // 失败立即重连间隔
#define SOCKET_FAIL_RECONNECT_INTERVAL   30   // 链接心跳间隔


@interface DCSocketClient ()<SRWebSocketDelegate>

/// 是否为首次连接
@property (nonatomic, assign) BOOL isFirstTime;

/// 是否为主动关闭
@property (nonatomic, assign) BOOL isActiveClose;

//@property (nonatomic, assign) SRReadyState socketState;

/// 链接心跳定时
@property (nonatomic, strong) GCDSource* conntectTimer;

/// 已重连次数
@property (nonatomic, assign) NSUInteger reConnectCount;


@property (nonatomic, strong) NSMutableDictionary *refTargets;

@end

@implementation DCSocketClient
+ (instancetype)sharedInstance {
    static DCSocketClient* instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.isNeedHandleOfflineMsg = YES;
        self.reConnectCount = 0;
        _isFirstTime = YES;
        _isActiveClose = NO;
        
        _serailQueue = dispatch_queue_create("com.projectfile.dispatchQueue", DISPATCH_QUEUE_SERIAL);
        [self addNotification];
    }
    return self;
}


- (void)addNotification {
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillEnterForegroundNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        DCLog(@"%ld",self.webSocket.readyState);
        [self reConnect];
        [self.conntectTimer resumeTimer];
    }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidEnterBackgroundNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        [self destroySocket];
        [self.conntectTimer pauseTimer];
    }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:kNetworkReachabilityStatusNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        if ([DCReachabilityManager sharedManager].isNetworkOK) {
            [self reConnect];
        }else {
            [DCSocketClient sharedInstance].kSocketStatus = KSocketNetworkFailStatus;
        }
    }];
}


#pragma mark - instance -
- (SRWebSocket *)webSocket {
    if (_webSocket == nil) {
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@?token=%@",kSocketPre,[[DCUserManager sharedManager] userModel].token]]];
        request.timeoutInterval = 10;
        [request setValue:@"" forHTTPHeaderField:@"Cookie"];
        
        _webSocket = [[SRWebSocket alloc] initWithURLRequest:request];
        [_webSocket setDelegateDispatchQueue:_serailQueue];
        _webSocket.delegate = self;
    }
    return _webSocket;
}

/// 销毁socket
- (void)destroySocket{
    if (_webSocket) {
        _webSocket.delegate = nil;
        [_webSocket close];
        self.webSocket = nil;
    }
}

/// 销毁conntectTimer
- (void)destroyConntectTimer {
    if (_conntectTimer) {
        [_conntectTimer stopTimer];
        self.conntectTimer = nil;
    }
}


#pragma mark - 连接 & 断开 -
- (void)connect {
    _isFirstTime = NO;
    _isActiveClose = NO;
    [self _open];
//    [self.webSocket addObserver:self forKeyPath:@"readyState" options:NSKeyValueObservingOptionNew context:nil];
}
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if ([keyPath isEqualToString:@"readyState"]) {
        if ([change[@"new"] intValue] == 1) {
            [MBProgressHUD showTips:@"socket已连接"];
        }else {
            [MBProgressHUD showTips:@"socket断开了"];
        }
    }
    NSLog(@"------%@",change);
}
    
    
- (void)reConnect {
//    if (self.webSocket.readyState == SR_OPEN || self.webSocket.readyState == SR_CONNECTING) {
//        NSLog(@"webSocket is open or connecting");
//    } else {
        if (_isFirstTime == NO && _isActiveClose == NO) {
            [self _open];
        }
//    }
}

- (void)disconnect {
    _isActiveClose = YES;
    dispatch_async(_serailQueue, ^{
        [self.webSocket close];
        [self destroySocket];
        [self destroyConntectTimer];
    });
}

/// 连接（重连前先 销毁已有的websocket）
- (void)_open {
    [DCSocketClient sharedInstance].kSocketStatus = KSocketConnectingStatus;
    dispatch_async(_serailQueue, ^{
        [self destroySocket];
        [self destroyConntectTimer];
        [self.webSocket open];
    });
}


#pragma mark -- WebSocketDelegate --
- (void)webSocketDidOpen:(SRWebSocket *)webSocket {
    self.reConnectCount = 0;
    [self receiveHistoryMessage:nil];
    
    /// 心跳包，防止服务端杀死
    self.conntectTimer = [[GCDSource alloc] initWithTimeInterval:SOCKET_FAIL_RECONNECT_INTERVAL repeats:YES timerBlock:^{
        [self sendHeartBeat];
    }];
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error {
    /// 断开重连，重连失败再走下方代理
    if (self.reConnectCount < MAX_REPEAT_CONNECT_NUMBER && [DCReachabilityManager sharedManager].isNetworkOK) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(REPEAT_CONNECT_INTERVAL * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            /// 延后重连，避免服务短时间无响应
            [self _open];
        });
        self.reConnectCount ++;
    } else {
        self.reConnectCount = 0;
        
        [self destroySocket];
        [self destroyConntectTimer];
        [DCSocketClient sharedInstance].kSocketStatus = KSocketUnknowFailStatus;
    }
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean {
    
    if (code == SRStatusCodeGoingAway || code == SRStatusCodeNormal) {
        /// 主动断开后销毁 Socket & Timer
        [self destroySocket];
        [self destroyConntectTimer];

    } else {
        /// 非主动断开，重新连接 （SRStatusCodeTryAgainLater、SRStatusCodeServiceRestart等状态）
        if ([DCReachabilityManager sharedManager].isNetworkOK) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(REPEAT_CONNECT_INTERVAL * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                /// 延后重连
                [self _open];
            });
        } else {
            [self destroySocket];
            [self destroyConntectTimer];
        }
    }
}


- (BOOL)webSocketShouldConvertTextFrameToString:(SRWebSocket *)webSocket {
    return YES;
}



@end
