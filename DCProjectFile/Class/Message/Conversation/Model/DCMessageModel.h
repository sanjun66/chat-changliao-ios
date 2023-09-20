//
//  DCMessageModel.h
//  DCProjectFile
//
//  Created  on 2023/6/7.
//

#import <Foundation/Foundation.h>
#import "DCStatusDefine.h"
#import "DCUserInfo.h"

NS_ASSUME_NONNULL_BEGIN

@class DCMessageContent;
@class DCMessageExtra;

@interface DCMessageModel : NSObject
/// 消息类型 talk_message
@property (nonatomic, copy) NSString *event_name;
/// 本地使用，消息唯一id
@property (nonatomic, copy) NSString *uuid;
/// 此数据的提示信息
@property (nonatomic, copy) NSString *message;
/// 此数据的状态码
@property (nonatomic, assign) NSInteger code;

@property (nonatomic, copy) NSString *aesData;

@property (nonatomic, strong) DCMessageContent *data;

@property (nonatomic, strong) NSArray <DCMessageContent*>*list;

@property (nonatomic, strong) NSArray <NSString*>*message_ids;

@end



@interface DCMessageContent : NSObject
/// 消息id
@property (nonatomic, copy) NSString* messageId;

/// 发送人id
@property (nonatomic, copy) NSString *from_uid;

/// 接收人id
@property (nonatomic, copy) NSString *to_uid;

/// 目标会话id
@property (nonatomic, copy) NSString *targetId;

/// 聊天类型 1 私聊 2群聊
@property (nonatomic, assign) int talk_type;

/// 是否已读 1是 0否
@property (nonatomic, assign) BOOL is_read;

/// 是否撤回 1是 0否
@property (nonatomic, assign) BOOL is_revoke;

/// 引用id 消息的唯一标识
@property (nonatomic, assign) int quote_id;

/// 消息类型  1 文本消息 2 文件消息 3 转发消息 4代码消息 5 投票消息 6 群组公告 7好友申请 8 登录通知消息 9入群退群 10语音通话 11视频通话 12加好友
@property (nonatomic, assign) int message_type;

/// @好友 、 多个用英文逗号 “,” 拼接 (0:代表所有人)
@property (nonatomic, copy) NSString *warn_users;

/// 消息内容 不超过1024个字符串
@property (nonatomic, copy) NSString *message;

/// 消息时间
@property (nonatomic, assign) long created_at;

/// 消息毫秒级时间戳
@property (nonatomic, assign) long timestamp;

/// 附加信息
@property (nonatomic, strong) DCMessageExtra *extra;

/// 消息方向
@property (nonatomic, assign) DCMessageDirection messageDirection;

@property (nonatomic, assign) DCConversationType conversationType;

///
@property (nonatomic, strong) DCUserInfo *senderUser;

/// 本地使用，消息唯一id
@property (nonatomic, copy) NSString *uuid;

/// 是否为加密消息
@property (nonatomic, assign) BOOL is_secret;

/// 消息密码
@property (nonatomic, copy) NSString *pwd;


@property (nonatomic, assign) DCSentStatus msgSentStatus;

@property (nonatomic, assign) BOOL isDisplayMsgTime;

@property (nonatomic, assign) BOOL isSelected;
@property (nonatomic, assign) BOOL isHighlighted;
@property (nonatomic) CGSize cellSize;


/// 加好友使用 maker || taker
@property (nonatomic, copy) NSString *flag;

- (NSComparisonResult)compareMessageDatas:(DCMessageContent *)msg;

@end


@interface DCMessageExtra : NSObject

/// 文件后缀
@property (nonatomic, copy) NSString * suffix;

/// 原始名称
@property (nonatomic, copy) NSString * original_name;

/// 本地路径
@property (nonatomic, copy) NSString * path;

/// 封面地址
@property (nonatomic, copy) NSString * cover;

/// 网络地址
@property (nonatomic, copy) NSString * url;

/// 文件类型[1:图片;2:视频;3:文件;4语音]
/// [1:入群通知;2:自动退群;3:管理员踢群;4群解散]
@property (nonatomic, assign) int type;

/// 文件时长
@property (nonatomic, assign) int duration;

/// 文件大小
@property (nonatomic, assign) CGFloat size;

/// 文件宽度
@property (nonatomic, assign) CGFloat weight;

/// 文件高度
@property (nonatomic, assign) CGFloat height;

/// 文件上传渠道
@property (nonatomic, copy) NSString * driver;

/// 通话状态=1- 发起方取消 2- 接收方拒绝 3- 对方无应答 4- 接受方同意 5- 通话正常挂断 6 通话异常
@property (nonatomic, assign) int state;
/// 群视频发起人昵称
@property (nonatomic, copy) NSString *nickname;
//MARK: - Group
/// 操作人id
@property (nonatomic, copy) NSString *operate_user_id;
@property (nonatomic, copy) NSString *operate_user_name;
@property (nonatomic, strong) NSArray *users;


//MARK: - 合并转发消息
@property (nonatomic, assign) int talk_type;
@property (nonatomic, strong) NSArray <DCMessageContent*>*talk_list;

//MARK: - 引用消息
@property (nonatomic, strong)DCMessageContent* quote_msg;
@end
NS_ASSUME_NONNULL_END
