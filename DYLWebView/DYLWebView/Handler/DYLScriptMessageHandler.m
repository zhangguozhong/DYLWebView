//
//  DYLScriptMessageHandler.m
//  DYLWebView
//
//  Created by mannyi on 2017/7/20.
//  Copyright © 2017年 mannyi. All rights reserved.
//

#import "DYLScriptMessageHandler.h"

@interface DYLScriptMessageHandler ()

@property (weak, nonatomic) id<WKScriptMessageHandler> scriptDelegate;

@end

@implementation DYLScriptMessageHandler

- (instancetype)initWithScriptDelegate:(id<WKScriptMessageHandler>)scriptDelegate {
    self = [super init];
    if (self) {
        self.scriptDelegate = scriptDelegate;
    }
    return self;
}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message
{
    [self.scriptDelegate userContentController:userContentController didReceiveScriptMessage:message];
}

@end
