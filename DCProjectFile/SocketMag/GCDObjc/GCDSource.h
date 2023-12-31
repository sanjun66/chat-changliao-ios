

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GCDSource : NSObject

- (instancetype)initWithTimeInterval:(NSTimeInterval)timeInterval repeats:(BOOL)repeats timerBlock:(void(^)(void))timerBlock;

- (instancetype)initWithTimeInterval:(NSTimeInterval)timeInterval repeats:(BOOL)repeats timerBlock:(void(^)(void))timerBlock timerQueue:(dispatch_queue_t)timerQueue blockQueue:(dispatch_queue_t)blockQueue;

- (instancetype)init UNAVAILABLE_ATTRIBUTE;

- (void)pauseTimer; // 挂起与恢复必须平衡，不然会crash

- (void)resumeTimer;

- (void)stopTimer; // 不能在挂起的状态cancel，需要恢复定时器再cancel

@end

NS_ASSUME_NONNULL_END

/*
self.source = [[GCDSource alloc] initWithTimeInterval:3 repeats:YES timerBlock:^{
    
}];

[_source pauseTimer];
[_source resumeTimer];
[_source stopTimer];
 */
