//
//  DYLWebView.h
//  DYLWebView
//
//  Created by mannyi on 2017/7/20.
//  Copyright © 2017年 mannyi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WKScriptMessageHandler.h>

@class DYLWebView;

typedef NS_ENUM(NSInteger, DYLWebViewNavigationType) {
    DYLWebViewNavigationTypeLinkClicked,
    DYLWebViewNavigationTypeFormSubmitted,
    DYLWebViewNavigationTypeBackForward,
    DYLWebViewNavigationTypeReload,
    DYLWebViewNavigationTypeFormResubmitted,
    DYLWebViewNavigationTypeOther
};

@protocol DYLWebViewDelegate <NSObject>

@required
- (void)webViewDidStartLoad:(DYLWebView *)webView;
- (void)webViewDidFinishLoad:(DYLWebView *)webView;
- (void)webView:(DYLWebView *)webView didFailLoadWithError:(NSError *)error;
- (BOOL)webView:(DYLWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(DYLWebViewNavigationType)navigationType;

@optional
- (void)webView:(DYLWebView *)webView webViewProgress:(float)progress;
- (void)webView:(DYLWebView *)webView webViewForTitle:(NSString *)title;

@end

@interface DYLWebView : UIView

@property (assign, nonatomic, readonly) BOOL usingUIWebView;
@property (nonatomic, readonly) id realWebView;
@property (strong, nonatomic, readonly) UIScrollView *scrollView;
@property (assign, nonatomic) BOOL isAllowNativeHelperJS;

@property (weak, nonatomic) id<DYLWebViewDelegate> delegate;
@property (copy, nonatomic, readonly) NSString *title;

@property (strong, nonatomic, readonly) NSURLRequest *originalRequest;
@property (strong, nonatomic, readonly) NSURLRequest *currentRequest;
@property (strong, nonatomic, readonly) NSURL *URL;

- (instancetype)initWithFrame:(CGRect)frame usingUIWebView:(BOOL)usingUIWebView;

@property (assign, nonatomic) BOOL scalesPageToFit;
///预估网页加载进度
@property (nonatomic, readonly) double estimatedProgress;

@property (nonatomic, readonly) BOOL canGoBack;
@property (nonatomic, readonly) BOOL canGoForward;
@property (nonatomic, readonly) BOOL isLoading;

- (id)loadRequest:(NSURLRequest *)request;
- (id)loadHTMLString:(NSString *)string baseURL:(NSURL *)baseURL;

- (NSInteger)countOfHistory;
- (void)goBackWithStep:(NSInteger)step;

- (id)goBack;
- (id)goForward;
- (id)reload;
- (id)reloadFromOrigin;
- (void)stopLoading;

/**
 执行指定的js方法
 */
- (void)evaluateJavaScript:(NSString *)javaScriptString completionHandler:(void (^)(id result, NSError *error))completionHandler;

/**
 添加js回调oc通知方式，适用于 iOS8 之后
 */
- (void)addScriptMessageHandler:(id<WKScriptMessageHandler>)scriptMessageHandler name:(NSString *)name;

/**
 注销 注册过的js回调oc通知方式，适用于 iOS8 之后
 */
- (void)removeScriptMessageHandlerForName:(NSString *)name;

@end
