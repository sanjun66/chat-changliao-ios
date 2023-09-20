//
//  DCWalletDataModel.h
//  DCProjectFile
//
//  Created  on 2023/9/18.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DCWalletDataModel : NSObject
@property (nonatomic,assign) int withdraw_channel;
@property (nonatomic,assign) int recharge_channel;
@property (nonatomic,copy) NSString *coin;
@property (nonatomic,copy) NSString *balance;

@end

NS_ASSUME_NONNULL_END
