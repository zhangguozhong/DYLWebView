//
//  DYLWebViewProgress.h
//  DYLWebView
//
//  Created by mannyi on 2017/7/20.
//  Copyright © 2017年 mannyi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@class DYLWebViewProgress;

@protocol DYLWebViewProgressDelegate <NSObject>

@optional
- (void)webViewProgress:(DYLWebViewProgress *)webViewProgress updateProgress:(float)progress;

@end

@interface DYLWebViewProgress : NSObject <UIWebViewDelegate>

@property (weak, nonatomic) id<DYLWebViewProgressDelegate> progressDelegate;
@property (weak, nonatomic) id<UIWebViewDelegate> webViewProxyDelegate;

@end
