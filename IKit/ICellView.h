/*
 Copyright (c) 2014 ideawu. All rights reserved.
 Use of this source code is governed by a license that can be
 found in the LICENSE file.
 
 @author:  ideawu
 @website: http://www.cocoaui.com/
 */

#ifndef IKit_ICellView_h
#define IKit_ICellView_h

#import <UIKit/UIKit.h>

@class ICell;

@interface ICellView : UIView

@property (nonatomic, weak) ICell *cell;

@end

#endif
