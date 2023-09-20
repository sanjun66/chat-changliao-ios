//
//  DCCloudConversationDataModel.h
//  DCProjectFile
//
//  Created  on 2023/9/12.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DCCloudConversationDataModel : NSObject
@property (nonatomic, copy) NSString * avatar;
@property (nonatomic, copy) NSString * msg_id;
@property (nonatomic, copy) NSString * targetId;
@property (nonatomic, copy) NSString * message;
@property (nonatomic, copy) NSString * updated_at;
@property (nonatomic, copy) NSString * name;

@property (nonatomic, assign) int talk_type;
@property (nonatomic, assign) int message_type;

@property (nonatomic, assign) long timestamp;

@property (nonatomic, assign) BOOL is_pwd;
@property (nonatomic, assign) BOOL is_disturb;
@end

NS_ASSUME_NONNULL_END
