//
//  DCImageMessageProgressView.m
//  DCProjectFile
//
//  Created  on 2023/6/26.
//

#import "DCImageMessageProgressView.h"
#import "DCPieProgressView.h"
@interface DCImageMessageProgressView ()
@property (nonatomic, strong) DCPieProgressView *pView;

@end

@implementation DCImageMessageProgressView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.pView = [[DCPieProgressView alloc]initWithFrame:CGRectMake(0, 0, 48, 48)];
        self.pView.lineWidth = 0.5;
        self.pView.progressColor = [kWhiteColor colorWithAlphaComponent:0.8];
        self.pView.lineColor = kWhiteColor;
        [self addSubview:self.pView];
    }
    return self;
}
@end
