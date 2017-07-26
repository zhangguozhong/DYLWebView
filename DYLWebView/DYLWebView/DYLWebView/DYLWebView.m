//
//  DYLWebView.m
//  DYLWebView
//
//  Created by mannyi on 2017/7/20.
//  Copyright © 2017年 mannyi. All rights reserved.
//

#import "DYLWebView.h"
#import <WebKit/WebKit.h>
#import "UIWebView+DYLJavaScriptContext.h"
#import "DYLWebViewProgress.h"
#import "DYLJSContextHandler.h"
#import "UIView+DYLCurrentViewController.h"
#import <KVOController/KVOController.h>

#define kScreenWidth CGRectGetWidth([UIScreen mainScreen].bounds)
#define kScreenHeight CGRectGetHeight([UIScreen mainScreen].bounds)

@interface DYLWebView () <UIWebViewDelegate, DYLWebViewProgressDelegate, WKUIDelegate, WKNavigationDelegate, DYLJavaScriptContextDelegate>

@property (strong, nonatomic) DYLWebViewProgress *webViewProgress;
@property (nonatomic, assign) double estimatedProgress;
@property (strong, nonatomic) JSContext *javaScriptContext;

@property (copy, nonatomic, readwrite) NSString *title;
@property (strong, nonatomic, readwrite) NSURLRequest *originalRequest;
@property (strong, nonatomic, readwrite) NSURLRequest *currentRequest;

@end

@implementation DYLWebView

@synthesize usingUIWebView = _usingUIWebView;
@synthesize realWebView = _realWebView;
@synthesize scalesPageToFit = _scalesPageToFit;

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    return [self init];
}

- (instancetype)init {
    return [self initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
}

- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame usingUIWebView:NO];
}

- (instancetype)initWithFrame:(CGRect)frame usingUIWebView:(BOOL)usingUIWebView {
    self = [super initWithFrame:frame];
    if (self) {
        _usingUIWebView = usingUIWebView;
        [self initWithRealWebView];
    }
    return self;
}

- (void)initWithRealWebView {
    Class wkWebView = NSClassFromString(@"WKWebView");
    if (wkWebView && !self.usingUIWebView) {
        _usingUIWebView = NO;
        [self initWkWebView];
    }
    else {
        _usingUIWebView = YES;
        [self initUIWebView];
    }
    
    self.scalesPageToFit = YES;
    self.isAllowNativeHelperJS = YES;
    [self.realWebView setFrame:self.bounds];
    [self.realWebView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    [self addSubview:self.realWebView];
}

- (void)initWkWebView
{
    WKWebViewConfiguration *configuration = [[NSClassFromString(@"WKWebViewConfiguration") alloc] init];
    configuration.preferences = [[NSClassFromString(@"WKPreferences") alloc] init];
    configuration.preferences.javaScriptCanOpenWindowsAutomatically = YES;
    configuration.preferences.javaScriptEnabled = YES;
    configuration.userContentController = [[NSClassFromString(@"WKUserContentController") alloc] init];
    
    WKWebView *wkWebView = [[NSClassFromString(@"WKWebView") alloc] initWithFrame:self.bounds configuration:configuration];
    wkWebView.allowsBackForwardNavigationGestures = YES;
    wkWebView.UIDelegate = self;
    wkWebView.navigationDelegate = self;
    wkWebView.backgroundColor = [UIColor clearColor];
    wkWebView.opaque = NO;
    
    _realWebView = wkWebView;
    [self registerForKVO];
}

- (void)initUIWebView
{
    UIWebView *webView = [[UIWebView alloc] initWithFrame:self.bounds];
    webView.backgroundColor = [UIColor clearColor];
    webView.opaque = NO;
    
    for (UIView *subview in webView.scrollView.subviews)
    {
        if ([subview isKindOfClass:[UIImageView class]])
        {
            ((UIImageView *) subview).image = nil;
            subview.backgroundColor = [UIColor clearColor];
        }
    }
    
    self.webViewProgress = [[DYLWebViewProgress alloc] init];
    webView.delegate = _webViewProgress;
    _webViewProgress.progressDelegate = self;
    _webViewProgress.webViewProxyDelegate = self;
    _realWebView = webView;
}

#pragma mark - KVO
- (void)registerForKVO
{
    if ([_realWebView isKindOfClass:[NSClassFromString(@"WKWebView") class]]) {
        [self.KVOController observe:_realWebView keyPaths:@[@"estimatedProgress", @"title"] options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
            if ([NSThread isMainThread]) {
                [self updateUIForWkWebViewForKeyPath:change[FBKVONotificationKeyPathKey] newValue:change[NSKeyValueChangeNewKey]];
            }
            else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self updateUIForWkWebViewForKeyPath:change[FBKVONotificationKeyPathKey] newValue:change[NSKeyValueChangeNewKey]];
                });
            }
        }];
    }
}

- (void)updateUIForWkWebViewForKeyPath:(NSString *)keyPath newValue:(id)newValue
{
    if ([keyPath isEqualToString:@"estimatedProgress"]) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(webView:webViewProgress:)]) {
            [self.delegate webView:self webViewProgress:[newValue floatValue]];
        }
    } else if ([keyPath isEqualToString:@"title"]) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(webView:webViewForTitle:)]) {
            [self.delegate webView:self webViewForTitle:newValue];
        }
    }
}

#pragma mark - UIWebViewDelegate
- (void)webViewDidStartLoad:(UIWebView *)webView {
    if (self.delegate && [self.delegate respondsToSelector:@selector(webViewDidStartLoad:)]) {
        [self.delegate webViewDidStartLoad:self];
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    if (!self.originalRequest) {
        self.originalRequest = webView.request;
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(webViewDidFinishLoad:)]) {
        if (self.isAllowNativeHelperJS) {
            [self registerNativeHelperJS];
        }
        
        [self.delegate webViewDidFinishLoad:self];
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    if (self.delegate && [self.delegate respondsToSelector:@selector(webView:didFailLoadWithError:)]) {
        [self.delegate webView:self didFailLoadWithError:error];
    }
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if (self.delegate && [self.delegate respondsToSelector:@selector(webView:shouldStartLoadWithRequest:navigationType:)]) {
        return [self.delegate webView:self shouldStartLoadWithRequest:request navigationType:(DYLWebViewNavigationType)navigationType];
    } else {
        return YES;
    }
}

#pragma mark - 获取javaScriptContext
- (void)webView:(UIWebView *)webView didCreateJavaScriptContext:(JSContext *)javaScriptContext {
    self.javaScriptContext = javaScriptContext;
    UIViewController *weakTargetVC = [self viewForController];
    self.javaScriptContext[@"NativeBridge"] = [[DYLJSContextHandler alloc] initWithWeakTarget:weakTargetVC];
}


#pragma mark - WKNavigationDelegate
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    if (self.delegate && [self.delegate respondsToSelector:@selector(webViewDidStartLoad:)]) {
        [self.delegate webViewDidStartLoad:self];
    }
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    if (self.delegate && [self.delegate respondsToSelector:@selector(webView:didFailLoadWithError:)]) {
        [self.delegate webView:self didFailLoadWithError:error];
    }
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    if (self.isAllowNativeHelperJS) {
        [self registerNativeHelperJS];
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(webViewDidFinishLoad:)]) {
        [self.delegate webViewDidFinishLoad:self];
    }
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    BOOL decision = YES;
    if (self.delegate && [self.delegate respondsToSelector:@selector(webView:shouldStartLoadWithRequest:navigationType:)]) {
        decision = [self.delegate webView:self shouldStartLoadWithRequest:navigationAction.request navigationType:(DYLWebViewNavigationType)navigationAction.navigationType];
    }
    
    if (!decision) {
        decisionHandler(WKNavigationActionPolicyCancel);
    } else {
        self.currentRequest = navigationAction.request;
        if(!navigationAction.targetFrame)
        {
            [webView loadRequest:navigationAction.request];
        }
        decisionHandler(WKNavigationActionPolicyAllow);
    }
}

#pragma mark - DYLWebViewProgressDelegate
- (void)webViewProgress:(DYLWebViewProgress *)webViewProgress updateProgress:(float)progress {
    if ([self.delegate respondsToSelector:@selector(webView:webViewProgress:)]) {
        self.estimatedProgress = progress;
        [self.delegate webView:self webViewProgress:progress];
    }
}


#pragma mark - Getter and Setter
- (void)setScalesPageToFit:(BOOL)scalesPageToFit
{
    if (_usingUIWebView)
    {
        UIWebView *webView = self.realWebView;
        webView.scalesPageToFit = scalesPageToFit;
    }
    else
    {
        if (_scalesPageToFit == scalesPageToFit)
        {
            return;
        }
        else
        {
            WKWebView *webView = self.realWebView;
            NSString *jScript = @"var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); \
            meta.setAttribute('content', 'width=device-width'); \
            document.getElementsByTagName('head')[0].appendChild(meta);";
            
            if(scalesPageToFit)
            {
                WKUserScript *wkUScript = [[NSClassFromString(@"WKUserScript") alloc] initWithSource:jScript injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
                [webView.configuration.userContentController addUserScript:wkUScript];
            }
            else
            {
                NSMutableArray *array = [NSMutableArray arrayWithArray:webView.configuration.userContentController.userScripts];
                for (WKUserScript *wkUScript in array)
                {
                    if([wkUScript.source isEqual:jScript])
                    {
                        [array removeObject:wkUScript];
                        break;
                    }
                }
                for (WKUserScript *wkUScript in array)
                {
                    [webView.configuration.userContentController addUserScript:wkUScript];
                }
            }
        }
    }
    _scalesPageToFit = scalesPageToFit;
}

- (BOOL)scalesPageToFit
{
    if (_usingUIWebView)
    {
        UIWebView *webView = (UIWebView *)_realWebView;
        return webView.scalesPageToFit;
    }
    else
    {
        return _scalesPageToFit;
    }
}


#pragma mark - 基础方法
- (UIScrollView *)scrollView
{
    return [self.realWebView scrollView];
}

- (NSString *)title
{
    if (_usingUIWebView)
    {
        return [((UIWebView *)self.realWebView) stringByEvaluatingJavaScriptFromString:@"document.title"];
    }
    else
    {
        return [(WKWebView *)self.realWebView title];
    }
}

- (id)loadRequest:(NSURLRequest *)request
{
    self.originalRequest = request;
    self.currentRequest = request;
    
    if (_usingUIWebView)
    {
        [(UIWebView *)self.realWebView loadRequest:request];
        return nil;
    }
    else
    {
        return [(WKWebView *)self.realWebView loadRequest:request];
    }
}

- (id)loadHTMLString:(NSString *)string baseURL:(NSURL *)baseURL
{
    if (_usingUIWebView)
    {
        [(UIWebView *)self.realWebView loadHTMLString:string baseURL:baseURL];
        return nil;
    }
    else
    {
        return [(WKWebView *)self.realWebView loadHTMLString:string baseURL:baseURL];
    }
}

- (NSURLRequest *)currentRequest
{
    if (_usingUIWebView)
    {
        return [(UIWebView *)self.realWebView request];
    }
    else
    {
        return _currentRequest;
    }
}

- (NSURL *)URL
{
    if (_usingUIWebView)
    {
        return [(UIWebView *)self.realWebView request].URL;
    }
    else
    {
        return [(WKWebView *)self.realWebView URL];
    }
}

- (NSInteger)countOfHistory
{
    if (_usingUIWebView)
    {
        UIWebView *webView = self.realWebView;
        int count = [[webView stringByEvaluatingJavaScriptFromString:@"window.history.length"] intValue];
        if (count)
        {
            return count;
        }
        else
        {
            return 1;
        }
    }
    else
    {
        WKWebView *wkWebView = self.realWebView;
        return wkWebView.backForwardList.backList.count;
    }
}

- (void)goBackWithStep:(NSInteger)step
{
    if (![self canGoBack]) {
        return;
    }
    
    if (step > 0)
    {
        NSInteger historyCount = self.countOfHistory;
        if (step >= historyCount)
        {
            step = historyCount - 1;
        }
        
        if (_usingUIWebView)
        {
            UIWebView *webView = self.realWebView;
            [webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"window.history.go(-%ld)", (long)step]];
        }
        else
        {
            WKWebView *wkWebView = self.realWebView;
            WKBackForwardListItem *backItem = wkWebView.backForwardList.backList[step];
            [wkWebView goToBackForwardListItem:backItem];
        }
    }
    else
    {
        [self goBack];
    }
}

- (id)goBack
{
    if (_usingUIWebView)
    {
        [(UIWebView *)self.realWebView goBack];
        return nil;
    }
    else
    {
        return [(WKWebView *)self.realWebView goBack];
    }
}

- (id)goForward
{
    if (_usingUIWebView)
    {
        [(UIWebView *)self.realWebView goForward];
        return nil;
    }
    else
    {
        return [(WKWebView *)self.realWebView goForward];
    }
}

- (id)reload
{
    if (_usingUIWebView)
    {
        [(UIWebView *)self.realWebView reload];
        return nil;
    }
    else
    {
        return [(WKWebView *)self.realWebView reload];
    }
}

- (id)reloadFromOrigin
{
    if (_usingUIWebView)
    {
        if (self.originalRequest)
        {
            [self evaluateJavaScript:[NSString stringWithFormat:@"window.location.replace('%@')",self.originalRequest.URL.absoluteString] completionHandler:nil];
        }
        return nil;
    }
    else
    {
        return [(WKWebView*)self.realWebView reloadFromOrigin];
    }
}

- (void)stopLoading
{
    [self.realWebView stopLoading];
}

- (BOOL)canGoBack
{
    return [self.realWebView canGoBack];
}

- (BOOL)canGoForward
{
    return [self.realWebView canGoForward];
}

- (BOOL)isLoading
{
    return [self.realWebView isLoading];
}

- (void)evaluateJavaScript:(NSString *)javaScriptString completionHandler:(void (^)(id, NSError *))completionHandler
{
    if (_usingUIWebView)
    {
        JSValue *jsValue = [self.javaScriptContext evaluateScript:javaScriptString];
        if (completionHandler) {
            completionHandler(jsValue, nil);
        }
    }
    else
    {
        [(WKWebView *)self.realWebView evaluateJavaScript:javaScriptString completionHandler:completionHandler];
    }
}


#pragma mark - ScriptMessageHandler
- (void)addScriptMessageHandler:(id<WKScriptMessageHandler>)scriptMessageHandler name:(NSString *)name {
    if ([_realWebView isKindOfClass:[NSClassFromString(@"WKWebView") class]]) {
        [((WKWebView *)_realWebView).configuration.userContentController addScriptMessageHandler:scriptMessageHandler name:name];
    }
}

- (void)removeScriptMessageHandlerForName:(NSString *)name {
    if ([_realWebView isKindOfClass:[NSClassFromString(@"WKWebView") class]]) {
        [((WKWebView *)_realWebView).configuration.userContentController removeScriptMessageHandlerForName:name];
    }
}

- (void)registerNativeHelperJS {
    NSString *nativeHelperJS = [[NSBundle mainBundle] pathForResource:@"nativehelper" ofType:@".js"];
    if (nativeHelperJS) {
        NSString *javaScriptString = [NSString stringWithContentsOfFile:nativeHelperJS encoding:NSUTF8StringEncoding error:nil];
        [self evaluateJavaScript:javaScriptString completionHandler:^(id result, NSError *error) {
            
        }];
    }
}

#pragma mark - 如果没有找到方法，去realWebView或者delegate中调用
- (BOOL)respondsToSelector:(SEL)aSelector
{
    BOOL hasResponds = [super respondsToSelector:aSelector];
    if (!hasResponds) {
        hasResponds = [self.realWebView respondsToSelector:aSelector];
    }
    if (!hasResponds) {
        hasResponds = [self.delegate respondsToSelector:aSelector];
    }
    return hasResponds;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
    NSMethodSignature *methodSignature = [super methodSignatureForSelector:aSelector];
    if (!methodSignature) {
        if ([self.realWebView respondsToSelector:aSelector]) {
            methodSignature = [self.realWebView methodSignatureForSelector:aSelector];
        }
        else if ([self.delegate respondsToSelector:aSelector]) {
            methodSignature = [(id)self.delegate methodSignatureForSelector:aSelector];
        }
    }
    return methodSignature;
}

- (void)forwardInvocation:(NSInvocation *)anInvocation
{
    if ([self.realWebView respondsToSelector:anInvocation.selector]) {
        [anInvocation invokeWithTarget:self.realWebView];
    }
    else {
        [anInvocation invokeWithTarget:self.delegate];
    }
}


#pragma mark - 清理
- (void)dealloc {
    if (_usingUIWebView) {
        UIWebView *webView = self.realWebView;
        webView.delegate = nil;
    }
    else {
        WKWebView *wkWebView = self.realWebView;
        wkWebView.UIDelegate = nil;
        wkWebView.navigationDelegate = nil;
    }
    
    [_realWebView scrollView].delegate = nil;
    [_realWebView stopLoading];
    [(UIWebView *)_realWebView loadHTMLString:@"" baseURL:nil];
    [_realWebView stopLoading];
    [_realWebView removeFromSuperview];
    _realWebView = nil;
}

@end
