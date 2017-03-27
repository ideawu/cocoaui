/*
 Copyright (c) 2014-2017 ideawu. All rights reserved.
 Use of this source code is governed by a license that can be
 found in the LICENSE file.
 
 @author:  ideawu
 @website: http://www.cocoaui.com/
 */

#import "ITableView.h"
#import "ITableInternal.h"
#import "IStyleInternal.h"

@interface ITableView(){	
	// 锚定在底部
	IView *_bottomBar;
}
@end


@implementation ITableView

- (id)init{
	self = [super init];
	self.backgroundColor = [UIColor whiteColor];

	_scrollView = [[UIScrollView alloc] init];
	_scrollView.frame = [UIScreen mainScreen].bounds;
	_scrollView.backgroundColor = [UIColor clearColor];
	_scrollView.scrollEnabled = YES;
	_scrollView.bounces = YES;
	_scrollView.alwaysBounceVertical = YES;
	//_scrollView.alwaysBounceHorizontal = YES;

	[self addSubview:_scrollView];

	return self;
}

- (IView *)bottomBar{
	return _bottomBar;
}

- (void)setBottomBar:(IView *)bottomBar{
	if(_bottomBar){
		[_bottomBar removeFromSuperview];
	}
	_bottomBar = bottomBar;
	if(bottomBar){
		[self addSubview:bottomBar];
	}
}

- (void)layoutSubviews{
	//log_debug(@"%s", __func__);
	[super layoutSubviews];
	
	if(_bottomBar){
		CGFloat y = self.frame.size.height - _bottomBar.style.outerHeight;
		if(_bottomBar.style.top != y){
			[_bottomBar.style set:[NSString stringWithFormat:@"top: %f", y]];
		}
	}
	
	if(self.superview){
		CGSize contentFrameSize = self.frame.size;
		if(_bottomBar){
			contentFrameSize.height -= _bottomBar.style.outerHeight;
		}
		if(!CGSizeEqualToSize(_scrollView.frame.size, contentFrameSize)){
			log_debug(@"change size, w: %.1f=>%.1f, h: %.1f=>%.1f", _scrollView.frame.size.width, contentFrameSize.width, _scrollView.frame.size.height, contentFrameSize.height);
			CGRect frame = _scrollView.frame;
			frame.size = contentFrameSize;
			_scrollView.frame = frame;
		}
	}

	[_table layoutViews];
}

@end
