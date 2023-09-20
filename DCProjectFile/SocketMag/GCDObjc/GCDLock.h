

#import <Foundation/Foundation.h>

@interface GCDLock : NSObject

- (void)lock:(void(^)(void))block;

@end
