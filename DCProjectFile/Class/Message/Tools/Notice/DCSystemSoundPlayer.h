//
//  DCSystemSoundPlayer.h
//  DCProjectFile
//
//  Created  on 2023/7/17.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
typedef void (^DCSystemSoundPlayerCompletion)(BOOL complete);
@interface DCSystemSoundPlayer : NSObject
+ (DCSystemSoundPlayer *)defaultPlayer;
- (void)playSoundByMessage:(DCMessageContent *)dcMessage completeBlock:(DCSystemSoundPlayerCompletion)completion;

/**
 * 设置忽略响铃的会话
 */
- (void)setIgnoreConversationType:(DCConversationType)conversationType targetId:(NSString *)targetId;

/**
 * 清除忽略响铃的会话
 */
- (void)resetIgnoreConversation;

@end

NS_ASSUME_NONNULL_END
