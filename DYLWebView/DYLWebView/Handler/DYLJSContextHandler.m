//
//  DYLJSContextHandler.m
//  DYLWebView
//
//  Created by mannyi on 2017/7/20.
//  Copyright © 2017年 mannyi. All rights reserved.
//

#import "DYLJSContextHandler.h"

@interface DYLJSContextHandler ()

@property (weak, nonatomic) id weakTarget;

@end

@implementation DYLJSContextHandler

- (instancetype)initWithWeakTarget:(id)weakTarget {
    self = [super init];
    if (self) {
        self.weakTarget = weakTarget;
    }
    return self;
}

- (void)show
{
}

- (void)open
{
}

@end
