//
//  DCSocketClient+MsgReceive.h
//  DCProjectFile
//
//  Created  on 2023/6/19.
//

#import "DCSocketClient.h"

NS_ASSUME_NONNULL_BEGIN

@interface DCSocketClient (MsgReceive)
/// 撤回消息处理
- (void)onRevokeWithMsgId:(NSString *)msgId;
@end

NS_ASSUME_NONNULL_END
