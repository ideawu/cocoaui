/*
 Copyright (c) 2014 ideawu. All rights reserved.
 Use of this source code is governed by a license that can be
 found in the LICENSE file.
 
 @author:  ideawu
 @website: http://www.cocoaui.com/
 */

#ifndef IKit_ITableInternal_h
#define IKit_ITableInternal_h

#import "ITable.h"

@class ICell;

@interface ITable()

- (void)cell:(ICell *)cell didResizeHeightDelta:(CGFloat)delta;

- (void)onHighlight:(IView *)view;
- (void)onUnhighlight:(IView *)view;
- (void)onClick:(IView *)view;

@end

#endif
