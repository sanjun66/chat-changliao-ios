//
//  DCFileManager.m
//  DCProjectFile
//
//  Created  on 2023/6/29.
//

#import "DCFileManager.h"

@implementation DCFileManager
+ (NSString *)saveMessageFile:(NSData *)fileData fileName:(NSString *)fileName {
    NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/MessageFile"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:path] == NO) {
        [[NSFileManager defaultManager] createDirectoryAtPath:path
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:nil];
    }
    
    NSString *filePath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@",fileName]];
    
    BOOL isOk = [fileData writeToFile:filePath atomically:YES];
    NSLog(@"%@",isOk?@"文件保存成功":@"文件保存失败");
    return filePath;
}

+ (UIImage *)getMessageImage:(NSString *)msgPath {
    NSString *fileName = [msgPath componentsSeparatedByString:@"/"].lastObject;
    
    NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/MessageFile"];
    NSString *filePath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@",fileName]];
    if (![self isExistsAtPath:filePath]) {
        return nil;
    }
    return [UIImage imageWithContentsOfFile:filePath];
}


+ (NSString *)getFilePath:(NSString *)msgPath {
    NSString *fileName = [msgPath componentsSeparatedByString:@"/"].lastObject;
    
    NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/MessageFile"];
    NSString *filePath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@",fileName]];
    
    return filePath;
}

+ (NSString *)fileName:(NSString *)filePath {
    return [filePath componentsSeparatedByString:@"/"].lastObject;;
}

+ (NSData *)getMessageFileData:(NSString *)msgPath {
    NSString *fileName = [msgPath componentsSeparatedByString:@"/"].lastObject;
    
    NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/MessageFile"];
    NSString *filePath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@",fileName]];
    
    return [NSData dataWithContentsOfFile:filePath];
}

+ (NSString *)getMessageFileCachePath {
    NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/MessageFile"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:path] == NO) {
        [[NSFileManager defaultManager] createDirectoryAtPath:path
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:nil];
    }
    
    NSString *filePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/MessageFile"];
    
    return filePath;
}

#pragma mark - 移动文件(夹)
/*参数1、被移动文件路径
 *参数2、要移动到的目标文件路径
 *参数3、当要移动到的文件路径文件存在，会移动失败，这里传入是否覆盖
 *参数4、错误信息
 */
+ (BOOL)moveItemAtPath:(NSString *)path toPath:(NSString *)toPath overwrite:(BOOL)overwrite error:(NSError *__autoreleasing *)error {
    // 先要保证源文件路径存在，不然抛出异常
    if (![self isExistsAtPath:path]) {
        [NSException raise:@"非法的源文件路径" format:@"源文件路径%@不存在，请检查源文件路径", path];
        return NO;
    }
    //获得目标文件的上级目录
    NSString *toDirPath = [self directoryAtPath:toPath];
    if (![self isExistsAtPath:toDirPath]) {
        // 创建移动路径
        if (![self createDirectoryAtPath:toDirPath error:error]) {
            return NO;
        }
    }
    // 判断目标路径文件是否存在
    if ([self isExistsAtPath:toPath]) {
        //如果覆盖，删除目标路径文件
        if (overwrite) {
            //删掉目标路径文件
            [self removeItemAtPath:toPath error:error];
        }else {
           //删掉被移动文件
            [self removeItemAtPath:path error:error];
            return YES;
        }
    }
    
    // 移动文件，当要移动到的文件路径文件存在，会移动失败
    BOOL isSuccess = [[NSFileManager defaultManager] moveItemAtPath:path toPath:toPath error:error];
    
    return isSuccess;
}
+ (BOOL)createDirectoryAtPath:(NSString *)path error:(NSError *__autoreleasing *)error {
    NSFileManager *manager = [NSFileManager defaultManager];
    /* createDirectoryAtPath:withIntermediateDirectories:attributes:error:
     * 参数1：创建的文件夹的路径
     * 参数2：是否创建媒介的布尔值，一般为YES
     * 参数3: 属性，没有就置为nil
     * 参数4: 错误信息
    */
    BOOL isSuccess = [manager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:error];
    return isSuccess;
}

+ (BOOL)removeItemAtPath:(NSString *)path error:(NSError *__autoreleasing *)error {
    return [[NSFileManager defaultManager] removeItemAtPath:path error:error];
}

#pragma mark - 判断文件(夹)是否存在
+ (BOOL)isExistsAtPath:(NSString *)path {
    return [[NSFileManager defaultManager] fileExistsAtPath:path];
}

+ (NSString *)directoryAtPath:(NSString *)path {
    return [path stringByDeletingLastPathComponent];
}

+ (BOOL)createFileAtPath:(NSString *)path overwrite:(BOOL)overwrite error:(NSError *__autoreleasing *)error {
    // 如果文件夹路径不存在，那么先创建文件夹
    NSString *directoryPath = [self directoryAtPath:path];
    if (![self isExistsAtPath:directoryPath]) {
        // 创建文件夹
        if (![self createDirectoryAtPath:directoryPath error:error]) {
            return NO;
        }
    }
    // 如果文件存在，并不想覆盖，那么直接返回YES。
    if (!overwrite) {
        if ([self isExistsAtPath:path]) {
            return YES;
        }
    }
   /*创建文件
    *参数1：创建文件的路径
    *参数2：创建文件的内容（NSData类型）
    *参数3：文件相关属性
    */
    BOOL isSuccess = [[NSFileManager defaultManager] createFileAtPath:path contents:nil attributes:nil];

    return isSuccess;
}
@end
