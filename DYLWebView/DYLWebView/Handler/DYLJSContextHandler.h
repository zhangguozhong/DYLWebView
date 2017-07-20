//
//  DYLJSContextHandler.h
//  DYLWebView
//
//  Created by mannyi on 2017/7/20.
//  Copyright © 2017年 mannyi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>

@protocol DYLJSContextHandlerDelegate <JSExport>

- (void)show;
- (void)open;

@end

@interface DYLJSContextHandler : NSObject <DYLJSContextHandlerDelegate>

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

- (instancetype)initWithWeakTarget:(id)weakTarget;

@end
