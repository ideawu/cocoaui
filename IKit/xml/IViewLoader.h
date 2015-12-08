/*
 Copyright (c) 2014-2015 ideawu. All rights reserved.
 Use of this source code is governed by a license that can be
 found in the LICENSE file.
 
 @author:  ideawu
 @website: http://www.cocoaui.com/
 */

#import <Foundation/Foundation.h>

@class IView;
@class IStyleSheet;

@interface IViewLoader : NSObject

@property (nonatomic, readonly) IStyleSheet *styleSheet;

+ (IView *)viewFromXml:(NSString *)xml;
+ (IView *)viewFromXml:(NSString *)xml basePath:(NSString *)basePath;
+ (IView *)viewWithContentsOfFile:(NSString *)path;

+ (void)loadUrl:(NSString *)url callback:(void (^)(IView *view))callback;

- (IView *)getViewById:(NSString *)id_;


- (void)didStartElement:(NSString *)tagName attributes:(NSDictionary *)attributeDict;
- (void)didEndElement:(NSString *)tagName;
- (void)foundCharacters:(NSString *)str;

@end
