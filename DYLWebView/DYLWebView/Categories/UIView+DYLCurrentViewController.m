//
//  UIView+DYLCurrentViewController.m
//  DYLWebView
//
//  Created by mannyi on 2017/7/20.
//  Copyright © 2017年 mannyi. All rights reserved.
//

#import "UIView+DYLCurrentViewController.h"

@implementation UIView (DYLCurrentViewController)

- (UIViewController *)viewForController
{
    UIResponder *next = [self nextResponder];
    do {
        if ([next isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)next;
        }
        next = [next nextResponder];
    } while (next);
    return nil;
}

@end
