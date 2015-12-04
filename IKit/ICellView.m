/*
 Copyright (c) 2014 ideawu. All rights reserved.
 Use of this source code is governed by a license that can be
 found in the LICENSE file.
 
 @author:  ideawu
 @website: http://www.cocoaui.com/
 */

#import "ICellView.h"
#import "ICell.h"
#import "ITableInternal.h"

@implementation ICellView

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
	//log_trace(@"%s", __func__);
	[super touchesBegan:touches withEvent:event];
	[_cell.table onHighlight:_cell.contentView atIndex:_cell.index];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
	//log_trace(@"%s", __func__);
	[super touchesMoved:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
	//log_trace(@"%s", __func__);
	[super touchesEnded:touches withEvent:event];
	[_cell.table onClick:_cell.contentView atIndex:_cell.index];
	[self performSelector:@selector(delayUnhighlight) withObject:nil afterDelay:0.15];
	//[_cell.table performSelector:@selector(onUnhighlight:) withObject:_cell.contentView afterDelay:0.15];
}

- (void)delayUnhighlight{
	[_cell.table onUnhighlight:_cell.contentView atIndex:_cell.index];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
	//log_trace(@"%s", __func__);
	[super touchesCancelled:touches withEvent:event];
	[_cell.table onUnhighlight:_cell.contentView atIndex:_cell.index];
}

@end
