/*
 Copyright (c) 2014-2017 ideawu. All rights reserved.
 Use of this source code is governed by a license that can be
 found in the LICENSE file.
 
 @author:  ideawu
 @website: http://www.cocoaui.com/
 */

#import <UIKit/UIKit.h>

@class ITable;
@class IView;

@interface ITableView : UIView

@property (nonatomic, weak) ITable *table;

@property (nonatomic, readonly) UIScrollView *scrollView;

@property (nonatomic) IView *bottomBar;

@end
