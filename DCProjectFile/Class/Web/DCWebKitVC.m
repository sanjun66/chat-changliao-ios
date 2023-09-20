//
//  DCWebKitVC.m
//  DCProjectFile
//
//  Created  on 2023/7/5.
//

#import "DCWebKitVC.h"
#import <WebKit/WebKit.h>

@interface DCWebKitVC ()
@property (nonatomic,strong) WKWebView *wkWebview;
@property (nonatomic,strong) UIProgressView *progress;

@end

@implementation DCWebKitVC

- (void)viewDidLoad {
    [super viewDidLoad];
    if (![NSString isEmpty:self.titleStr]) {
        self.navigationItem.title = self.titleStr;
    }
    [self createWebkit];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.wkWebview.frame = self.view.bounds;
}
- (void)createWebkit {
    self.extendedLayoutIncludesOpaqueBars = YES;
        
    WKWebView *webView = [[WKWebView alloc] initWithFrame:CGRectZero];
//    webView.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight-kNavHeight);
    
    webView.opaque = false;
    webView.backgroundColor = kWhiteColor;
    if ([NSString isEmpty:self.titleStr]) {
        [webView addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:NULL];
    }
    [self.view addSubview:webView];
    self.wkWebview = webView;
    
    
    if (![DCTools isEmpty:self.localPath]) {
//        NSString *path = [[NSBundle mainBundle] pathForResource:@"resource_res_express" ofType:@"html"];
//        NSString *htmlString = [NSString stringWithContentsOfFile:self.localPath encoding:NSUTF8StringEncoding error:nil];
//        NSString *basePath = [[NSBundle mainBundle] bundlePath];
//        NSURL *baseURL = [NSURL fileURLWithPath:basePath];
//        [webView loadHTMLString:htmlString baseURL:baseURL];
        [webView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:self.localPath isDirectory:NO]]];
        return;
    }
    
    NSString *urlStr = self.jumpUrl;
    NSURL *url = [NSURL URLWithString:urlStr];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    [webView loadRequest:request];
    
}
#pragma mark KVO的监听代理
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"title"]){
        if (object == self.wkWebview){
            self.title = self.wkWebview.title;
        }else{
            [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        }
    }else{
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}
#pragma mark 移除观察者
- (void)dealloc
{
    if ([NSString isEmpty:self.titleStr]) {
        [self.wkWebview removeObserver:self forKeyPath:@"title"];
    }
}
#pragma mark 加载进度条
- (UIProgressView *)progress
{
    if (_progress == nil)
    {
        _progress = [[UIProgressView alloc]initWithFrame:CGRectMake(0, kNavHeight, kScreenWidth, 2)];
        _progress.tintColor = [UIColor blueColor];
        _progress.backgroundColor = [UIColor lightGrayColor];
        [self.view addSubview:_progress];
    }
    return _progress;
}
@end
