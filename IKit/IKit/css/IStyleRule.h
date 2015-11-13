/*
 Copyright (c) 2014-2015 ideawu. All rights reserved.
 Use of this source code is governed by a license that can be
 found in the LICENSE file.
 
 @author:  ideawu
 @website: http://www.cocoaui.com/
 */

#import <Foundation/Foundation.h>

@class IView;
@class IStyleDeclBlock;

@interface IStyleRule : NSObject

@property (nonatomic, readonly) NSMutableArray *selectors;
@property (nonatomic, readonly) IStyleDeclBlock *declBlock;
@property (nonatomic, readonly) NSString *baseUrl;
@property (nonatomic, readonly) int weight;

- (void)parseRule:(NSString *)rule css:(NSString *)css baseUrl:(NSString *)baseUrl;
- (BOOL)match:(IView *)view;

@end
