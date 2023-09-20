//
//  DCPreviewPhotoManager.h
//  DCProjectFile
//
//  Created on 2023/3/1.
//

#import <Foundation/Foundation.h>
#import "DCMessageModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface DCPreviewPhotoManager : NSObject
+ (instancetype)sharedManager;
// 显示视频播放
- (void)showVideo:(NSArray<HXCustomAssetModel*>*)assetModels previewView:(UIView *)previewView ;
// 显示图片预览
- (void)showPreviewPhoto:(NSArray<HXCustomAssetModel*>*)assetModels selectIndex:(NSInteger)selIdx compele:(UIView*(^)(NSInteger curIdx))complete;
- (void)showPreviewWith:(NSArray<DCMessageContent *>*)messages selectModel:(DCMessageContent*)model compele:(UIView*(^)(DCMessageContent * curModel))complete;

- (void)showPreview:(NSArray<DCMessageContent *>*)messages selectModel:(DCMessageContent*)model compele:(UIView*(^)(DCMessageContent * curModel))complete ;
@end

NS_ASSUME_NONNULL_END
