//
//  DCSearchMsgResultVC.m
//  DCProjectFile
//
//  Created  on 2023/9/11.
//

#import "DCSearchMsgResultVC.h"
#import "DCSearchMessageCell.h"
#import "DCConversationListVC.h"

@interface DCSearchMsgResultVC ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation DCSearchMsgResultVC
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.title = @"聊天记录";
    
    [self.tableView registerNib:[UINib nibWithNibName:@"DCSearchMessageCell" bundle:nil] forCellReuseIdentifier:@"DCSearchMessageCell"];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.msgs.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DCSearchMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DCSearchMessageCell" forIndexPath:indexPath];
    cell.msg = self.msgs[indexPath.row];
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DCMessageContent *model = self.msgs[indexPath.row];
    [[DCMessageManager sharedManager] messageIndexOfObject:model complete:^(NSInteger idx) {
        DCConversationListVC *chatVc = [[DCConversationListVC alloc]initWithConversationType:model.conversationType targetId:model.targetId];
        if (idx >= 0) {
            chatVc.targetSelectModel = model;
            chatVc.targetMessageIndex = idx;
        }
        [self.navigationController pushViewController:chatVc animated:YES];
    }];
    
}

@end
