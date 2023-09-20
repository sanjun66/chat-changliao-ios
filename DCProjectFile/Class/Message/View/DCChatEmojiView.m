//
//  DCChatEmojiView.m
//  DCProjectFile
//
//  Created  on 2023/6/12.
//

#import "DCChatEmojiView.h"
#import "DCCollectionViewLayout.h"

#define RC_EMOJI_WIDTH 30
#define RC_EMOTIONTAB_SIZE_HEIGHT 42
#define RC_EMOTIONTAB_SIZE_WIDTH 42
#define RC_EMOTIONTAB_ICON_SIZE 25


@interface DCChatEmojiView ()<UICollectionViewDelegate,UICollectionViewDataSource>
@property (nonatomic, strong) NSArray *faceEmojiArray;
@property (nonatomic, assign) int emojiTotalPage;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UIView *botView;
@property (nonatomic, strong) UIPageControl *pageView;
@end

@implementation DCChatEmojiView
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = kBackgroundColor;
        NSString *resourcePath = [[NSBundle mainBundle] resourcePath];
        NSString *bundlePath = [resourcePath stringByAppendingPathComponent:@"Emoji.plist"];
        self.faceEmojiArray = [[NSArray alloc] initWithContentsOfFile:bundlePath];

        [self createSubview];
    }
    return self;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.faceEmojiArray.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    DCChatEmojiCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([DCChatEmojiCell class]) forIndexPath:indexPath];
    
    cell.emojiLabel.text = self.faceEmojiArray[indexPath.row];
    
    return cell;
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self.delegate emojiViewDidInputText:self.faceEmojiArray[indexPath.row]];
}

- (void)delText {
    [self.delegate emojiViewDidTapDelete];
}

- (void)didSendMessage:(UIButton *)sender {
    [self.delegate emojiViewDidSendMessage];
    sender.backgroundColor = [UIColor.whiteColor colorWithAlphaComponent:0.9];
}
- (void)createSubview {
//    DCCollectionViewLayout *flowLayout = [[DCCollectionViewLayout alloc]init];
//    flowLayout.itemSize = CGSizeMake(RC_EMOTIONTAB_SIZE_WIDTH, RC_EMOTIONTAB_SIZE_HEIGHT);
//    flowLayout.sectionInset = UIEdgeInsetsMake(0, 10, 0, 10);
//    flowLayout.minimumLineSpacing = 0;
//    flowLayout.minimumInteritemSpacing = 0;
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc]init];
    flowLayout.itemSize = CGSizeMake(RC_EMOTIONTAB_SIZE_WIDTH, RC_EMOTIONTAB_SIZE_HEIGHT);
    flowLayout.sectionInset = UIEdgeInsetsMake(0, 10, kBottomSafe+20, 10);
    flowLayout.minimumLineSpacing = 10;
    flowLayout.minimumInteritemSpacing = 10;
    flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    
    self.collectionView = [[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:flowLayout];
    self.collectionView.backgroundColor = UIColor.clearColor;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.showsVerticalScrollIndicator = NO;
//    self.collectionView.pagingEnabled = YES;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self.collectionView registerClass:[DCChatEmojiCell class] forCellWithReuseIdentifier:NSStringFromClass([DCChatEmojiCell class])];
    
    [self addSubview:self.collectionView];
    
    // 页码
//    self.pageView = [[UIPageControl alloc]init];
//    self.pageView.currentPage = 0;
//    self.pageView.pageIndicatorTintColor = HEX(@"#898989");
//    self.pageView.currentPageIndicatorTintColor = HEX(@"#D9D9D9");
//    [self addSubview:self.pageView];
//
//    int itemCount = floorf((kScreenWidth-10)/RC_EMOTIONTAB_SIZE_HEIGHT);
//    int rowCount = ceilf(self.faceEmojiArray.count/itemCount);
//    int pageCount = ceilf(rowCount/3.f);
//    self.pageView.numberOfPages = pageCount;
    
    self.botView = [[UIView alloc]initWithFrame:CGRectZero];
    self.botView.backgroundColor = kClearColor;
    [self addSubview:self.botView];
    
    UIButton *sendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [sendBtn setTitle:@"发送" forState:UIControlStateNormal];
    [sendBtn setTitleColor:kTextTitColor forState:UIControlStateNormal];
    sendBtn.titleLabel.font = kFontSize(15);
    sendBtn.frame = CGRectMake(65, 0, 55, 40);
    sendBtn.backgroundColor = [UIColor.whiteColor colorWithAlphaComponent:0.9];
    sendBtn.layer.cornerRadius = 6;
    sendBtn.clipsToBounds = YES;
    [sendBtn addTarget:self action:@selector(didSendMessage:) forControlEvents:UIControlEventTouchUpInside];
    [self.botView addSubview:sendBtn];
    self.sendButton = sendBtn;
    
    UIButton *delBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [delBtn addTarget:self action:@selector(delText) forControlEvents:UIControlEventTouchUpInside];
    [delBtn setImage:[UIImage imageNamed:@"emoji_btn_delete"] forState:UIControlStateNormal];
    delBtn.frame = CGRectMake(0, 0, 55, 40);
    delBtn.backgroundColor = [UIColor.whiteColor colorWithAlphaComponent:0.9];
    delBtn.layer.cornerRadius = 6;
    delBtn.clipsToBounds = YES;
    [self.botView addSubview:delBtn];
}
//- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
//    if (scrollView == self.collectionView) {
//        NSInteger curPage = scrollView.contentOffset.x/(kScreenWidth-10);
//        self.pageView.currentPage = curPage;
//    }
//}
- (void)layoutSubviews {
    [super layoutSubviews];
//    self.pageView.frame = CGRectMake(0, self.collectionView.height+22, kScreenWidth, 20);
    self.collectionView.frame = CGRectMake(5, 12, self.width-10, self.height-12);
    self.botView.frame = CGRectMake(self.width-140, self.height-kBottomSafe-40, 120, 40);
}
@end


@implementation DCChatEmojiCell
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.emojiLabel = [[UILabel alloc]init];
        self.emojiLabel.textAlignment = NSTextAlignmentCenter;
        self.emojiLabel.frame = self.contentView.bounds;
        self.emojiLabel.font = [UIFont systemFontOfSize:32];
        [self.contentView addSubview:self.emojiLabel];
    }
    return self;
}

@end
