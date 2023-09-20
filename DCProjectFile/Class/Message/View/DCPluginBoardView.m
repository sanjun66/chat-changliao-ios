//
//  DCPluginBoardView.m
//  DCProjectFile
//
//  Created  on 2023/6/13.
//

#import "DCPluginBoardView.h"
#import "DCDragViewController.h"
#import "DCMessagePswInputAlert.h"
#define kPluginBoardTitle @"kPluginBoardTitle"
#define kPluginBoardImage @"kPluginBoardImage"

@interface DCPluginBoardView ()<UICollectionViewDelegate,UICollectionViewDataSource,UIDocumentPickerDelegate>
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) UIDocumentPickerViewController *documentPickerVC;
@property (nonatomic, strong) NSDictionary *callParms;
@property (nonatomic, assign) NSInteger handleIndex;
@property (nonatomic, strong) NSArray *selectModels;
@end

@implementation DCPluginBoardView
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.dataArray = [NSMutableArray arrayWithObjects:
                          @{kPluginBoardTitle:@"图片" , kPluginBoardImage:@"ic_ctype_image"},
                          @{kPluginBoardTitle:@"视频" , kPluginBoardImage:@"ic_ctype_video"},
                          @{kPluginBoardTitle:@"文件" , kPluginBoardImage:@"ic_ctype_file"},
                          nil];
        self.callParms = @{kPluginBoardTitle:@"视频通话" , kPluginBoardImage:@"ic_ctype_location"};
        [self setupCollectionView];
    }
    return self;
}
- (void)setConversationType:(DCConversationType)conversationType {
    _conversationType = conversationType;
    if (self.conversationType==ConversationType_PRIVATE) {
        [self.dataArray addObject:self.callParms];
        [self.collectionView reloadData];
    }
}

- (void)setGroupModel:(DCGroupDataModel *)groupModel {
    _groupModel = groupModel;
    if (!groupModel.group_info.audio) {
        if ([self.dataArray containsObject:self.callParms]) {
            [self.dataArray removeObject:self.callParms];
            [self.collectionView reloadData];
        }
        
    }else {
        if (![self.dataArray containsObject:self.callParms]) {
            [self.dataArray addObject:self.callParms];
            [self.collectionView reloadData];
        }
    }
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    DCPluginBoardCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([DCPluginBoardCell class]) forIndexPath:indexPath];
    cell.itemData = self.dataArray[indexPath.row];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *item = self.dataArray[indexPath.row];
    NSString *indexTitle = item[kPluginBoardTitle];
    if ([indexTitle isEqualToString:@"图片"]) {
        HXPhotoManager *manager = [DCTools photoManager:9 isVideo:NO];
        [manager clearSelectedList];
        [[DCTools topViewController] hx_presentSelectPhotoControllerWithManager:manager didDone:^(NSArray<HXPhotoModel *> * _Nullable allList, NSArray<HXPhotoModel *> * _Nullable photoList, NSArray<HXPhotoModel *> * _Nullable videoList, BOOL isOriginal, UIViewController * _Nullable viewController, HXPhotoManager * _Nullable manager) {
            self.handleIndex = 0;
            self.selectModels = photoList;
            [self getImageData:photoList.firstObject];
            
        } cancel:^(UIViewController * _Nullable viewController, HXPhotoManager * _Nullable manager) {
            
        }];
    }
    
    if ([indexTitle isEqualToString:@"视频"]){
        HXPhotoManager *manager = [DCTools photoManager:1 isVideo:YES];
        [manager clearSelectedList];
        [[DCTools topViewController] hx_presentSelectPhotoControllerWithManager:manager didDone:^(NSArray<HXPhotoModel *> * _Nullable allList, NSArray<HXPhotoModel *> * _Nullable photoList, NSArray<HXPhotoModel *> * _Nullable videoList, BOOL isOriginal, UIViewController * _Nullable viewController, HXPhotoManager * _Nullable manager) {
            HXPhotoModel *model = videoList.firstObject;
            //            if (model.assetByte / (1024*1024) > 10) {
            //                [MBProgressHUD showTips:@"视频不能超过10MB"];
            //                return;
            //            }
            
            BOOL isOk = NO;
            if (model.videoURL) {
                [self saveVideoCoverImg:model];
                isOk = [self moveItemAt:model.videoURL videoDuration:model.videoDuration thumbPhoto:model.thumbPhoto];
                
            }
            if (!isOk || !model.videoURL) {
                [self exportSelectVideo:model];
            }
        } cancel:^(UIViewController * _Nullable viewController, HXPhotoManager * _Nullable manager) {
            
        }];
    }
    
    if ([indexTitle isEqualToString:@"文件"]) {
        [[DCTools topViewController] presentViewController:self.documentPickerVC animated:YES completion:nil];
    }
    
    if ([indexTitle isEqualToString:@"视频通话"]) {
        if (self.conversationType==DC_ConversationType_GROUP) {
            if (self.groupModel.group_info.audio&&self.groupModel.group_info.is_audio) {
                UIViewController *alert = [DCTools actionSheet:@[@"视频通话",@"语音通话"] complete:^(int idx) {
                    if ([self.delegate respondsToSelector:@selector(pluginBoardViewMakeCall:)]) {
                        [self.delegate pluginBoardViewMakeCall:(idx==0)?QBRTCConferenceTypeVideo:QBRTCConferenceTypeAudio];
                    }
                }];
                
                [[DCTools topViewController] presentViewController:alert animated:YES completion:nil];
            }else {
                [MBProgressHUD showTips:@"不允许群通话"];
            }
            
        }
        
        if (self.conversationType==DC_ConversationType_PRIVATE) {
            UIViewController *alert = [DCTools actionSheet:@[@"视频通话",@"语音通话"] complete:^(int idx) {
                if ([self.delegate respondsToSelector:@selector(pluginBoardViewMakeCall:)]) {
                    [self.delegate pluginBoardViewMakeCall:(idx==0)?QBRTCConferenceTypeVideo:QBRTCConferenceTypeAudio];
                }
            }];
            
            [[DCTools topViewController] presentViewController:alert animated:YES completion:nil];
        }
    }
}
- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentsAtURLs:(NSArray <NSURL *>*)urls {
    NSURL *url = urls.firstObject;
     BOOL canAccessingResource = [url startAccessingSecurityScopedResource];
     if(canAccessingResource) {
         NSFileCoordinator *fileCoordinator = [[NSFileCoordinator alloc] init];
         NSError *error;
         [fileCoordinator coordinateReadingItemAtURL:url options:0 error:&error byAccessor:^(NSURL *newURL) {
             NSString *fileName = [newURL lastPathComponent];
             NSData *fileData = [NSData dataWithContentsOfURL:newURL];
             NSString *filePath = [DCFileManager saveMessageFile:fileData fileName:fileName];
             [[DCSocketClient sharedInstance]createFileMsg:self.targetId localPath:filePath size:fileData.length];
             [[DCTools topViewController] dismissViewControllerAnimated:YES completion:NULL];
         }];
         if (error) {
             // error handing
         }
     } else {
         // startAccessingSecurityScopedResource fail
     }
     [url stopAccessingSecurityScopedResource];
}
- (UIDocumentPickerViewController *)documentPickerVC {
    if (!_documentPickerVC) {
        self.documentPickerVC = [[UIDocumentPickerViewController alloc] initWithDocumentTypes:@[@"public.content"] inMode:UIDocumentPickerModeOpen];
        _documentPickerVC.delegate = self;
        _documentPickerVC.modalPresentationStyle = UIModalPresentationFormSheet; //设置模态弹出方式
    }
    return _documentPickerVC;
}

// 导出视频
- (void)exportSelectVideo:(HXPhotoModel *)model {
    
    [model exportVideoWithPresetName:nil startRequestICloud:nil iCloudProgressHandler:nil exportProgressHandler:nil success:^(NSURL * _Nullable videoURL, HXPhotoModel * _Nullable model) {
        [self moveItemAt:videoURL videoDuration:model.videoDuration thumbPhoto:model.thumbPhoto];
        [self saveVideoCoverImg:model];
    } failed:^(NSDictionary * _Nullable info, HXPhotoModel * _Nullable model) {
        
    }];
}
// 保存封面
- (void)saveVideoCoverImg:(HXPhotoModel *)model {
    if (model.thumbPhoto) {
        NSString *fileName = [model.videoURL.absoluteString componentsSeparatedByString:@"/"].lastObject;
        NSString *name = [fileName componentsSeparatedByString:@"."].firstObject;
        UIImage *targetImage = [UIImage imageCompressForWidth:model.thumbPhoto targetWidth:120];
        NSData *data = [UIImage lubanCompressImage:targetImage];
        [DCFileManager saveMessageFile:data fileName:[NSString stringWithFormat:@"%@.png",name]];
    }
}
- (BOOL)moveItemAt:(NSURL *)videoURL videoDuration:(int)duration thumbPhoto:(UIImage *)thumbPhoto {
    if (!videoURL) {return NO;}
    AVURLAsset  *asset = [AVURLAsset assetWithURL:videoURL];
    NSArray *array = asset.tracks;
    CGSize videoSize = CGSizeZero;
    for(AVAssetTrack  *track in array){
        if([track.mediaType isEqualToString:AVMediaTypeVideo]){
            videoSize = track.naturalSize;
        }
    }
    if (videoSize.width == 0 || videoSize.height == 0) {
        videoSize = CGSizeMake(120, 140);
    }
    NSString *fileName = [videoURL.absoluteString componentsSeparatedByString:@"/"].lastObject;
    NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:fileName];
    NSString *toPath = [[DCFileManager getMessageFileCachePath] stringByAppendingPathComponent:fileName];
    BOOL isOk = [DCFileManager moveItemAtPath:path toPath:toPath overwrite:YES error:nil];
    
    if (isOk) {
        [[DCSocketClient sharedInstance] createVideoMsg:self.targetId localPath:toPath videoSize:videoSize duration:duration thumbPhoto:thumbPhoto];
    }
    return isOk;
}

- (void) getImageData:(HXPhotoModel *)model {
    
    [model getImageWithSuccess:^(UIImage * _Nullable image, HXPhotoModel * _Nullable model, NSDictionary * _Nullable info) {
        [[DCSocketClient sharedInstance] createImageMsg:self.targetId image:image];
        self.handleIndex += 1;
        if (self.handleIndex < self.selectModels.count) {
            [self getImageData:[self.selectModels objectAtIndex:self.handleIndex]];
        }
        
    } failed:^(NSDictionary * _Nullable info, HXPhotoModel * _Nullable model) {
        self.handleIndex += 1;
        if (self.handleIndex < self.selectModels.count) {
            [self getImageData:[self.selectModels objectAtIndex:self.handleIndex]];
        }
    }];
}

- (void)setupCollectionView {
    CGFloat margin = (kScreenWidth-60*4)/5;
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc]init];
    flowLayout.itemSize = CGSizeMake(60, 90);
    flowLayout.minimumLineSpacing = 10;
    flowLayout.minimumInteritemSpacing = margin;
    flowLayout.sectionInset = UIEdgeInsetsMake(0, margin, 0, margin);
    flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    
    self.collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 10, kScreenWidth, 190) collectionViewLayout:flowLayout];
    self.collectionView.backgroundColor = UIColor.clearColor;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.showsVerticalScrollIndicator = NO;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self.collectionView registerClass:[DCPluginBoardCell class] forCellWithReuseIdentifier:NSStringFromClass([DCPluginBoardCell class])];
    
    [self addSubview:self.collectionView];
    
//    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(margin, 180, kScreenWidth-margin*2, 0.5)];
//    line.backgroundColor = HEX(@"#E8F4F9");
//    [self addSubview:line];
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(margin, 200, 90, 40)];
    label.text = @"密聊模式";
    label.font = kNameSize(@"PingFangSC-Medium", 14);
    label.textColor = kMainColor;
    [self addSubview:label];
    
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(kScreenWidth-margin-70, 200, 70, 40);
    [button setImage:[UIImage imageNamed:@"msg_secret_close"] forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:@"msg_secret_open"] forState:UIControlStateSelected];
    [button addTarget:self action:@selector(changeSecretType:) forControlEvents:UIControlEventTouchUpInside];
    button.selected = ![DCTools isEmpty:[DCSocketClient sharedInstance].secretPsw];
    [self addSubview:button];
}
- (void)changeSecretType:(UIButton *)sender {
    if (sender.isSelected) {
        sender.selected = NO;
        [DCSocketClient sharedInstance].secretPsw = nil;
        return;
    }
    if ([self.delegate respondsToSelector:@selector(pluginBoardViewWillInput)]) {
        [self.delegate pluginBoardViewWillInput];
    }
    DCMessagePswInputAlert *alert = [DCMessagePswInputAlert xib];
    alert.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
    [[UIApplication sharedApplication].keyWindow.rootViewController.view addSubview:alert];
    [DCTools animationForView:alert.backView];
    [alert.sectetField becomeFirstResponder];
    alert.inputAlertComplete = ^(NSString * _Nullable text) {
        if (nil!=text) {
            [DCSocketClient sharedInstance].secretPsw = text;
            sender.selected = YES;
        }
        [self.delegate pluginBoardViewDidEndInput];
    };
}
- (void)switchViewSecret:(UISwitch*)switchView {
    
    
}
@end




@interface DCPluginBoardCell ()
@property (nonatomic, strong) UIImageView *iconImg;
@property (nonatomic, strong) UILabel *descLabel;
@end

@implementation DCPluginBoardCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        UIView *backView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 60, 60)];
        backView.backgroundColor = kWhiteColor;
        backView.layer.cornerRadius = 15;
        backView.layer.masksToBounds = YES;
        [self.contentView addSubview:backView];
        
        [self.contentView addSubview:self.iconImg];
        [self.contentView addSubview:self.descLabel];
    }
    return self;
}

- (void)setItemData:(NSDictionary *)itemData {
    _itemData = itemData;
    self.iconImg.image = [UIImage imageNamed:itemData[kPluginBoardImage]];
    self.descLabel.text = itemData[kPluginBoardTitle];
}

- (UIImageView *)iconImg {
    if (!_iconImg) {
        _iconImg = [[UIImageView alloc]initWithFrame:CGRectMake(10, 10, 40, 40)];
    }
    return _iconImg;
}

- (UILabel *)descLabel {
    if (!_descLabel) {
        _descLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 60, 60, 30)];
        _descLabel.font = kNameSize(@"PingFangSC-Medium", 13);
        _descLabel.textColor = kTextTitColor;
        _descLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _descLabel;
}

@end
