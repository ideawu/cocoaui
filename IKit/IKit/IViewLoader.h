/*
 Copyright (c) 2014 ideawu. All rights reserved.
 Use of this source code is governed by a license that can be
 found in the LICENSE file.
 
 @author:  ideawu
 @website: http://www.cocoaui.com/
 */

#import <Foundation/Foundation.h>

@class IView;
@class IStyleSheet;

@interface IViewLoader : NSObject

@property (nonatomic) NSString *baseUrl;

@property (nonatomic, readonly) NSArray *rootViews;
@property (nonatomic, readonly) IView *view;
@property (nonatomic, readonly) IStyleSheet *styleSheet;

+ (void)loadUrl:(NSString *)url callback:(void (^)(IView *view))callback;

- (void)loadXml:(NSString *)str;
- (IView *)getViewById:(NSString *)id_;

- (void)duplicate;

@end
