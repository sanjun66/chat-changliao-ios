//
//  DCMentionedStringRangeInfo.h
//  DCProjectFile
//
//  Created  on 2023/8/11.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DCMentionedStringRangeInfo : NSObject
/*!
 @用户Id
 */
@property (nonatomic, strong) NSString *userId;

/*!
 文本消息的内容
 */
@property (nonatomic, strong) NSString *content;

/*!
 文本消息的range
 */
@property (nonatomic, assign) NSRange range;

- (NSString *)encodeToString;

- (instancetype)initWithDecodeString:(NSString *)mentionedInfoString;

@end

NS_ASSUME_NONNULL_END
