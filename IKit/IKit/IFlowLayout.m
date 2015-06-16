/*
 Copyright (c) 2014 ideawu. All rights reserved.
 Use of this source code is governed by a license that can be
 found in the LICENSE file.
 
 @author:  ideawu
 @website: http://www.cocoaui.com/
 */

#import "IFlowLayout.h"
#import "IViewInternal.h"
#import "IStyleInternal.h"

@interface IFlowLayout (){
	CGFloat _x2;
	NSMutableArray *_leftPoints;
	NSMutableArray *_rightPoints;
}
@property (nonatomic, weak) IStyle *style;

- (void)newLine:(IStyleFloatType)floatType;
@end

@implementation IFlowLayout

+ (id)layoutWithStyle:(IStyle *)style{
	IFlowLayout *ret = [[IFlowLayout alloc] init];
	ret.style = style;
	[ret reset];
	return ret;
}

- (id)init{
	self = [super init];
	return self;
}

- (void)reset{
	_x = 0;
	_y = 0;
	_w = _style.w;
	_h = _style.h;
	_x2 = _w;
	_realWidth = 0;
	_realHeight = 0;
	if(_leftPoints != nil){
		[_leftPoints removeAllObjects];
		[_rightPoints removeAllObjects];
	}
}

- (void)place:(IView *)view{
	IStyle *style = view.style;
	
	if(style.displayType == IStyleDisplayNone){
		return;
	}
	
	if(_leftPoints == nil){
		_leftPoints = [[NSMutableArray alloc] init];
		_rightPoints = [[NSMutableArray alloc] init];
	}
	
	// clear before positioning
	if(style.clearLeft){
		//while(_x != 0){
		while(_leftPoints.count > 0){
			[self newLine: IStyleFloatLeft];
		}
	}
	if(style.clearRight){
		//while(_x2 != _w){
		while(_rightPoints.count > 0){
			[self newLine: IStyleFloatRight];
		}
	}
	
	if(style.ratioWidth > 0){
		style.w = style.ratioWidth * (_x2 - _x) - style.margin.left - style.margin.right;
		//log_trace(@"x2=%f, x=%f, margin-left: %f, margin-right: %f", _x2, _x, style.margin.left, style.margin.right);
		//log_trace(@"left=%lu, right=%lu", _leftPoints.count, _rightPoints.count);
	}
	if(style.ratioHeight > 0){
		style.h = style.ratioHeight * (_h - _y) - style.margin.top - style.margin.bottom;
	}

	if(style.resizeNone){
		// view.need_layout 的时候再调用?
		[view layout];
	}
	
	while(1){
		if(!style.resizeNone){
			if(style.resizeWidth){
				style.w = _x2 - _x - style.margin.left - style.margin.right;
			}
			if(style.w > 0){
				//log_trace(@"%@ before w=%f, h=%f, _x=%f, x2=%f", view.name, style.w, style.h, _x, _x2);
				view.level += 1;
				//log_trace(@"%s %d call layout %@", __func__, __LINE__, view.name);
				[view layout];
				view.level -= 1;
				//log_trace(@"%@ after w=%f, h=%f, _x=%f, x2=%f", view.name, style.w, style.h, _x, _x2);
				if(style.w == 0){
					return;
				}
			}
		}
		
		if((_leftPoints.count > 0 || _rightPoints.count > 0) && (style.w <= 0 || _x + style.outerBox.w > _x2)){
			[self newLine: style.floatType];
		}else{
			break;
		}
	}

	IRect box = style.outerBox;
	
	if(style.valignType == IStyleValignTop){
		box.y = _y;
	}else if(style.valignType == IStyleValignBottom){
		box.y = _style.innerHeight - box.h;
	}else if(style.valignType == IStyleValignMiddle){
		box.y = ((_style.innerHeight - _y) - box.h)/2;
	}

	if(style.floatCenter){
		// 居中相当于左右 margin 相等
		box.x = _x + ((_x2 - _x) - box.w)/2;
		//box.y = _y;
		CGPoint p = CGPointMake(_x, box.y + box.h);
		NSValue *v = [NSValue valueWithCGPoint:p];
		[_leftPoints addObject:v];
		_x = _x2;
	}else if(style.floatRight){
		box.x = _x2 - box.w;
		//box.y = _y;
		CGPoint p = CGPointMake(_x2, box.y + box.h);
		NSValue *v = [NSValue valueWithCGPoint:p];
		[_rightPoints addObject:v];
		_x2 -= box.w;
	}else{
		box.x = _x;
		//box.y = _y;
		CGPoint p = CGPointMake(_x, box.y + box.h);
		NSValue *v = [NSValue valueWithCGPoint:p];
		[_leftPoints addObject:v];
		_x += box.w;
	}
	
	style.x = box.x + style.margin.left;
	style.y = box.y + style.margin.top;
	
	if(style.resizeWidth){
		//log_trace(@"%@ place, x=%f, y=%f, w=%f, h=%f", view.name, style.x, style.y, style.w, style.h);
	}
	
	// clear after positioning
	if(style.floatLeft && style.clearRight){
		_x = _x2;
	}
	if(style.floatRight && style.clearLeft){
		_x = _x2;
	}
	if(_x >= _x2){
		[self newLine: style.floatType];
	}
	
	_realWidth = MAX(_realWidth, box.x + box.w);
	_realHeight = MAX(_realHeight, box.y + box.h);
}

- (void)newLine:(IStyleFloatType)floatType{
	NSValue *left, *right, *pop;
	left = [_leftPoints lastObject];
	right = [_rightPoints lastObject];
	if(!left && !right){
		_x = 0;
		_x2 = _w;
		return;
	}else if(left && !right){
		pop = left;
	}else if(!left && right){
		pop = right;
	}else if(left && right){
		CGPoint l = [left CGPointValue];
		CGPoint r = [right CGPointValue];
		if(l.y < r.y){
			pop = left;
		}else if(l.y > r.y){
			pop = right;
		}else{
			if(floatType == IStyleFloatLeft){
				pop = left;
			}else{
				pop = right;
			}
		}
	}
	CGPoint p = [pop CGPointValue];
	// TODO:
	//_y = p.y;
	_y = MAX(_y, p.y);
	if(pop == left){
		_x = p.x;
		[_leftPoints removeLastObject];
	}else{
		_x2 = p.x;
		[_rightPoints removeLastObject];
	}
	while ([_leftPoints count] > 0) {
		NSValue *v = [_leftPoints lastObject];
		CGPoint p = [v CGPointValue];
		if(p.y > _y){
			break;
		}
		_x = p.x;
		[_leftPoints removeLastObject];
	}
	while ([_rightPoints count] > 0) {
		NSValue *v = [_rightPoints lastObject];
		CGPoint p = [v CGPointValue];
		if(p.y > _y){
			break;
		}
		_x2 = p.x;
		[_rightPoints removeLastObject];
	}
	if([_leftPoints count] == 0){
		_x = 0;
	}
	if([_rightPoints count] == 0){
		_x2 = _w;
		if(_style.resizeWidth){
			_x2 = MAX(_w, _realWidth);
		}
	}
}

@end
