/*
 Copyright (c) 2014 ideawu. All rights reserved.
 Use of this source code is governed by a license that can be
 found in the LICENSE file.
 
 @author:  ideawu
 @website: http://www.cocoaui.com/
 */

#import "ICell.h"
#import "ITableInternal.h"

@interface ICell (){
	CGFloat _height;
}
@end;

@implementation ICell

- (CGFloat)height{
	return _height;
}

- (void)setHeight:(CGFloat)height{
	if(_height != height){
		if(_table){
			//log_trace(@"%s: %f => %f", __FUNCTION__, _height, height);
			CGFloat delta = height - _height;
			_height = height;
			[_table cell:self didResizeHeightDelta:delta];
		}else{
			_height = height;
		}
	}
}

- (NSUInteger)index{
	if(_table){
		return [_table.cells indexOfObject:self];
	}else{
		return NSNotFound;
	}
}

@end
