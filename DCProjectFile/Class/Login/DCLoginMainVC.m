//
//  DCLoginMainVC.m
//  DCProjectFile
//
//  Created  on 2023/5/17.
//

#import "DCLoginMainVC.h"
#import "DCLoginInputVC.h"
#import "DCRegisterVC.h"
@interface DCLoginMainVC ()
@property (weak, nonatomic) IBOutlet UIImageView *logoImage;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *logoMargin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *logoWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *logoHeight;

@property (strong, nonatomic) UIButton *checkBox;
@end

@implementation DCLoginMainVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.logoImage.image = [UIImage imageNamed:@"luanch_icon"];
    self.logoMargin.constant = 50;
    self.logoWidth.constant = 213;
    self.logoHeight.constant = 213;
}
- (IBAction)loginTypeSelcted:(UIButton *)sender {
    DCLoginInputVC *vc = [[DCLoginInputVC alloc]init];
    vc.isEmail = [[NSNumber numberWithInteger:sender.tag] boolValue];
    [self.navigationController pushViewController:vc animated:YES];

}
- (IBAction)registerAccount:(id)sender {
    [self presentViewController:[DCTools actionSheet:@[@"手机号",@"邮箱"] complete:^(int idx) {
        DCRegisterVC *vc = [[DCRegisterVC alloc]init];
        vc.isEmail = idx;
        [self.navigationController pushViewController:vc animated:YES];
    }] animated:YES completion:nil];

}


@end
