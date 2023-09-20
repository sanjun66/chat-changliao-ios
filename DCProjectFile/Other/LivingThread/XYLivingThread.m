

#import "XYLivingThread.h"

@interface XYLivingThread()
@property (nonatomic, weak) NSThread *p_thread;
@property (nonatomic, assign, getter=isShouldKeepRunning) BOOL shouldKeepRunning;

@end

@implementation XYLivingThread

static NSThread *tm_defaultThread;
static NSMutableDictionary *tm_threadDictM;


#pragma mark - public
/**
 在默认全局常驻线程中执行操作 (只要调用,默认线程即创建且不会销毁)
 
 @param task 操作
 */
+ (void)executeTask:(XYLivingThreadTask)task {
    if (!task) {
        return;
    }
    
    if (!tm_defaultThread) {
        void (^creatThreadBlock)(void) = ^ {
            NSRunLoop *currentRunLoop = [NSRunLoop currentRunLoop];
            [currentRunLoop addPort:[NSPort new] forMode:NSDefaultRunLoopMode];
            [[NSRunLoop currentRunLoop] run];
            while (1) {
                [currentRunLoop runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
            }
        };
        
        if (@available(iOS 10.0, *)) {
            tm_defaultThread = [[NSThread alloc] initWithBlock:creatThreadBlock];
        } else {
            tm_defaultThread = [[NSThread alloc] initWithTarget:self selector:@selector(class_creatThreadMethod:) object:creatThreadBlock];
        }
        [tm_defaultThread start];
    }
    [self performSelector:@selector(class_taskMethod:) onThread:tm_defaultThread withObject:task waitUntilDone:NO];
}

+ (void)class_creatThreadMethod:(void (^)(void))block {
    block();
}

+ (void)class_taskMethod:(XYLivingThreadTask)task {
    task();
}

/**
 在自定义全局常驻线程中执行操作 (根据 identity 创建自定义线程,且创建后不会销毁)
 
 @param task 操作
 @param identity 自定义线程唯一标识
 */
+ (void)executeTask:(XYLivingThreadTask)task identity:(NSString *)identity {
    if (!task || !identity || identity.length == 0) {
        return;
    }
    
    if (!tm_threadDictM) {
        tm_threadDictM = [NSMutableDictionary dictionary];
    }
    
    NSThread *threadByIdentity = [tm_threadDictM objectForKey:identity];
    
    if (!threadByIdentity) {
        void (^creatThreadBlock)(void) = ^ {
            CFRunLoopSourceContext content = {0};
            CFRunLoopSourceRef source = CFRunLoopSourceCreate(kCFAllocatorDefault, 0, &content);
            CFRunLoopAddSource(CFRunLoopGetCurrent(), source, kCFRunLoopDefaultMode);
            CFRelease(source);
            CFRunLoopRunInMode(kCFRunLoopDefaultMode, 1.0e10, false);
        };
        
        if (@available(iOS 10.0, *)) {
            threadByIdentity = [[NSThread alloc] initWithBlock:creatThreadBlock];
        } else {
            threadByIdentity = [[NSThread alloc] initWithTarget:self selector:@selector(class_creatThreadMethod:) object:creatThreadBlock];
        }
        [threadByIdentity start];
        
        if (threadByIdentity) {
            [tm_threadDictM setObject:threadByIdentity forKey:identity];
        }
    }
    
    [self performSelector:@selector(class_taskMethod:) onThread:threadByIdentity withObject:task waitUntilDone:NO];
}

/**
 在默认常驻线程中执行操作 (线程需随当前对象创建或销毁)
 
 @param task 操作
 */
- (void)executeTask:(XYLivingThreadTask)task {
    if (!task || !self.p_thread) return;
    [self performSelector:@selector(threakTaskMethod:) onThread:self.p_thread withObject:task waitUntilDone:NO];
}

#pragma mark - system
- (instancetype)init {
    if (self = [super init]) {
        self.p_thread = [self thread];
    }
    return self;
}

- (void)dealloc {
    [self performSelector:@selector(clearThreadMethod) onThread:self.p_thread withObject:nil waitUntilDone:YES];
}

#pragma mark - private
- (NSThread *)thread {
    NSThread *thread = nil;
    __weak typeof(self) weakSelf = self;
    void (^creatThreadBlock)(void) = ^ {
        NSRunLoop *currentRunLoop = [NSRunLoop currentRunLoop];
        [currentRunLoop addPort:[NSPort new] forMode:NSDefaultRunLoopMode];
        while (weakSelf && weakSelf.isShouldKeepRunning) {
            [currentRunLoop runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
        }
    };
    
    self.shouldKeepRunning = YES;
    if (@available(iOS 10.0, *)) {
        thread = [[NSThread alloc] initWithBlock:creatThreadBlock];
    } else {
        thread = [[NSThread alloc] initWithTarget:weakSelf selector:@selector(creatThreadMethod:) object:creatThreadBlock];
    }
    [thread start];
    return thread;
}

- (void)creatThreadMethod:(void (^)(void))creatThreadBlock {
    creatThreadBlock();
}

- (void)threakTaskMethod:(void (^)(void))task {
    task ? task() : nil;
}

- (void)clearThreadMethod {
    self.shouldKeepRunning = NO;
    CFRunLoopStop(CFRunLoopGetCurrent());
}

@end
