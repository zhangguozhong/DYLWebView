//
//  DYLWebViewProgressView.h
//  DYLWebView
//
//  Created by mannyi on 2017/7/20.
//  Copyright © 2017年 mannyi. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^CompletionBlock)(void);

@interface DYLWebViewProgressView : UIView

@property (assign, nonatomic) float progress;
@property (strong, nonatomic) UIColor *progressColor;

@property (copy, nonatomic) CompletionBlock completionBlock;

@end
