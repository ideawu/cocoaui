/*
 Copyright (c) 2014 ideawu. All rights reserved.
 Use of this source code is governed by a license that can be
 found in the LICENSE file.
 
 @author:  ideawu
 @website: http://www.cocoaui.com/
 */

#ifndef IKit_ICell_h
#define IKit_ICell_h

#import "ITableCellView.h"

@class IView;
@class ITable;

@interface ITableCell : NSObject

@property (nonatomic, weak) ITable *table;

@property (nonatomic) ITableCellView *view;
@property (nonatomic) IView *contentView;

@property (nonatomic) BOOL isSeparator;

@property (nonatomic) CGFloat x;
@property (nonatomic) CGFloat y;
@property (nonatomic) CGFloat height;

@property (nonatomic) NSString *tag;
@property (nonatomic) id data;

- (NSUInteger)index;

@end

#endif
