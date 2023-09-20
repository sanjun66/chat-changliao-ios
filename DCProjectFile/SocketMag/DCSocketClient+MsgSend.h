//
//  DCSocketClient+MsgSend.h
//  DCProjectFile
//
//  Created  on 2023/6/19.
//

#import "DCSocketClient.h"

NS_ASSUME_NONNULL_BEGIN

@interface DCSocketClient (MsgSend)

/// 发送文字消息
- (void)createTextMsg:(NSString *)toUid content:(NSString *)connect mentionedUserIds:(nullable NSString *)uids;

/// 发送图片消息
- (void)createImageMsg:(NSString*)toUid image:(UIImage*)image ;

/// 发送语音消息
- (void)createVoiceMsg:(NSString *)toUid voiceData:(NSData *)data duration:(long)duration;

/// 发送视频消息
- (void)createVideoMsg:(NSString *)toUid localPath:(NSString *)path videoSize:(CGSize)size duration:(int)duration thumbPhoto:(UIImage *)thumbPhoto;

/// 发送文件消息
- (void)createFileMsg:(NSString *)toUid localPath:(NSString *)path size:(CGFloat)size;
/// 发送心跳消息
- (void)sendHeartBeat;

/// 发送拉取历史消息
- (void)receiveHistoryMessage:(NSString * _Nullable )ids;

/// 消息回执
- (void)sentMsgReceipt:(NSString *)msgId;

/// 撤回消息
- (void)revokeMessage:(DCMessageContent *)message;

/// 上传文件后发消息
-(void)upLoadMsgData:(NSData *)data
               parms:(NSMutableDictionary *)parms
               extra:(NSMutableDictionary *)extra
                uuid:(NSString *)uuid
      messageContent:(nullable DCMessageContent *)localMsg
            isResent:(BOOL)resent;

/// 发消息接口
- (void)sentMsgRequestWithParms:(NSDictionary *)parms
                           uuid:(NSString *)uuid
                 messageContent:(nullable DCMessageContent *)localMsg
                       isResent:(BOOL)resent;
@end

NS_ASSUME_NONNULL_END
