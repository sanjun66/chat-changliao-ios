//
//  SCQRCodeVC.m
//  yunbaolive
//
//  Created by mac on 2020/7/16.
//  Copyright © 2020 cat. All rights reserved.
//

#import "SCQRCodeVC.h"
#import "SGQRCode.h"
#import "DCUserInfoVC.h"

@interface SCQRCodeVC ()
{
    SGQRCodeObtain *obtain;
}
@property (nonatomic, strong) SGQRCodeScanView *scanView;
@property (nonatomic, strong) UILabel *promptLabel;
@property (nonatomic, assign) BOOL stop;
@end

@implementation SCQRCodeVC

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    if (_stop) {
        [obtain startRunningWithBefore:nil completion:nil];
    }
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.scanView addTimer];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.scanView removeTimer];
}

- (void)dealloc {
    NSLog(@"WBQRCodeVC - dealloc");
    [self removeScanningView];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = HEX(@"#1E1E28");
    [self setupNavigationBar];
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (status == AVAuthorizationStatusRestricted || status == AVAuthorizationStatusDenied)
    {
        // 弹框
        UIAlertController *alertC=[UIAlertController alertControllerWithTitle:@"需要开启摄像头权限和开关" message:nil preferredStyle:UIAlertControllerStyleAlert];
        [alertC addAction:[UIAlertAction actionWithTitle:@"忽略" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [self.navigationController popViewControllerAnimated:YES];
        }]];
        [alertC addAction:[UIAlertAction actionWithTitle:@"马上去设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:^(BOOL success) {
            }];
            
        }]];
        
        //弹出提示框
        [self presentViewController:alertC animated:YES completion:nil];
    }else {
        obtain = [SGQRCodeObtain QRCodeObtain];
        [self setupQRCodeScan];
        [self.view addSubview:self.scanView];
        [self.view addSubview:self.promptLabel];
    }
    
}
- (void)setupQRCodeScan {
    __weak typeof(self) weakSelf = self;

    SGQRCodeObtainConfigure *configure = [SGQRCodeObtainConfigure QRCodeObtainConfigure];
    configure.openLog = YES;
    configure.rectOfInterest = CGRectMake(0.05, 0.2, 0.7, 0.6);
    // 这里只是提供了几种作为参考（共：13）；需什么类型添加什么类型即可
    NSArray *arr = @[AVMetadataObjectTypeQRCode, AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode128Code];
    configure.metadataObjectTypes = arr;
    
    [obtain establishQRCodeObtainScanWithController:self configure:configure];
    [obtain startRunningWithBefore:^{
        [MBProgressHUD showActivityWithMessage:@"正在加载..."];
    } completion:^{
        [MBProgressHUD hideActivity];
    }];
    __weak typeof(self) ws = self;
    
    [obtain setBlockWithQRCodeObtainScanResult:^(SGQRCodeObtain *obtain, NSString *result) {
        if (result) {
            [obtain stopRunning];
            weakSelf.stop = YES;
            [obtain playSoundName:@"SGQRCode.bundle/sound.caf"];
            if (weakSelf.scanBlock) {
                weakSelf.scanBlock(result);
                [weakSelf.navigationController popViewControllerAnimated:YES];
                return;
            }
            NSDictionary *parms = [DCTools dictionaryWithJsonString:result];
            if ([parms[@"appName"] isEqualToString:kAppName]) {
                if ([parms[@"type"] intValue] == 1) {
                    DCUserInfoVC *vc = [[DCUserInfoVC alloc]init];
                    vc.toUid = [NSString stringWithFormat:@"%@",parms[@"uid"]];
                    [ws.navigationController pushViewController:vc animated:YES];
                }else if ([parms[@"type"] intValue]==2) {
                    [ws showGroupInvited:parms];
                }
            }else {
                [MBProgressHUD showTips:@"未识别出结果"];
                [ws.navigationController popViewControllerAnimated:YES];
            }
        }
    }];
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
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.navigationController popToRootViewControllerAnimated:YES];
            });
        } failure:^(NSError * _Nonnull error) {
            
        }];
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [cancel setValue:kTextSubColor forKey:@"_titleTextColor"];
    [sure setValue:kMainColor forKey:@"_titleTextColor"];
    [alert addAction:sure];
    [alert addAction:cancel];
    
    [self presentViewController:alert animated:YES completion:nil];
}
- (void)setupNavigationBar {
    
    self.navigationItem.title = @"扫一扫";
    
    UIButton *right = [UIButton buttonWithType:UIButtonTypeCustom];
    [right setTitle:@"相册" forState:0];
    [right setTitleColor:kMainColor forState:0];
    right.titleLabel.font = kFontSize(15);
    [right addTarget:self action:@selector(rightBarButtonItenAction) forControlEvents:UIControlEventTouchUpInside];
    [right sizeToFit];
    UIBarButtonItem *rightitem = [[UIBarButtonItem alloc]initWithCustomView:right];
    self.navigationItem.rightBarButtonItem = rightitem;
}
- (void)rightBarButtonItenAction {
    __weak typeof(self) weakSelf = self;

    [obtain establishAuthorizationQRCodeObtainAlbumWithController:nil];
    if (obtain.isPHAuthorization == YES) {
        [self.scanView removeTimer];
    }
    [obtain setBlockWithQRCodeObtainAlbumDidCancelImagePickerController:^(SGQRCodeObtain *obtain) {
        [weakSelf.view addSubview:weakSelf.scanView];
    }];
    __weak typeof(self) ws = self;
    [obtain setBlockWithQRCodeObtainAlbumResult:^(SGQRCodeObtain *obtain, NSString *result) {
        if (result == nil) {
            NSLog(@"暂未识别出二维码");
        } else {
            if (weakSelf.scanBlock) {
                weakSelf.scanBlock(result);
                [weakSelf.navigationController popViewControllerAnimated:YES];
                return;
            }
            NSDictionary *parms = [DCTools dictionaryWithJsonString:result];
            if ([parms[@"appName"] isEqualToString:kAppName]) {
                if ([parms[@"type"] intValue] == 1) {
                    DCUserInfoVC *vc = [[DCUserInfoVC alloc]init];
                    vc.toUid = [NSString stringWithFormat:@"%@",parms[@"uid"]];
                    [ws.navigationController pushViewController:vc animated:YES];
                }else if ([parms[@"type"] intValue]==2) {
                    [ws showGroupInvited:parms];
                }
                
            }else {
                [MBProgressHUD showTips:@"未识别出结果"];
                [ws.navigationController popViewControllerAnimated:YES];
            }
        }
    }];
}

- (SGQRCodeScanView *)scanView {
    if (!_scanView) {
        _scanView = [[SGQRCodeScanView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        // 静态库加载 bundle 里面的资源使用 SGQRCode.bundle/QRCodeScanLineGrid
        // 动态库加载直接使用 QRCodeScanLineGrid
        _scanView.scanImageName = @"SGQRCode.bundle/QRCodeScanLine";
        _scanView.scanAnimationStyle = ScanAnimationStyleDefault;
        _scanView.cornerLocation = CornerLoactionOutside;
        _scanView.cornerColor = kMainColor;
    }
    return _scanView;
}
- (void)removeScanningView {
    [self.scanView removeTimer];
    [self.scanView removeFromSuperview];
    self.scanView = nil;
}

- (UILabel *)promptLabel {
    if (!_promptLabel) {
        _promptLabel = [[UILabel alloc] init];
        _promptLabel.backgroundColor = [UIColor clearColor];
        CGFloat promptLabelX = 0;
        CGFloat promptLabelY = 0.73 * self.view.frame.size.height-kNavHeight;
        CGFloat promptLabelW = self.view.frame.size.width;
        CGFloat promptLabelH = 25;
        _promptLabel.frame = CGRectMake(promptLabelX, promptLabelY, promptLabelW, promptLabelH);
        _promptLabel.textAlignment = NSTextAlignmentCenter;
        _promptLabel.font = [UIFont boldSystemFontOfSize:13.0];
        _promptLabel.textColor = [[UIColor whiteColor] colorWithAlphaComponent:0.6];
        _promptLabel.text = @"将二维码/条码放入框内, 即可自动扫描";
    }
    return _promptLabel;
}
//MARK: 网络请求
- (void)networkWithResult:(NSString *)result {
    
}

@end

