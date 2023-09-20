//
//  DCReachabilityManager.h
//  DCProjectFile
//
//  Created on 2023/3/2.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DCReachabilityManager : NSObject
@property (nonatomic, assign) BOOL isNetworkOK;

+ (instancetype)sharedManager;
- (void)starMonitorNetworking;

@end

NS_ASSUME_NONNULL_END
