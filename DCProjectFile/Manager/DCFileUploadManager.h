//
//  DCFileUploadManager.h
//  DCProjectFile
//
//  Created  on 2023/8/17.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^UploadSuccessBlock)(NSString * result);
typedef void(^UploadFailureBlock)(id error);

@interface DCFileUploadManager : NSObject
@property (nonatomic, strong) NSMutableDictionary *dataTaskDictionary;
+ (instancetype)sharedManager;
- (void)upload:(NSData*)data name:(NSString *)fileName uniquelyIdentifies:(nullable NSString *)identifies success:(UploadSuccessBlock)success failure:(UploadFailureBlock)failure;
@end

NS_ASSUME_NONNULL_END
