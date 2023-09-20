//
//  DCStatusDefine.h
//  DCProjectFile
//
//  Created  on 2023/6/6.
//

#ifndef DCStatusDefine_h
#define DCStatusDefine_h


#pragma mark DCConversationType - 会话类型
/*!
 会话类型
 */
typedef NS_ENUM(NSUInteger, DCConversationType) {
    /*!
     单聊
     */
    DC_ConversationType_PRIVATE = 1,

    /*!
     群组
     */
    DC_ConversationType_GROUP = 2,

    /*!
     聊天室
     */
    DC_ConversationType_CHATROOM = 3,

    /*!
     客服
     */
    DC_ConversationType_CUSTOMERSERVICE = 4,

    /*!
     系统会话
     */
    DC_ConversationType_SYSTEM = 5,

    /*!
     加密会话（仅对部分私有云用户开放，公有云用户不适用）
     */
    DC_ConversationType_Encrypted = 6,

    /*!
     无效类型
     */
    DC_ConversationType_INVALID

};

#pragma mark RCConversationNotificationStatus - 会话提醒状态
/*!
 会话提醒状态
 */
typedef NS_ENUM(NSUInteger, DCConversationNotificationStatus) {
    /*!
     免打扰

     */
    DO_NOT_DISTURB = 0,

    /*!
     新消息提醒
     */
    NOTIFY = 1,
};

typedef NS_ENUM(NSUInteger, DCMessageDirection) {
    /*!
     发送
     */
    DC_MessageDirection_SEND = 1,

    /*!
     接收
     */
    DC_MessageDirection_RECEIVE = 2
};


#pragma mark RCSentStatus - 消息的发送状态
/*!
 消息的发送状态
 */
typedef NS_ENUM(NSUInteger, DCSentStatus) {
    /*!
     发送中
     */
    DC_SentStatus_SENDING = 1,

    /*!
     发送失败
     */
    DC_SentStatus_FAILED = 2,

    /*!
     已发送成功
     */
    DC_SentStatus_SENT = 3,

    /*!
     对方已接收
     */
    DC_SentStatus_RECEIVED = 4,

    /*!
     对方已阅读
     */
    DC_SentStatus_READ = 5,

    /*!
     对方已销毁
     */
    DC_SentStatus_DESTROYED = 6,

    /*!
     发送已取消
     */
    DC_SentStatus_CANCELED = 7,

    /*!
     无效类型
     */
    DC_SentStatus_INVALID
};

#pragma mark RCReceivedStatus - 消息的接收状态
/*!
 消息的接收状态
 */
typedef NS_ENUM(NSUInteger, DCReceivedStatus) {
    /*!
     未读
     */
    ReceivedStatus_UNREAD = 0,

    /*!
     已读
     */
    ReceivedStatus_READ = 1,

    /*!
     已听

     @discussion 仅用于语音消息
     */
    ReceivedStatus_LISTENED = 2,

    /*!
     已下载
     */
    ReceivedStatus_DOWNLOADED = 4,

    /*!
     该消息已经被其他登录的多端收取过。（即该消息已经被其他端收取过后。当前端才登录，并重新拉取了这条消息。客户可以通过这个状态更新
     UI，比如不再提示）。
     */
    ReceivedStatus_RETRIEVED = 8,

    /*!
     该消息是被多端同时收取的。（即其他端正同时登录，一条消息被同时发往多端。客户可以通过这个状态值更新自己的某些 UI
     状态）。
     */
    ReceivedStatus_MULTIPLERECEIVE = 16,

};

#pragma mark RCMediaType - 消息内容中多媒体文件的类型
/*!
 消息内容中多媒体文件的类型
 */
typedef NS_ENUM(NSUInteger, DCMediaType) {
    /*!
     图片
     */
    MediaType_IMAGE = 1,

    /*!
     语音
     */
    MediaType_AUDIO = 2,

    /*!
     视频
     */
    MediaType_VIDEO = 3,

    /*!
     其他文件
     */
    MediaType_FILE = 4,

    /*!
     小视频
     */
    MediaType_SIGHT = 5,

    /*!
     合并转发
     */
    MediaType_HTML = 6
};


/*!
 输入工具栏的输入模式
 */
typedef NS_ENUM(NSInteger, KBottomBarStatus) {
    /*!
     初始状态
     */
    KBottomBarDefaultStatus = 0,
    /*!
     文本输入状态
     */
    KBottomBarKeyboardStatus,
    /*!
     功能板输入状态
     */
    KBottomBarPluginStatus,
    /*!
     表情输入状态
     */
    KBottomBarEmojiStatus,
    /*!
     语音消息输入状态
     */
    KBottomBarRecordStatus,
    /*!
     常用语输入状态
     */
    KBottomBarCommonPhrasesStatus,
    /*!
     阅后即焚输入状态
     */
    KBottomBarDestructStatus,
};


/*!
 Socket的连接状态
 */
typedef NS_ENUM(NSInteger, KSocketStatus) {
    
    KSocketDefaultStatus = 1,
    
    KSocketConnectingStatus = 2,
   
    KSocketReceivingStatus = 3,
    
    KSocketNetworkFailStatus = 4,
    
    KSocketUnknowFailStatus = 5,
};


typedef NS_ENUM(NSInteger, KTextInputType) {
    
    KTextInputTypeNickName = 1,
    
    KTextInputTypeNoteName = 2,
   
    KTextInputTypeGroupName = 3,
    
    KTextInputTypeGroupNotice = 4,
    
    KTextInputTypeGroupDescribe = 5,
};


typedef NS_ENUM(NSInteger, CallDirection) {
    CallDirectionIncoming,
    CallDirectionOutgoing
};

#endif /* DCStatusDefine_h */
