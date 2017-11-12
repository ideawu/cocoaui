/*
 Copyright (c) 2014 ideawu. All rights reserved.
 Use of this source code is governed by a license that can be
 found in the LICENSE file.
 
 @author:  ideawu
 @website: http://www.cocoaui.com/
 */

#import "IPullRefresh.h"
#import "IView.h"
#import "IRefreshControl.h"

@interface IPullRefresh (){
	//BOOL isDragging;
	UIScrollView *_scrollView;
	IRefreshState headerRefreshState, footerRefreshState;
	UIEdgeInsets inset;
	BOOL allowRefresh;
}
@end

@implementation IPullRefresh

- (id)initWithScrollView:(UIScrollView *)scrollView{
	self = [self init];
	_scrollView = scrollView;
	_headerVisibleRateToRefresh = 1;
	_footerVisibleRateToRefresh = 1;
	allowRefresh = YES;
	return self;
}

- (CGFloat)headerVisibleRate{
	if(_headerView && _headerView.frame.size.height > 0){
		CGFloat visibleHeight = - (_scrollView.contentInset.top + _scrollView.contentOffset.y);
        
        //fix IOS 11 adjustedContentInset by xusion
        if (@available(iOS 11.0, *)) {
            visibleHeight = - (_scrollView.adjustedContentInset.top + _scrollView.contentOffset.y);
        }
        
		//log_trace(@"header: visibleHeight=%f height=%f", visibleHeight, _headerView.frame.size.height);
		CGFloat rate = visibleHeight / _headerView.frame.size.height;
		return rate;
	}
	return 0;
}

- (CGFloat)footerVisibleRate{
	if(_footerView && _footerView.frame.size.height > 0){
		CGFloat visibleHeight;
        
        //fix IOS 11 adjustedContentInset by xusion
        if (@available(iOS 11.0, *)) {
            if(_scrollView.contentSize.height + _scrollView.adjustedContentInset.top > _scrollView.frame.size.height){
                visibleHeight = _scrollView.contentOffset.y + _scrollView.frame.size.height - _scrollView.contentSize.height;
            }else{
                visibleHeight = _scrollView.contentOffset.y + _scrollView.adjustedContentInset.top;
            }
        }else{
            if(_scrollView.contentSize.height + _scrollView.contentInset.top > _scrollView.frame.size.height){
                visibleHeight = _scrollView.contentOffset.y + _scrollView.frame.size.height - _scrollView.contentSize.height;
            }else{
                visibleHeight = _scrollView.contentOffset.y + _scrollView.contentInset.top;
            }
        }
		
		//log_trace(@"footer: visibleHeight=%f height=%f", visibleHeight, _footerView.frame.size.height);
		//log_trace(@"footer.frame: %@, content: %f, offset: %f", NSStringFromCGRect(_footerView.frame), _scrollView.contentSize.height, _scrollView.contentOffset.y);
		CGFloat rate = visibleHeight / _footerView.frame.size.height;
		return rate;
	}
	return 0;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
	//log_trace(@"%s", __func__);
	if([self headerVisibleRate] > _headerVisibleRateToRefresh){
		if(headerRefreshState == IRefreshMaybe){
			[self setView:_headerView state:IRefreshBegin];
		}
	}
	
	if([self footerVisibleRate] > _footerVisibleRateToRefresh){
		if(footerRefreshState == IRefreshMaybe){
			[self setView:_footerView state:IRefreshBegin];
		}
	}
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
	//log_debug(@"%s", __func__);
	allowRefresh = YES;
}

- (void)scrollViewDidScroll:(UIScrollView*)scrollView{
	//log_trace(@"scroll.offset.y = %f", scrollView.contentOffset.y);

	if(_headerView){
		if(scrollView.tracking || _headerView.triggerMode == IRefreshTriggerScroll){
			CGFloat rate = [self headerVisibleRate];
			//log_debug(@"header = %f", rate);
			if(rate > _headerVisibleRateToRefresh){
				if(headerRefreshState == IRefreshNone){
					[self setView:_headerView state:IRefreshMaybe];
				}
				if(!scrollView.tracking){
					if(headerRefreshState == IRefreshMaybe){
						[self setView:_headerView state:IRefreshBegin];
					}
				}
			//}else if(rate > 0){
			}else{
				if(headerRefreshState == IRefreshMaybe){
					[self setView:_headerView state:IRefreshNone];
				}
			}
		}
	}
	
	if(_footerView){
		if(scrollView.tracking || _footerView.triggerMode == IRefreshTriggerScroll){
			CGFloat rate = [self footerVisibleRate];
			//log_debug(@"footer = %f", rate);
			if(rate > _footerVisibleRateToRefresh){
				if(footerRefreshState == IRefreshNone){
					[self setView:_footerView state:IRefreshMaybe];
				}
				if(!scrollView.tracking){
					if(footerRefreshState == IRefreshMaybe){
						[self setView:_footerView state:IRefreshBegin];
					}
				}
			//}else if(rate > 0){
			}else{
				if(footerRefreshState == IRefreshMaybe){
					[self setView:_footerView state:IRefreshNone];
				}
			}
		}
	}
}

- (void)setView:(IView *)view state:(IRefreshState)state{
	//log_trace(@"%s %d", __func__, state);
	if(state == IRefreshMaybe){
		if(!allowRefresh){
			return;
		}
	}
	
	// 不能同时进行两个刷新
	if(state == IRefreshBegin && (headerRefreshState == IRefreshBegin || footerRefreshState == IRefreshBegin)){
		return;
	}
	if(view == _headerView){
		headerRefreshState = state;
	}
	if(view == _footerView){
		footerRefreshState = state;
	}
	
	if([view isKindOfClass:[IRefreshControl class]]){
		[(IRefreshControl *)view setState:state];
	}

	if(state == IRefreshBegin){
		[self beginRefresh:view];
	}else{
		if(_delegate){
			[_delegate onRefresh:view state:state];
		}
	}
}

- (void)beginRefresh:(IView *)view{
	allowRefresh = NO;
	
	BOOL animation = NO;
	if(view == _headerView && _headerVisibleRateToRefresh > 0){
		animation = YES;
	}
	if(view == _footerView && _footerVisibleRateToRefresh > 0){
		animation = YES;
	}
	
	if(!animation){
		[_delegate onRefresh:view state:IRefreshBegin];
	}else{
		inset = _scrollView.contentInset;
		UIEdgeInsets tmp_inset = inset;
		CGPoint offset = CGPointZero;
		if(view == _headerView){
			tmp_inset.top += _headerView.frame.size.height * _headerVisibleRateToRefresh;
			offset.y = -tmp_inset.top;
		}else{
			tmp_inset.bottom = _footerView.frame.size.height * _footerVisibleRateToRefresh;
			
            //fix IOS 11 adjustedContentInset by xusion
            if (@available(iOS 11.0, *)) {
                if(_scrollView.contentSize.height + _scrollView.adjustedContentInset.top + _footerView.frame.size.height > _scrollView.frame.size.height){
                    offset.y = _footerView.frame.origin.y + _footerView.frame.size.height * _footerVisibleRateToRefresh - _scrollView.frame.size.height;
                }else{
                    offset.y = 0;
                }
            }else{
                if(_scrollView.contentSize.height + _scrollView.contentInset.top + _footerView.frame.size.height > _scrollView.frame.size.height){
                    offset.y = _footerView.frame.origin.y + _footerView.frame.size.height * _footerVisibleRateToRefresh - _scrollView.frame.size.height;
                }else{
                    offset.y = 0;
                }
            }
			
		}
		//log_debug(@"header.h: %.1f, footer.h: %.1f", _headerView.frame.size.height, _footerView.frame.size.height);
		//log_debug(@"inset.top: %.1f, frame.h: %.1f", _scrollView.contentInset.top, _scrollView.frame.size.height);
		//log_debug(@"offset.y: %.1f", offset.y);
		
		_scrollView.bounces = NO;
		[UIView animateWithDuration:0.2 animations:^(){
			// 在 iOS 7, 不能弄混 contentOffset 和 contentInset 的顺序
			_scrollView.contentOffset = offset;
			_scrollView.contentInset = tmp_inset;
		} completion:^(BOOL finished) {
			//log_trace(@"inset %@, offset: %@", NSStringFromUIEdgeInsets(_scrollView.contentInset), NSStringFromCGPoint(_scrollView.contentOffset));
			_scrollView.bounces = YES;
			// 要在回调中调用 delegate, 否则 delegate 处理比较快的话, 会导致屏幕跳动
			if(_delegate){
				[_delegate onRefresh:view state:IRefreshBegin];
			}
		}];
	}
}

- (void)beginRefreshControll:(IView *)view{
	[self setView:view state: IRefreshBegin];
	allowRefresh = YES;
}

- (void)endRefreshControll:(IView *)view{
	//log_trace(@"%s", __func__);
	if(view == _headerView && headerRefreshState != IRefreshNone){
		[self setView:view state:IRefreshNone];
	}else if(view == _footerView && footerRefreshState != IRefreshNone){
		[self setView:view state:IRefreshNone];
	}else{
		return;
	}
	[UIView animateWithDuration:0.2 animations:^(){
		_scrollView.contentInset = inset;
	}];
}
@end
