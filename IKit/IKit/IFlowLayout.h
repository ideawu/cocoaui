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

+ (id)layoutWithView:(IView *)view;

- (void)layout;

@end
