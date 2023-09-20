//
//  DCFileManager.h
//  DCProjectFile
//
//  Created  on 2023/6/29.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DCFileManager : NSObject
/// 把消息文件存入本地
+ (NSString *)saveMessageFile:(NSData *)fileData fileName:(NSString *)fileName;

/// 获取图片消息的缓存图片
+ (UIImage *)getMessageImage:(NSString *)msgPath;

+ (NSData *)getMessageFileData:(NSString *)msgPath;

+ (NSString *)getFilePath:(NSString *)msgPath;

/// 根据路径获取文件名
+ (NSString *)fileName:(NSString *)filePath;

// 获取消息文件缓存的路径
+ (NSString *)getMessageFileCachePath;

/// 判断是否存在
+ (BOOL)isExistsAtPath:(NSString *)path;

+ (BOOL)moveItemAtPath:(NSString *)path toPath:(NSString *)toPath overwrite:(BOOL)overwrite error:(NSError *__autoreleasing *)error;
@end

NS_ASSUME_NONNULL_END
