
#import <Foundation/Foundation.h>

@interface GCDQueue : NSObject

+ (void)asyncQueue:(dispatch_queue_t)queue block:(void(^)(void))block;

+ (void)asyncGlobal:(void(^)(void))block;

+ (void)asyncMain:(void(^)(void))block;

+ (void)delay:(void(^)(void))block timeInterval:(NSTimeInterval)timeInterval;

@end
