//
//  UIWebView+DYLJavaScriptContext.m
//  DYLWebView
//
//  Created by mannyi on 2017/7/20.
//  Copyright © 2017年 mannyi. All rights reserved.
//

#import "UIWebView+DYLJavaScriptContext.h"
#import <objc/runtime.h>

@interface UIWebView (DYLJavaScriptCorePrivate)

- (void)private_didCreateJavaScriptContext:(JSContext *)javaScriptContext;

@end

static NSHashTable *globalWebViews = nil;
@implementation NSObject (JavaScriptContext)

- (void)webView:(id)unused didCreateJavaScriptContext:(JSContext *)javaScriptContext forFrame:(id)frame
{
    void (^notifyDidCreateJavaScriptContext)() = ^{
        for (UIWebView *webView in globalWebViews)
        {
            NSString *identifier = [NSString stringWithFormat:@"dyl_jscWebView_%lu", (unsigned long)webView.hash];
            [webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"var %@ = '%@'", identifier, identifier]];
            
            if ([javaScriptContext[identifier].toString isEqualToString:identifier]) {
                [webView private_didCreateJavaScriptContext:javaScriptContext];
                return;
            }
        }
    };
    
    if ([NSThread mainThread]) {
        notifyDidCreateJavaScriptContext();
    }
    else {
        dispatch_async(dispatch_get_main_queue(), notifyDidCreateJavaScriptContext);
    }
}

@end

@implementation UIWebView (DYLJavaScriptContext)

+ (id)allocWithZone:(struct _NSZone *)zone
{
    dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        globalWebViews = [NSHashTable weakObjectsHashTable];
    });
    
    id webView = [super allocWithZone:zone];
    [globalWebViews addObject:webView];
    return webView;
}

- (void)private_didCreateJavaScriptContext:(JSContext *)javaScriptContext
{
    objc_setAssociatedObject(self, @selector(javaScriptContext), javaScriptContext, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (self.delegate && [self.delegate respondsToSelector:@selector(webView:didCreateJavaScriptContext:)]) {
        id<DYLJavaScriptContextDelegate> weakProxyDelegate = (id<DYLJavaScriptContextDelegate>)self.delegate;
        [weakProxyDelegate webView:self didCreateJavaScriptContext:javaScriptContext];
    }
}

- (JSContext *)javaScriptContext
{
    return objc_getAssociatedObject(self, _cmd);
}

@end
