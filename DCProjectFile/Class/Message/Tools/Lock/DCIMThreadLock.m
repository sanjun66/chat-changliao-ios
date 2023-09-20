//
//  DCIMThreadLock.m
//  DCProjectFile
//
//  Created  on 2023/7/7.
//

#import "DCIMThreadLock.h"
@interface DCIMThreadLock ()
@property (nonatomic, assign) pthread_rwlock_t rwlock;
@end

@implementation DCIMThreadLock
+ (instancetype)createRWLock {
    return [[DCIMThreadLock alloc] init];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        pthread_rwlock_init(&_rwlock, NULL);
    }
    return self;
}

- (void)performReadLockBlock:(dispatch_block_t)block {
    if (!block) {
        return;
    }
    pthread_rwlock_rdlock(&_rwlock);
    block();
    pthread_rwlock_unlock(&_rwlock);
}

- (void)performWriteLockBlock:(dispatch_block_t)block {
    if (!block) {
        return;
    }
    pthread_rwlock_wrlock(&_rwlock);
    block();
    pthread_rwlock_unlock(&_rwlock);
}

- (void)dealloc {
    pthread_rwlock_destroy(&_rwlock);
}
@end
