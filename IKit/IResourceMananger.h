/*
 Copyright (c) 2014-2015 ideawu. All rights reserved.
 Use of this source code is governed by a license that can be
 found in the LICENSE file.

 @author:  ideawu
 @website: http://www.cocoaui.com/
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class IStyleSheet;

@interface IResourceMananger : NSObject

@property (nonatomic) BOOL enableCssCache;
@property (nonatomic) BOOL enableImageCache;

+ (IResourceMananger *)sharedMananger;
+ (void)setSharedManager:(IResourceMananger *)mananger;

- (UIImage *)loadImage:(NSString *)path callback:(void (^)(UIImage *))callback;
// css path 必须是完整路径
// TODO: 如果要支持异步加载 css, 需要对 IStyle 进行改造
- (IStyleSheet *)loadCss:(NSString *)path;

@end
