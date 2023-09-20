//
//  DCVersionModel.h
//  DCProjectFile
//
//  Created  on 2023/8/30.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DCVersionModel : NSObject

@property (nonatomic, copy) NSString * release_date;
@property (nonatomic, copy) NSString * platform;
@property (nonatomic, copy) NSString * update_url;
@property (nonatomic, copy) NSString * desc;
@property (nonatomic, copy) NSString * version_name;
//是否强制更新 1-强制更新，0-非强制
@property (nonatomic, assign) BOOL forced_update;
@property (nonatomic, assign) CGFloat version_code;

@end

NS_ASSUME_NONNULL_END
