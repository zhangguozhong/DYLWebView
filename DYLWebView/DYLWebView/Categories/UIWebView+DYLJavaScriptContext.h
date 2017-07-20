//
//  UIWebView+DYLJavaScriptContext.h
//  DYLWebView
//
//  Created by mannyi on 2017/7/20.
//  Copyright © 2017年 mannyi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <JavaScriptCore/JavaScriptCore.h>

@protocol DYLJavaScriptContextDelegate <UIWebViewDelegate>

@optional
- (void)webView:(UIWebView *)webView didCreateJavaScriptContext:(JSContext *)javaScriptContext;

@end

@interface UIWebView (DYLJavaScriptContext)

@property (strong, nonatomic, readonly) JSContext *javaScriptContext;

@end
