/*
 Copyright (c) 2014 ideawu. All rights reserved.
 Use of this source code is governed by a license that can be
 found in the LICENSE file.
 
 @author:  ideawu
 @website: http://www.cocoaui.com/
 */

#import <UIKit/UIKit.h>

@class IView;
@class IStyle;

@interface IFlowLayout : NSObject{
}

@property (nonatomic) CGFloat x;
@property (nonatomic) CGFloat y;
@property (nonatomic) CGFloat w;
@property (nonatomic) CGFloat h;
@property (nonatomic) CGFloat realWidth;
@property (nonatomic) CGFloat realHeight;

+ (id)layoutWithStyle:(IStyle *)style;

- (void)place:(IView *)view;
- (void)reset;

@end
