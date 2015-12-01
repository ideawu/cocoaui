/*
 Copyright (c) 2014-2015 ideawu. All rights reserved.
 Use of this source code is governed by a license that can be
 found in the LICENSE file.
 
 @author:  ideawu
 @website: http://www.cocoaui.com/
 */

#import <Foundation/Foundation.h>

@class IView;
@class ICssBlock;

@interface ICssRule : NSObject

@property (nonatomic, readonly) ICssBlock *declBlock;
@property (nonatomic, readonly) int weight;

+ (ICssRule *)fromSelector:(NSString *)sel css:(NSString *)css baseUrl:(NSString *)baseUrl;

- (BOOL)containsPseudoClass;
- (BOOL)matchView:(IView *)view;

@end
