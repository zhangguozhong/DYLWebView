//
//  DYLWebViewProgressView.m
//  DYLWebView
//
//  Created by mannyi on 2017/7/20.
//  Copyright © 2017年 mannyi. All rights reserved.
//

#import "DYLWebViewProgressView.h"

@interface DYLWebViewProgressView ()
@property (strong, nonatomic) UIView *progressBarView;
@end

@implementation DYLWebViewProgressView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = NO;
        _progressBarView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, CGRectGetHeight(self.bounds))];
        _progressBarView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _progressBarView.alpha = 0;
        _progressBarView.backgroundColor = [UIColor redColor];
        [self addSubview:_progressBarView];
    }
    return self;
}

- (void)setProgressColor:(UIColor *)progressColor
{
    _progressColor = progressColor;
    _progressBarView.backgroundColor = progressColor;
}

- (void)setProgress:(float)progress
{
    _progress = progress;
    if (progress >= 1.) {
        [UIView animateWithDuration:0.25 animations:^{
            CGRect frame = _progressBarView.frame;
            frame.size.width = progress * CGRectGetWidth(self.frame);
            _progressBarView.frame = frame;
            
        } completion:^(BOOL finished) {
            if (finished) {
                _progressBarView.alpha = 0.0;
                CGRect frame = _progressBarView.frame;
                frame.size.width = 0;
                _progressBarView.frame = frame;
            }
            
            if ([self.delegate respondsToSelector:@selector(webViewProgressViewDidFinishLoad:)]) {
                [self.delegate webViewProgressViewDidFinishLoad:self];
            }
        }];
    }
    else {
        _progressBarView.alpha = 1;
        if (progress > 0) {
            [UIView animateWithDuration:0.25 animations:^{
                CGRect frame = _progressBarView.frame;
                frame.size.width = progress * CGRectGetWidth(self.frame);
                _progressBarView.frame = frame;
                
            } completion:^(BOOL finished) {
                
            }];
        }
    }
}

@end
