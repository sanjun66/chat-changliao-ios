//
//  DCConversationListVC+Request.h
//  DCProjectFile
//
//  Created  on 2023/9/5.
//

#import "DCConversationListVC.h"

NS_ASSUME_NONNULL_BEGIN

@interface DCConversationListVC (Request)

/// 获取会话信息
- (void)requesetConversationInfo ;
/// 消息解密
- (void)requestSecretMessageDecrypt:(DCMessageContent *)msg pwd:(NSString *)pwd;
/// 发起音视频通话
- (void)requestPreCallCheck:(QBRTCConferenceType)conferenceType members:(NSArray*)members isMultit:(BOOL)isMultit toUids:(NSString *)touids;
/// 上报消息已读
- (void)requestReportMessageRead:(NSString *)msgId;
/// 获取云消息记录
- (void)requestCloudMessageList:(DCMessageContent*)model;
/// 消息删除接口
- (void)requestForMessageDelete:(NSString *)msgId;
/// 获取用户在线状态
- (void)requestUserOnlineState;
@end

NS_ASSUME_NONNULL_END
