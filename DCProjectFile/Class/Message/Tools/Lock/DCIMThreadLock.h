//
//  DCIMThreadLock.h
//  DCProjectFile
//
//  Created  on 2023/7/7.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DCIMThreadLock : NSObject
// 创建实例（注意：每次都生成新的实例）
+ (instancetype)createRWLock;

// 读加锁，同一时间，允许多线程读
- (void)performReadLockBlock:(dispatch_block_t)block;

// 写加锁，同一时间，只允许一个线程写
- (void)performWriteLockBlock:(dispatch_block_t)block;

@end

NS_ASSUME_NONNULL_END
