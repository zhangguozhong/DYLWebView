//
//  DYLWebViewProgressView.h
//  DYLWebView
//
//  Created by mannyi on 2017/7/20.
//  Copyright © 2017年 mannyi. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DYLWebViewProgressView;
@protocol DYLWebViewProgressViewDelegate <NSObject>

@optional
- (void)webViewProgressViewDidFinishLoad:(DYLWebViewProgressView *)webViewProgressView;

@end

@interface DYLWebViewProgressView : UIView

@property (assign, nonatomic) float progress;
@property (strong, nonatomic) UIColor *progressColor;

@property (weak, nonatomic) id<DYLWebViewProgressViewDelegate> delegate;

@end
