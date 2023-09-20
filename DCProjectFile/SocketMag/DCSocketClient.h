//
//  DCSocketClient.h
//  DCProjectFile
//
//  Created  on 2023/6/19.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


@interface DCSocketClient : NSObject

@property (nonatomic, strong, nullable) SRWebSocket* webSocket;

@property (nonatomic) dispatch_queue_t serailQueue;

@property (nonatomic, assign) BOOL isNeedHandleOfflineMsg;

@property (nonatomic, assign) KSocketStatus kSocketStatus;

@property (nonatomic, assign) DCConversationType conversationType;

@property (nonatomic, copy, nullable) NSString *secretPsw;

+ (instancetype)sharedInstance;

- (void)connect;
- (void)reConnect;
- (void)disconnect;
- (void)destroySocket;
@end

NS_ASSUME_NONNULL_END
