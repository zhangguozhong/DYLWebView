//
//  DYLWebViewDemoController.m
//  DYLWebView
//
//  Created by mannyi on 2017/7/20.
//  Copyright © 2017年 mannyi. All rights reserved.
//

#import "DYLWebViewDemoController.h"
#import "DYLWebView.h"
#import "DYLWebViewProgressView.h"

@interface DYLWebViewDemoController () <DYLWebViewDelegate, WKScriptMessageHandler>

@property (strong, nonatomic) DYLWebView *webView;
@property (strong, nonatomic) DYLWebViewProgressView *progressBarView;

@end

@implementation DYLWebViewDemoController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"测试";
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.webView = [[DYLWebView alloc] initWithFrame:self.view.bounds];
    _webView.delegate = self;
    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://www.mannyi.com"]]];
    [self.view addSubview:_webView];
    
    self.progressBarView = [[DYLWebViewProgressView alloc] initWithFrame:CGRectMake(0, [self isNavigationHidden]?0:64, self.view.frame.size.width, 2)];
    _progressBarView.progressColor = [UIColor greenColor];
    [self.view addSubview:_progressBarView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
}

- (BOOL)webView:(DYLWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(DYLWebViewNavigationType)navigationType
{
    return YES;
}

- (void)webViewDidStartLoad:(DYLWebView *)webView
{
    NSLog(@"加载开始");
}

- (void)webViewDidFinishLoad:(DYLWebView *)webView
{
    NSLog(@"加载完成");
}

- (void)webView:(DYLWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"加载错误%@", error);
}


- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message
{
    
}

- (void)webView:(DYLWebView *)webView webViewProgress:(float)progress
{
    _progressBarView.progress = progress;
}

- (BOOL)isNavigationHidden
{
    return !self.navigationController || !self.navigationController.navigationBar.translucent || !self.navigationController.navigationBar;
}

@end
