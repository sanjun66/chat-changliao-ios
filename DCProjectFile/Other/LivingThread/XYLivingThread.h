

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^XYLivingThreadTask)(void);

@interface XYLivingThread : NSObject

/**
 在默认全局常驻线程中执行操作 (只要调用,默认线程即创建且不会销毁)

 @param task 操作
 */
+ (void)executeTask:(XYLivingThreadTask)task;

/**
 在自定义全局常驻线程中执行操作 (根据 identity 创建自定义线程,且创建后不会销毁)
 
 @param task 操作
 @param identity 自定义线程唯一标识
 */
+ (void)executeTask:(XYLivingThreadTask)task identity:(NSString *)identity;

/**
 在默认常驻线程中执行操作 (线程需随当前对象创建或销魂)
 
 @param task 操作
 */
- (void)executeTask:(XYLivingThreadTask)task;

@end

NS_ASSUME_NONNULL_END
