//
//  DCPreviewPhotoManager.m
//  DCProjectFile
//
//  Created on 2023/3/1.
//

#import "DCPreviewPhotoManager.h"
#import "YBImageBrowser.h"
#import "YBIBVideoData.h"
#import "DCUserInfoVC.h"

@interface DCPreviewPhotoManager ()<YBImageBrowserDelegate>

@end

@implementation DCPreviewPhotoManager
+ (instancetype)sharedManager {
    static DCPreviewPhotoManager *manager = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        manager = [[self alloc] init];
    });

    return manager;
}
// 显示视频播放
- (void)showVideo:(NSArray<HXCustomAssetModel*>*)assetModels previewView:(UIView *)previewView {
//    HXCustomAssetModel *assetModel = [HXCustomAssetModel assetWithNetworkVideoURL:[NSURL URLWithString:videoUrl] videoCoverURL:nil videoDuration:5 selected:YES];
    HXPhotoManager *photoManager = [HXPhotoManager managerWithType:HXPhotoManagerSelectedTypePhotoAndVideo];
    photoManager.configuration.videoAutoPlayType = HXVideoAutoPlayTypeAll;
    // 跳转预览界面时动画起始的view
    photoManager.configuration.customPreviewFromView = ^UIView *(NSInteger currentIndex) {
        return previewView;
    };
    // 跳转预览界面时展现动画的image
    photoManager.configuration.customPreviewFromImage = ^UIImage *(NSInteger currentIndex) {
        if ([previewView isKindOfClass: [UIImageView class]]) {
            return ((UIImageView*)previewView).image;
        }
        return nil;
    };
    // 退出预览界面时终点view
    photoManager.configuration.customPreviewToView = ^UIView *(NSInteger currentIndex) {
        return previewView;
    };
    photoManager.configuration.previewRespondsToLongPress = ^(UILongPressGestureRecognizer *longPress, HXPhotoModel *photoModel, HXPhotoManager *manager, HXPhotoPreviewViewController *previewViewController) {
        [[DCTools topViewController] presentViewController:[DCTools actionSheet:@[@"保存到相册"] complete:^(int idx) {
            HXCustomAssetModel *customModel = assetModels.firstObject;
            if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum([customModel.localVideoURL path])) {
                //保存相册核心代码
                UISaveVideoAtPathToSavedPhotosAlbum([customModel.localVideoURL path], self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
            }
            
            UIImageWriteToSavedPhotosAlbum(customModel.localImage, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
        }] animated:YES completion:nil];
    };
    
    [photoManager addCustomAssetModel:assetModels];

    [[DCTools topViewController] hx_presentPreviewPhotoControllerWithManager:photoManager
                                         previewStyle:HXPhotoViewPreViewShowStyleDark
                                         currentIndex:0
                                            photoView:nil];
}

- (void)showPreviewPhoto:(NSArray<HXCustomAssetModel*>*)assetModels selectIndex:(NSInteger)selIdx compele:(UIView*(^)(NSInteger curIdx))complete {
    
    HXPhotoManager *manager = [HXPhotoManager managerWithType:HXPhotoManagerSelectedTypePhotoAndVideo];
    manager.configuration.videoAutoPlayType = HXVideoAutoPlayTypeAll;
    manager.configuration.customPreviewFromView = ^UIView *(NSInteger currentIndex) {
        return complete(currentIndex);
    };
    manager.configuration.customPreviewToView = ^UIView *(NSInteger currentIndex) {
        return complete(currentIndex);
    };
    manager.configuration.customPreviewFromImage = ^UIImage *(NSInteger currentIndex) {
        if ([complete(currentIndex) isKindOfClass:[UIImageView class]]) {
            return ((UIImageView *)complete(currentIndex)).image;
        }
        return nil;
    };
    manager.configuration.customPreviewFromRect = ^CGRect(NSInteger currentIndex) {
        return complete(currentIndex).frame;
    };
    manager.configuration.previewRespondsToLongPress = ^(UILongPressGestureRecognizer *longPress, HXPhotoModel *photoModel, HXPhotoManager *manager, HXPhotoPreviewViewController *previewViewController) {
        [[DCTools topViewController] presentViewController:[DCTools actionSheet:@[@"保存到相册"] complete:^(int idx) {
            HXCustomAssetModel *customModel = assetModels.firstObject;
            UIImageWriteToSavedPhotosAlbum(customModel.localImage, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
        }] animated:YES completion:nil];
    };
    [manager addCustomAssetModel:assetModels];
    
    [[DCTools topViewController] hx_presentPreviewPhotoControllerWithManager:manager previewStyle:HXPhotoViewPreViewShowStyleDark showBottomPageControl:YES currentIndex:selIdx];
    
}



- (void)showPreviewWith:(NSArray<DCMessageContent *>*)messages selectModel:(DCMessageContent*)model compele:(UIView*(^)(DCMessageContent * curModel))complete {
    NSMutableArray *assetModels = [NSMutableArray array];
    NSMutableArray *targetArray = [NSMutableArray array];
    [messages enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(DCMessageContent * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.message_type==2 && obj.msgSentStatus != DC_SentStatus_SENDING) {
            if (obj.extra.type==1) {
                UIImage *image = [DCFileManager getMessageImage:obj.extra.path];
                if (image) {
                    HXCustomAssetModel *astModel = [HXCustomAssetModel assetWithLocalImage:image selected:YES];
                    [assetModels addObject:astModel];
                    [targetArray addObject:obj];
                }else if ([obj.extra.url hasPrefix:@"http"]){
                    HXCustomAssetModel *astModel = [HXCustomAssetModel assetWithNetworkImageURL:[NSURL URLWithString:obj.extra.url] selected:YES];
                    [assetModels addObject:astModel];
                    [targetArray addObject:obj];
                }
            }
            
            if (obj.extra.type==2) {
                NSString *fileName = [DCFileManager fileName:obj.extra.path];
                NSString *filePath = [[DCFileManager getMessageFileCachePath] stringByAppendingPathComponent:fileName];
                if ([DCFileManager isExistsAtPath:filePath] && ![DCTools isEmpty:fileName]) {
                    HXCustomAssetModel *astModel = [HXCustomAssetModel assetWithLocalVideoURL:[NSURL fileURLWithPath:filePath] selected:YES];
                    [assetModels addObject:astModel];
                    [targetArray addObject:obj];
                }else if ([obj.extra.url hasPrefix:@"http"]) {
                    HXCustomAssetModel *astModel = [HXCustomAssetModel assetWithNetworkVideoURL:[NSURL URLWithString:obj.extra.url] videoCoverURL:[NSURL URLWithString:obj.extra.cover] videoDuration:obj.extra.duration selected:YES];
                    [assetModels addObject:astModel];
                    [targetArray addObject:obj];
                }
            }
        }
    }];
    
    NSInteger selIdx = [targetArray indexOfObject:model];
    
    HXPhotoManager *manager = [HXPhotoManager managerWithType:HXPhotoManagerSelectedTypePhotoAndVideo];
    manager.configuration.videoAutoPlayType = HXVideoAutoPlayTypeAll;
    manager.configuration.selectTogether = YES;
    manager.configuration.saveSystemAblum = YES;
    manager.configuration.photoMaxNum = 0;
    manager.configuration.videoMaxNum = 0;
    
    manager.configuration.customPreviewFromView = ^UIView *(NSInteger currentIndex) {
        return complete(targetArray[currentIndex]);
    };
    manager.configuration.customPreviewToView = ^UIView *(NSInteger currentIndex) {
        return complete(targetArray[currentIndex]);
    };
    manager.configuration.customPreviewFromImage = ^UIImage *(NSInteger currentIndex) {
        if ([complete(targetArray[currentIndex]) isKindOfClass:[UIImageView class]]) {
            return ((UIImageView *)complete(targetArray[currentIndex])).image;
        }
        return nil;
    };
    manager.configuration.customPreviewFromRect = ^CGRect(NSInteger currentIndex) {
        return complete(targetArray[currentIndex]).frame;
    };
    manager.configuration.previewRespondsToLongPress = ^(UILongPressGestureRecognizer *longPress, HXPhotoModel *photoModel, HXPhotoManager *manager, HXPhotoPreviewViewController *previewViewController) {
        NSLog(@"%ld",previewViewController.currentModelIndex);
//        [[DCTools topViewController] presentViewController:[DCTools actionSheet:@[@"保存到相册"] complete:^(int idx) {
//            NSLog(@"%d",idx);
//            HXCustomAssetModel *customModel = assetModels.firstObject;
//            UIImageWriteToSavedPhotosAlbum(customModel.localImage, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
//        }] animated:YES completion:nil];
    };
    [manager addCustomAssetModel:assetModels];
    
    [[DCTools topViewController] hx_presentPreviewPhotoControllerWithManager:manager previewStyle:HXPhotoViewPreViewShowStyleDark showBottomPageControl:YES currentIndex:selIdx];
}

//保存视频完成之后的回调
- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    NSString *msg = nil ;
    if(error){
        msg = @"保存失败" ;
    }else{
        msg = @"保存成功" ;
    }
    [MBProgressHUD showTips:msg];
  
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    NSString *msg = nil ;
    if(error){
        msg = @"保存失败" ;
    }else{
        msg = @"保存成功" ;
    }
    [MBProgressHUD showTips:msg];
}


- (void)showPreview:(NSArray<DCMessageContent *>*)messages selectModel:(DCMessageContent*)model compele:(UIView*(^)(DCMessageContent * curModel))complete {
    NSMutableArray *assetModels = [NSMutableArray array];
    NSMutableArray *targetArray = [NSMutableArray array];
    [messages enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(DCMessageContent * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.message_type==2) {
            if (obj.extra.type==1) {
                NSString *filePath = [DCFileManager getFilePath:obj.extra.path];
                
                if ([DCFileManager isExistsAtPath:filePath]) {
                    YBIBImageData *data = [YBIBImageData new];
                    data.imagePath = filePath;
                    data.projectiveView = complete(obj);
                    [assetModels addObject:data];
                    [targetArray addObject:obj];
                }else if ([obj.extra.url hasPrefix:@"http"]){
                    YBIBImageData *data = [YBIBImageData new];
                    data.imageURL = [NSURL URLWithString:obj.extra.url];
                    data.projectiveView = complete(obj);
                    [assetModels addObject:data];
                    [targetArray addObject:obj];
                }
            }
            
            if (obj.extra.type==2) {
                NSString *fileName = [DCFileManager fileName:obj.extra.path];
                NSString *filePath = [[DCFileManager getMessageFileCachePath] stringByAppendingPathComponent:fileName];
                if ([DCFileManager isExistsAtPath:filePath] && ![DCTools isEmpty:fileName]) {
                    YBIBVideoData *data = [YBIBVideoData new];
                    data.videoURL = [NSURL fileURLWithPath:filePath];
                    data.projectiveView = complete(obj);
                    [assetModels addObject:data];
                    [targetArray addObject:obj];
                }else if ([obj.extra.url hasPrefix:@"http"]) {
                    YBIBVideoData *data = [YBIBVideoData new];
                    data.videoURL = [NSURL URLWithString:obj.extra.url];
                    data.projectiveView = complete(obj);
                    [assetModels addObject:data];
                    [targetArray addObject:obj];
                }
            }
        }
    }];
    
    NSInteger selIdx = [targetArray indexOfObject:model];
    
    YBImageBrowser *browser = [YBImageBrowser new];
    browser.dataSourceArray = assetModels;
    browser.currentPage = selIdx;
    browser.delegate = self;
    browser.defaultToolViewHandler.topView.operationType = YBIBTopViewOperationTypeSave;
    [browser showToView:[UIApplication sharedApplication].keyWindow.rootViewController.view];
    
}
- (void)yb_imageBrowser:(YBImageBrowser *)imageBrowser respondsToLongPressWithData:(id<YBIBDataProtocol>)data {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *saveAction = [UIAlertAction actionWithTitle:@"保存到相册" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [data yb_saveToPhotoAlbum];
    }];
    [saveAction setValue:kMainColor forKey:@"_titleTextColor"];
    [alert addAction:saveAction];
    
    if ([data isKindOfClass:[YBIBImageData class]]) {
        YBIBImageData *imgData = (YBIBImageData *)data;
        CIContext *context = [[CIContext alloc] init];
        //创建探测器
        CIDetector *QRCodeDetector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:context options:@{CIDetectorAccuracy: CIDetectorAccuracyLow}];
        //识别图片，获取特征
        CIImage *imgCI = [[CIImage alloc] initWithImage:imgData.originImage];
        NSArray *features = [QRCodeDetector featuresInImage:imgCI];
        
        //判断是否识别到二维码
        if (features.count > 0) {
            CIQRCodeFeature *qrcodeFeature = (CIQRCodeFeature *)features[0];
            __weak typeof(self) weakSelf = self;
            NSString *result = qrcodeFeature.messageString;
            
            UIAlertAction *identifiedAction = [UIAlertAction actionWithTitle:@"识别图中二维码" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
                NSDictionary *parms = [DCTools dictionaryWithJsonString:result];
                if ([parms[@"appName"] isEqualToString:kAppName]) {
                    if ([parms[@"type"] intValue] == 1) {
                        DCUserInfoVC *vc = [[DCUserInfoVC alloc]init];
                        vc.toUid = [NSString stringWithFormat:@"%@",parms[@"uid"]];
                        [[DCTools navigationViewController] pushViewController:vc animated:YES];
                    }else if ([parms[@"type"] intValue]==2) {
                        [weakSelf showGroupInvited:parms];
                    }
                }else {
                    [MBProgressHUD showTips:@"未识别出结果"];
                }
            }];
            [identifiedAction setValue:kMainColor forKey:@"_titleTextColor"];
            [alert addAction:identifiedAction];
        }
    }
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [cancel setValue:kTextSubColor forKey:@"_titleTextColor"];
    [alert addAction:cancel];
    
    [[DCTools topViewController] presentViewController:alert animated:YES completion:nil];
}

- (void)showGroupInvited:(NSDictionary *)parms {
    NSString *groupId = parms[@"groupId"];
    NSString *inviteId = parms[@"uid"];
    NSString *groupName = parms[@"groupName"];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"群邀请" message:[NSString stringWithFormat:@"邀请您加入群聊： %@ 是否确认加入",groupName] preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *sure = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSDictionary *dict = @{@"id":groupId , @"invite_id":inviteId};
        [[DCRequestManager sharedManager] requestWithMethod:@"POST" url:@"api/scanGroup" parameters:dict success:^(id  _Nullable result) {
            [MBProgressHUD showTips:@"加入群聊成功"];
            
        } failure:^(NSError * _Nonnull error) {
            
        }];
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [cancel setValue:kTextSubColor forKey:@"_titleTextColor"];
    [sure setValue:kMainColor forKey:@"_titleTextColor"];
    [alert addAction:sure];
    [alert addAction:cancel];
    
    [[DCTools topViewController] presentViewController:alert animated:YES completion:nil];
}

@end
