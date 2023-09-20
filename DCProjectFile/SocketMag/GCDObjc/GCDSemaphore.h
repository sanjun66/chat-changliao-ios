

#import <Foundation/Foundation.h>

/**
 ** 信号量为：0; wait 暂停执行后面代码，而且会阻塞线程
 ** 信号量为：1、2...设置线程最多的执行数量
 **/

@interface GCDSemaphore : NSObject

- (instancetype)initWithValue:(long)value;

+ (instancetype)semaphore;

- (void)wait;

- (void)signal;

@end
