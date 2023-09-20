//
//  DCMsgForwardListVC.m
//  DCProjectFile
//
//  Created  on 2023/9/7.
//

#import "DCMsgForwardListVC.h"
#import "DCForwardMsgBaseCell.h"


#define kExtraHeight 48

#define kMsgContentWidth (kScreenWidth-82)
@interface DCMsgForwardListVC ()<UITableViewDelegate,UITableViewDataSource,DCForwardMsgBaseCellDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) DCMessageContent *currentSelectedModel;
@property (nonatomic, strong) UIDocumentInteractionController * document;
@end

@implementation DCMsgForwardListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupNavTitle];
    [self.tableView registerNib:[UINib nibWithNibName:@"DCForwardMsgBaseCell" bundle:nil] forCellReuseIdentifier:@"DCForwardMsgBaseCell"];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.model.extra.talk_list.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DCForwardMsgBaseCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DCForwardMsgBaseCell" forIndexPath:indexPath];
    cell.model = self.model.extra.talk_list[indexPath.row];
    cell.delegate = self;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    DCMessageContent *msg = self.model.extra.talk_list[indexPath.row];
    if (msg.cellSize.height > 0) {
        return msg.cellSize.height;
    }
    
    CGFloat cellHeight = 0;
    
    if (msg.message_type==2 && (msg.extra.type==2 || msg.extra.type==3)) {
        cellHeight = 98;
    }
    
    if (msg.message_type==1) {
        cellHeight = [self textSize:msg.message].height + kExtraHeight;
        
    }
    
    if (msg.message_type==2 && msg.extra.type==1) {
        if (msg.extra.weight > kMsgContentWidth) {
            cellHeight = msg.extra.height * kMsgContentWidth / msg.extra.weight + kExtraHeight;
        }else {
            cellHeight = msg.extra.height + kExtraHeight;
        }
    }
    msg.cellSize = CGSizeMake(kScreenWidth, cellHeight);
    
    return cellHeight;
}


- (void)didTapMessageCell:(DCMessageContent *)model {
    // 文本消息无点击
    if (model.message_type==1) {return;}
    // 图片视频预览，文件跳转，语音播放
    if (model.message_type==2) {
        if (model.extra.type==1) {
            [self didTapVideoImageMessage:model];
        }else if (model.extra.type==2) {
            [self didTapVideoImageMessage:model];
        }else if (model.extra.type==3) {
            [self didTapFileMsg:model];
        }
    }
}

// 预览图片视频
- (void)didTapVideoImageMessage:(DCMessageContent *)model {
    [[DCPreviewPhotoManager sharedManager] showPreview:[self.model.extra.talk_list reverseObjectEnumerator].allObjects selectModel:model compele:^UIView * _Nonnull(DCMessageContent * _Nonnull curModel) {
        return nil;
    }];
}

// 点击文件消息
- (void)didTapFileMsg:(DCMessageContent *)model {
    if (model.msgSentStatus == DC_SentStatus_SENDING) {return;}
    NSString *fileName = [DCFileManager fileName:model.extra.path];
    NSString *filePath = [[DCFileManager getMessageFileCachePath] stringByAppendingPathComponent:fileName];
    
    if ([DCFileManager isExistsAtPath:filePath]) {
        DCWebKitVC *wVc = [[DCWebKitVC alloc]init];
        wVc.titleStr = [model.extra.path lastPathComponent];
        wVc.localPath = filePath;
        [self.navigationController pushViewController:wVc animated:YES];
    }else {
        [MBProgressHUD showActivity];
        [[DCRequestManager sharedManager] downloadWithUrl:model.extra.url filePath:filePath success:^(id  _Nullable result) {
            [MBProgressHUD hideActivity];
            DCWebKitVC *wVc = [[DCWebKitVC alloc]init];
            wVc.titleStr = [model.extra.path lastPathComponent];
            wVc.localPath = filePath;
            [[DCTools navigationViewController] pushViewController:wVc animated:YES];
        }];
    }
}


- (void)didLongTouchMessageCell:(DCMessageContent *)model inView:(UIView *)view {
    
    UIMenuItem *copyItem = [[UIMenuItem alloc] initWithTitle:@"复制文字"
                                                      action:@selector(onCopyMessage:)];
    NSMutableArray *items = [NSMutableArray array];
    
    if (model.message_type == 1) {
        [items addObject:copyItem];
    }
    
    if (model.extra.type==3) {
        UIMenuItem *saveItem =
            [[UIMenuItem alloc] initWithTitle:@"保存到文件"
                                       action:@selector(onSaveMessageFile:)];
        [items addObject:saveItem];
    }
    
    
    self.currentSelectedModel = model;
    
    CGRect rect = [self.view convertRect:view.frame fromView:view.superview];

    UIMenuController *menu = [UIMenuController sharedMenuController];
    [menu setMenuItems:items];
    if (@available(iOS 13.0, *)) {
        [menu showMenuFromView:self.view rect:rect];
    } else {
        [menu setTargetRect:rect inView:self.view];
        [menu setMenuVisible:YES animated:YES];
    }
    
}

//复制消息内容
- (void)onCopyMessage:(id)sender {
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    [pasteboard setString:self.currentSelectedModel.message];
}

// 文件消息分享
- (void)onSaveMessageFile:(id)sender {
    NSString *fileName = [DCFileManager fileName:self.currentSelectedModel.extra.path];
    NSString *filePath = [[DCFileManager getMessageFileCachePath] stringByAppendingPathComponent:fileName];
    if ([DCFileManager isExistsAtPath:filePath]) {
        [self showShareAlert:filePath];
    }else {
        [MBProgressHUD showActivity];
        [[DCRequestManager sharedManager] downloadWithUrl:self.currentSelectedModel.extra.url filePath:filePath success:^(id  _Nullable result) {
            [MBProgressHUD hideActivity];
            [self onSaveMessageFile:nil];
        }];
    }
    
}

- (void)showShareAlert:(NSString *)filePath {
    NSURL *urlPath = [NSURL fileURLWithPath:filePath];
    _document = [UIDocumentInteractionController interactionControllerWithURL:urlPath];
    _document.delegate =  (id)self;
    [_document presentOpenInMenuFromRect:self.view.bounds inView:self.view animated:YES];
}
- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller {
    return self;
}



- (CGSize)textSize:(NSString *)text {
    CGSize size = [text textSizeIn:CGSizeMake(kMsgContentWidth, CGFLOAT_MAX) font:[UIFont systemFontOfSize:kTextFontSize]];
    
    return CGSizeMake(ceilf(size.width), ceilf(size.height));
}
- (void)setupNavTitle {
    if (self.model.extra.talk_type==2) {
        self.navigationItem.title = @"群聊的聊天记录";
    }else {
        DCMessageContent *fMsg = self.model.extra.talk_list.firstObject;        
        [[DCUserManager sharedManager] getConversationData:DC_ConversationType_PRIVATE targerId:fMsg.from_uid completion:^(DCUserInfo * _Nonnull userInfo) {
            NSString *fromName = userInfo.name;
            [[DCUserManager sharedManager] getConversationData:DC_ConversationType_PRIVATE targerId:fMsg.to_uid completion:^(DCUserInfo * _Nonnull userInfo) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.navigationItem.title = [NSString stringWithFormat:@"%@和%@的聊天记录",fromName , userInfo.name];
                });
            }];
            
        }];
    }
}
@end
