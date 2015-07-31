/*
 Copyright (c) 2014 ideawu. All rights reserved.
 Use of this source code is governed by a license that can be
 found in the LICENSE file.
 
 @author:  ideawu
 @website: http://www.cocoaui.com/
 */

#import "ITableInternal.h"
#import "ICell.h"
#import "IViewInternal.h"
#import "IStyleInternal.h"
#import "IPullRefresh.h"
#import "IRefreshControl.h"

@interface ITable() <UIScrollViewDelegate>{
	NSUInteger _visibleCellIndexMin;
	NSUInteger _visibleCellIndexMax;
	IPullRefresh *_pullRefresh;
	ICell *possibleSelectedCell;

	UIScrollView *_scrollView;
	// contentView 包裹着全部的 cells
	UIView *_contentView;
	// headerView 正常情况固定在顶部, 但下拉刷新时会向下滑动
	// footerView 永远固定在底部
	IView *_headerView, *_footerView;
	// headerRefreshControl 在第一个 cell 前面
	// footerRefreshControl 在最后一个 cell 后面
	IRefreshControl *_headerRefreshControl, *_footerRefreshControl;

	NSMutableArray *_cells;
	NSMutableDictionary *_tagViews;
	NSMutableDictionary *_tagClasses;
	
	CGRect _contentFrame;
	NSMutableArray *_cellSelectionEvents;
	
	UIView *_headerRefreshWrapper;
}
@end

@implementation ITable

- (id)init{
	self = [super init];
	_cells = [[NSMutableArray alloc] init];
	_tagViews = [[NSMutableDictionary alloc] init];
	_tagClasses = [[NSMutableDictionary alloc] init];

	_scrollView = [[UIScrollView alloc] init];
	_scrollView.frame = [UIScreen mainScreen].bounds;
	_scrollView.delegate = self;
	_scrollView.backgroundColor = [UIColor clearColor];
	_scrollView.scrollEnabled = YES;
	_scrollView.bounces = YES;
	_scrollView.alwaysBounceVertical = YES;
	//_scrollView.alwaysBounceHorizontal = YES;
	
	_contentView = [[UIView alloc] init];
	_contentFrame.size.width = [UIScreen mainScreen].bounds.size.width;
	
	_visibleCellIndexMin = NSUIntegerMax;
	_visibleCellIndexMax = 0;

	[_scrollView addSubview:_contentView];
	_cellSelectionEvents = [[NSMutableArray alloc] init];
	
	_headerRefreshWrapper = [[UIView alloc] init];
	[_scrollView addSubview:_headerRefreshWrapper];
	
	return self;
}

- (void)viewDidLoad{
	[super viewDidLoad];
	self.view.backgroundColor = [UIColor whiteColor];
	[self.view addSubview:_scrollView];
}

- (void)viewWillAppear:(BOOL)animated{
	[super viewWillAppear:animated];
	//NSLog(@"%s", __func__);
	[self layoutViews];
}

#pragma mark - datasource manipulating

- (void)registerViewClass:(Class)ivClass forTag:(NSString *)tag{
	[_tagClasses setObject:ivClass forKey:tag];
	
	NSMutableArray *views = [[NSMutableArray alloc] init];
	[_tagViews setObject:views forKey:tag];
}

- (void)addIViewRow:(IView *)view{
	[self addIViewRow:view defaultHeight:view.style.outerHeight];
}

- (void)addIViewRow:(IView *)view defaultHeight:(CGFloat)height{
	view.style.ratioWidth = 1.0;
	ICell *cell = [[ICell alloc] init];
	cell.contentView = view;
	[self addCell:cell defaultHeight:height];
}

- (void)addDataRow:(id)data forTag:(NSString *)tag{
	[self addDataRow:data forTag:tag defaultHeight:90];
}

- (void)addDataRow:(id)data forTag:(NSString *)tag defaultHeight:(CGFloat)height{
	ICell *cell = [[ICell alloc] init];
	cell.tag = tag;
	cell.data = data;
	[self addCell:cell defaultHeight:height];
}

- (void)addDivider:(NSString *)css{
	[self addDivider:css height:15]; // 默认高度 15
}

- (void)addDivider:(NSString *)css height:(CGFloat)height{
	IView *view = [[IView alloc] init];
	[view.style set:[NSString stringWithFormat:@"height: %f; background: #efeff4;", height]];
	[view.style set:css];
	ICell *cell = [[ICell alloc] init];
	cell.isSeparator = YES;
	cell.contentView = view;
	[self addCell:cell defaultHeight:view.style.outerHeight];
}

- (void)addSeparator:(NSString *)css{
	[self addDivider:css];
}

- (void)addSeparator:(NSString *)css height:(CGFloat)height{
	[self addDivider:css height:height];
}

- (void)addCell:(ICell *)cell defaultHeight:(CGFloat)height{
	_contentFrame.size.height += height;
	//log_debug(@"%s %.1f height: %.1f", __func__, height, _contentFrame.size.height);
	
	cell.height = height;
	cell.table = self;
	ICell *last = [_cells lastObject];
	if(last){
		cell.y = last.y + last.height;
	}
	[_cells addObject:cell];
}

- (void)insertCell:(ICell *)cell atIndex:(NSUInteger)index{
	_contentFrame.size.height += cell.height;
	cell.table = self;
	[_cells insertObject:cell atIndex:index];
	
	ICell *prev = nil;
	for(NSUInteger i=index; i<_cells.count; i++){
		ICell *cell = [_cells objectAtIndex:i];
		if(!prev){
			cell.y = 0;
		}else{
			cell.y = prev.y + prev.height;
		}
		prev = cell;
	}
	
	if(index <= _visibleCellIndexMin){
		CGPoint offset = _scrollView.contentOffset;
		offset.y += cell.height;
		_scrollView.contentOffset = offset;
	}
}

- (void)prependIViewRow:(IView *)view{
	[self prependIViewRow:view defaultHeight:90];
}

- (void)prependIViewRow:(IView *)view defaultHeight:(CGFloat)height{
	ICell *cell = [[ICell alloc] init];
	cell.contentView = view;
	cell.height = height;
	[self insertCell:cell atIndex:0];
}

- (void)prependDataRow:(id)data forTag:(NSString *)tag{
	[self prependDataRow:data forTag:tag defaultHeight:90];
}

- (void)prependDataRow:(id)data forTag:(NSString *)tag defaultHeight:(CGFloat)height{
	ICell *cell = [[ICell alloc] init];
	cell.tag = tag;
	cell.data = data;
	cell.height = height;
	[self insertCell:cell atIndex:0];
}

- (void)clear{
	for(NSUInteger i=_visibleCellIndexMin; i<=_visibleCellIndexMax; i++){
		ICell *cell = [_cells objectAtIndex:i];
		[cell.view removeFromSuperview];
		cell.view = nil;
		cell.contentView = nil;
	}
	[_cells removeAllObjects];
	_visibleCellIndexMin = NSUIntegerMax;
	_visibleCellIndexMax = 0;
	_contentFrame.size.height = 0;
}

- (void)reload{
	[self layoutViews];
}

#pragma mark - layout views

- (void)cell:(ICell *)cell didResizeHeightDelta:(CGFloat)delta{
	NSUInteger index = [_cells indexOfObject:cell];
	_contentFrame.size.height += delta;
	//log_debug(@"%s %d %.1f height: %.1f", __func__, (int)index, delta, _contentFrame.size.height);
	for(NSUInteger i=index; i<_cells.count; i++){
		ICell *cell = [_cells objectAtIndex:i];
		if(i != index){
			cell.y += delta;
		}
	}
	[self layoutViews];
}

- (void)addVisibleCellAtIndex:(NSUInteger)index{
	//log_debug(@"%s %d", __func__, (int)index);
	ICell *cell = [self cellForRowAtIndex:index];
	[_contentView addSubview:cell.view];
}

- (void)removeVisibleCellAtIndex:(NSUInteger)index{
	//log_debug(@"%s %d", __func__, (int)index);
	if(index >= _cells.count){
		return;
	}
	ICell *cell = [_cells objectAtIndex:index];
	if(cell.contentView){
		cell.contentView.cell = nil;
	}
	if(cell.view){
		[cell.view removeFromSuperview];
	}
	if(cell.tag){
		NSMutableArray *views = [_tagViews objectForKey:cell.tag];
		if(views.count < 3 && cell.view){
			[views addObject:cell.view];
			//log_debug(@"enqueue cell for tag: %@, count: %d", cell.tag, (int)views.count);
		}
		cell.contentView = nil;
		cell.view = nil;
	}
}

- (ICell *)cellForRowAtIndex:(NSUInteger)index{
	//log_debug(@"%s %d", __func__, (int)index);
	ICell *cell = [_cells objectAtIndex:index];
	if(!cell.view){
		if(cell.tag){
			NSMutableArray *views = [_tagViews objectForKey:cell.tag];
			if(views.count > 0){
				cell.view = views.lastObject;
				[views removeLastObject];
				cell.contentView = [cell.view.subviews objectAtIndex:0];
				[cell.contentView setNeedsLayout];
				//log_debug(@"dequeue cell for tag: %@, count: %d", cell.tag, (int)views.count);
			}else{
				cell.view = [[ICellView alloc] init];
				//cell.uiview.clipsToBounds = YES;
				Class cls = [_tagClasses objectForKey:cell.tag];
				if(cls){
					//log_trace(@"create new row class: %@", cls);
					cell.contentView = [[cls alloc] init];
					[cell.view addSubview:cell.contentView];
				}
			}
			if(cell.data && cell.contentView){
				cell.contentView.data = cell.data;
			}
		}else{
			cell.view = [[ICellView alloc] init];
			//cell.uiview.clipsToBounds = YES;
			if(cell.contentView){
				[cell.view addSubview:cell.contentView];
			}
		}
	}
	
	cell.view.cell = cell;
	if(cell.contentView){
		cell.contentView.cell = cell;
	}
	return cell;
}

- (void)layoutViews{
	_contentFrame.origin.y = 0;
	if(_headerView){
		_contentFrame.origin.y += _headerView.style.outerHeight;
	}
	if(self.view.superview){
		_contentFrame.size.width = self.view.superview.frame.size.width;
	}
	_contentView.frame = _contentFrame;
	
	CGSize scrollSize = _contentFrame.size;
	if(_headerView){
		scrollSize.height += _headerView.style.outerHeight;
	}
	if(_footerView){
		scrollSize.height += _footerView.style.outerHeight;
	}
	_scrollView.contentSize = scrollSize;
	//NSLog(@"scroll.height: %.1f", scrollSize.height);

	if(_scrollView.frame.size.height != self.view.frame.size.height){
		CGRect frame = _scrollView.frame;
		frame.size.height = self.view.frame.size.height;
		_scrollView.frame = frame;
	}

	//log_debug(@"%s frame: %.1f, offset: %.1f, size: %.1f, inset: %@", __func__, _scrollView.frame.size.height, _scrollView.contentOffset.y, _contentFrame.size.height, NSStringFromUIEdgeInsets(_scrollView.contentInset));
	
	CGFloat visibleHeight = _scrollView.frame.size.height - _scrollView.contentInset.top;
	CGFloat minVisibleY = _scrollView.contentOffset.y + _scrollView.contentInset.top - _contentView.frame.origin.y;
	CGFloat maxVisibleY = minVisibleY + visibleHeight;
	NSUInteger minVisibleIndex = NSUIntegerMax;
	NSUInteger maxVisibleIndex = 0;
	
	//NSLog(@"visible: %.1f, min: %.1f, max: %.1f", visibleHeight, minVisibleY, maxVisibleY);
	//_scrollView.layer.borderWidth = 2;
	//_scrollView.layer.borderColor = [UIColor yellowColor].CGColor;
	
	// 可优化, 不需要从0开始, 如二分查找
	for(NSUInteger i=0; i<_cells.count; i++){
		ICell *cell = [_cells objectAtIndex:i];
		CGFloat min_y = cell.y;
		CGFloat max_y = min_y + cell.height;
		if(min_y > maxVisibleY){
			// not visible
			break;
		}
		if(max_y < minVisibleY){
			// not visible
		}else{
			minVisibleIndex = MIN(minVisibleIndex, i);
			maxVisibleIndex = MAX(maxVisibleIndex, i);
		}
	}
	
	[self layoutVisibleCellsMinIndex:minVisibleIndex maxIndex:maxVisibleIndex];
	
	// 必须禁用动画
	[UIView setAnimationsEnabled:NO];
	for(NSUInteger i=_visibleCellIndexMin; i<=_visibleCellIndexMax; i++){
		ICell *cell = [_cells objectAtIndex:i];
		CGRect frame = CGRectMake(cell.x, cell.y, _scrollView.contentSize.width, cell.height);
		cell.view.frame = frame;
		//NSLog(@"%d %@", (int)i, NSStringFromCGRect(cell.uiview.frame));
		//NSLog(@"cell#%d y=%.1f", (int)i, cell.y);
	}
	[UIView setAnimationsEnabled:YES];
	
	[self layoutHeaderFooterRefreshControl];
	[self layoutHeaderFooterView];
}

- (void)layoutVisibleCellsMinIndex:(NSUInteger)minIndex maxIndex:(NSUInteger)maxIndex{
	if(_visibleCellIndexMin == minIndex && _visibleCellIndexMax == maxIndex){
		return;
	}
	//log_debug(@"visible.index: [%d, %d]=>[%d, %d]", (int)_visibleCellIndexMin, (int)_visibleCellIndexMax, (int)minIndex, (int)maxIndex);
	NSUInteger low = MIN(minIndex, _visibleCellIndexMin);
	NSUInteger high = MAX(maxIndex, _visibleCellIndexMax);
	for(NSUInteger index=low; index<=high; index++){
		ICell *cell = [_cells objectAtIndex:index];
		if(index < minIndex || index > maxIndex){
			if(cell.view.superview){
				[self removeVisibleCellAtIndex:index];
			}
		//}else if(index < _visibleCellIndexMin || index > _visibleCellIndexMax){
		}else{
			if(!cell.view.superview){
				[self addVisibleCellAtIndex:index];
			}
		}
	}
	_visibleCellIndexMin = minIndex;
	_visibleCellIndexMax = maxIndex;
}

#pragma mark - HeaderView and FooterView

- (IView *)headerView{
	return _headerView;
}

- (void)setHeaderView:(IView *)headerView{
	if(_headerView){
		[_headerView removeFromSuperview];
	}
	_headerView = headerView;
	if(_headerView){
		[_scrollView addSubview:_headerView];
		if(_scrollView.superview){
			[_headerView layoutSubviews];
			[self layoutHeaderFooterView];
		}
	}
}

- (IView *)footerView{
	return _footerView;
}

- (void)setFooterView:(IView *)footerView{
	if(footerView){
		[_footerView removeFromSuperview];
	}
	_footerView = footerView;
	if(_footerView){
		[_scrollView addSubview:_footerView];
		if(_scrollView.superview){
			[_footerView layoutSubviews];
			[self layoutHeaderFooterView];
		}
	}
}

- (void)layoutHeaderFooterView{
	//NSLog(@"%s", __func__);
	if(_headerView){
		CGFloat y = _scrollView.contentOffset.y + _scrollView.contentInset.top;
		if(y < 0){
			y = 0;
		}
		CGRect frame = _headerView.frame;
		frame.origin.y = y;
		_headerView.frame = frame;
	}
	if(_footerView){
		CGRect frame = _footerView.frame;
		// 锚定底部
		//CGPoint offset = _scrollView.contentOffset;
		//frame.origin.y = offset.y + _scrollView.frame.size.height - frame.size.height;
		//NSLog(@"offset: %.1f, %.1f", offset.y, frame.origin.y);
		// 不锚定底部
		frame.origin.y = _contentFrame.size.height + _contentFrame.origin.y;
		_footerView.frame = frame;
	}
}

#pragma mark - HeaderRefresh and FooterRefresh

- (void)scrollViewDidScroll:(UIScrollView*)scrollView{
	[self layoutViews];
	if(_pullRefresh){
		[_pullRefresh scrollViewDidScroll:scrollView];
	}
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
	if(_pullRefresh){
		[_pullRefresh scrollViewDidEndDecelerating:scrollView];
	}
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
	//log_trace(@"%s %d", __func__, decelerate);
	if(_pullRefresh){
		[_pullRefresh scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
	}
}

- (void)initPullRefresh{
	if(!_pullRefresh){
		_pullRefresh = [[IPullRefresh alloc] initWithScrollView:_scrollView];
		_pullRefresh.delegate = self;
	}
	_pullRefresh.headerView = _headerRefreshControl;
	_pullRefresh.footerView = _footerRefreshControl;
}

- (IRefreshControl *)headerRefreshControl{
	return _headerRefreshControl;
}

- (void)setHeaderRefreshControl:(IRefreshControl *)headerRefreshControl{
	//log_trace(@"%s %@", __func__, self);
	if(_headerRefreshControl){
		[_headerRefreshControl removeFromSuperview];
	}
	_headerRefreshControl = headerRefreshControl;
	[self initPullRefresh];
	
	if(_headerRefreshControl != nil){
		[_headerRefreshWrapper addSubview:_headerRefreshControl];
		if(_scrollView.superview){
			// layoutSubviews 之前, 必须有宽度
			CGRect frame = _headerRefreshWrapper.frame;
			frame.size.width = _scrollView.frame.size.width;
			_headerRefreshWrapper.frame = frame;
			
			[_headerRefreshControl layoutSubviews];
			[self layoutHeaderFooterRefreshControl];
		}
	}
}

- (IRefreshControl *)footerRefreshControl{
	return _footerRefreshControl;
}

- (void)setFooterRefreshControl:(IRefreshControl *)footerRefreshControl{
	//log_trace(@"%s %@", __func__, self);
	if(_footerRefreshControl){
		if(_footerRefreshControl.style.top != 0){
			// TODO: 这里有问题, 删除 footer 时没有更新 contentInset
		}
		[_footerRefreshControl removeFromSuperview];
	}
	_footerRefreshControl = footerRefreshControl;
	[self initPullRefresh];
	
	if(_footerRefreshControl != nil){
		if(_footerRefreshControl.style.top != 0){
			// TODO: 这里有问题, 删除 footer 时没有更新 contentInset
			UIEdgeInsets padding = _scrollView.contentInset;
			padding.bottom = - _footerRefreshControl.style.top;
			_scrollView.contentInset = padding;
		}
		
		[_scrollView addSubview:_footerRefreshControl];
		if(_scrollView.superview){
			[_footerRefreshControl layoutSubviews];
			[self layoutHeaderFooterRefreshControl];
		}
	}
}

- (void)layoutHeaderFooterRefreshControl{
	//log_trace(@"%s", __func__);
	if(_headerRefreshControl){
		CGFloat y = _scrollView.contentOffset.y + _scrollView.contentInset.top;
		if(y < 0){
			y = 0;
		}
		CGRect frame = _headerRefreshControl.frame;
		frame.origin.y = y - _headerRefreshControl.frame.size.height;
		_headerRefreshWrapper.frame = frame;
	}
	
	if(_footerRefreshControl){
		CGFloat y = _scrollView.contentSize.height;
		if(_footerRefreshControl.style.top != y){
			[_footerRefreshControl.style set:[NSString stringWithFormat:@"top: %f", y]];
		}
	}
}

#pragma mark - Event hanlders

- (void)onHighlight:(IView *)view{
	//log_trace(@"%s", __func__);
}

- (void)onUnhighlight:(IView *)view{
	//log_trace(@"%s", __func__);
}

- (void)onClick:(IView *)view{
	//log_trace(@"%s", __func__);
}

- (void)onRefresh:(IRefreshControl *)refreshControl state:(IRefreshState)state{
	//log_trace(@"%s %d", __func__, state);
	//[self layoutHeaderAndFooter];
	if(state == IRefreshBegin){
		[self endRefresh:refreshControl];
	}
}

- (void)endRefresh:(IRefreshControl *)refreshControl{
	if(_pullRefresh){
		[_pullRefresh endRefresh:refreshControl];
		[UIView animateWithDuration:0.2 animations:^(){
			[self layoutHeaderFooterRefreshControl];
			[self layoutHeaderFooterView];
		} completion:^(BOOL finished){
		}];
	}
}

@end
