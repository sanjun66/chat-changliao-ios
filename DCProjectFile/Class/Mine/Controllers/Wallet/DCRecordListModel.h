//
//  DCRecordListModel.h
//  DCProjectFile
//
//  Created  on 2023/9/18.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DCRecordListModel : NSObject
@property (nonatomic,copy) NSString *amount;
@property (nonatomic,copy) NSString *reason;
@property (nonatomic,copy) NSString *created_at;
@property (nonatomic,copy) NSString *coin;
/// 1-充值，2-提现
@property (nonatomic,assign) int type;
/// 1等待中 2审核中 3成功 4失败
@property (nonatomic,assign) int state;

@end

NS_ASSUME_NONNULL_END
