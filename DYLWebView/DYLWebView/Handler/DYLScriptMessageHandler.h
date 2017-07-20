//
//  DYLScriptMessageHandler.h
//  DYLWebView
//
//  Created by mannyi on 2017/7/20.
//  Copyright © 2017年 mannyi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WKScriptMessageHandler.h>

@interface DYLScriptMessageHandler : NSObject

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

- (instancetype)initWithScriptDelegate:(id<WKScriptMessageHandler>)scriptDelegate;

@end
