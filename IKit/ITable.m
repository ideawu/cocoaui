/*
 Copyright (c) 2014 ideawu. All rights reserved.
 Use of this source code is governed by a license that can be
 found in the LICENSE file.
 
 @author:  ideawu
 @website: http://www.cocoaui.com/
 */

#import "ITableInternal.h"
#import "ITableCell.h"
#import "IViewInternal.h"
#import "IStyleInternal.h"
#import "IPullRefresh.h"
#import "IRefreshControl.h"
#import "ITableView.h"

@interface ITable() <UIScrollViewDelegate, IPullRefreshDelegate>{
	NSUInteger _visibleCellIndexMin;
	NSUInteger _visibleCellIndexMax;
	IPullRefresh *_pullRefresh;
	ITableCell *possibleSelectedCell;
	
	ITableView *_tableView;

	// contentView 包裹着全部的 cells
	UIView *_contentView;
	
	// headerView 正常情况固定在顶部, 但下拉刷新时会向下滑动
	// footerView 所有内容(row)的后面
	IView *_headerView, *_footerView;

	// headerRefreshControl 在第一个 cell 前面
	// footerRefreshControl 在最后一个 cell 后面
	IRefreshControl *_headerRefreshControl, *_footerRefreshControl;

	NSMutableDictionary *_tagViews;
	NSMutableDictionary *_tagClasses;
	
	CGRect _contentFrame;
	NSMutableArray *_cellSelectionEvents;
	
	UIView *_headerRefreshWrapper;
	int fps;
	BOOL _forceLayoutCell;
}
@end

@implementation ITable

- (id)init{
	self = [super init];
	_cells = [[NSMutableArray alloc] init];
	_tagViews = [[NSMutableDictionary alloc] init];
	_tagClasses = [[NSMutableDictionary alloc] init];
	_visibleCellIndexMin = NSUIntegerMax;
	_visibleCellIndexMax = 0;
	_cellSelectionEvents = [[NSMutableArray alloc] init];
	_forceLayoutCell = YES;
	
	return self;
}

- (void)loadView{
	_tableView = [[ITableView alloc] init];
	_tableView.table = self;
	
	self.view = _tableView;
	
	_scrollView = _tableView.scrollView;
	_scrollView.delegate = self;
	
	_contentView = [[UIView alloc] init];
	[_scrollView addSubview:_contentView];
	
	_headerRefreshWrapper = [[UIView alloc] init];
	[_scrollView addSubview:_headerRefreshWrapper];
	
	_contentFrame.size.width = [UIScreen mainScreen].bounds.size.width;
}

- (void)viewWillAppear:(BOOL)animated{
	//log_debug(@"%s", __func__);
	[super viewWillAppear:animated];
	[self layoutViews];
}

- (void)viewDidAppear:(BOOL)animated{
	//log_debug(@"%s", __func__);
	[super viewDidAppear:animated];
	[self layoutViews];
}

#pragma mark - datasource manipulating

- (void)clear{
	for(NSUInteger i=_visibleCellIndexMin; i<=_visibleCellIndexMax; i++){
		ITableCell *cell = [_cells objectAtIndex:i];
		[cell.view removeFromSuperview];
		cell.view = nil;
		cell.contentView = nil;
	}
	[_cells removeAllObjects];
	_visibleCellIndexMin = NSUIntegerMax;
	_visibleCellIndexMax = 0;
	_contentFrame.size.height = 0;
	[self reload];
}

- (void)reload{
	[self layoutViews];
}

- (NSUInteger)count{
	return _cells.count;
}

- (void)scrollToRowAtIndex:(NSUInteger)index animated:(BOOL)animated{
	if(index >= _cells.count){
		return;
	}
	ITableCell *cell = _cells[index];
	CGRect frame = CGRectMake(0, cell.y, _contentFrame.size.width, cell.height);
	[self.scrollView scrollRectToVisible:frame animated:animated];
}

- (void)removeRowAtIndex:(NSUInteger)index{
	[self removeRowAtIndex:index animated:YES];
}

- (void)removeRowAtIndex:(NSUInteger)index animated:(BOOL)animated{
	ITableCell *cell = [_cells objectAtIndex:index];
	if(!cell){
		return;
	}
	
	/*
	[cell.view setUserInteractionEnabled:NO];
	[UIView animateWithDuration:0.15 animations:^(){
		cell.view.layer.opacity = 0.1;
	} completion:^(BOOL finished) {
		cell.height = 0;
		
		[cell.view removeFromSuperview];
		cell.view = nil;
		cell.contentView = nil;
		[_cells removeObjectAtIndex:cell.index];
		[self reload];
	}];
	*/
	
	CGFloat duration = 0.15;
	CGFloat steps = 8;
	CGFloat step_size = cell.height / steps;
	CGFloat interval = duration / steps;
	if(!animated){
		interval = 0;
		step_size = cell.height;
	}
	[cell.view setUserInteractionEnabled:NO];
	[UIView animateWithDuration:duration animations:^(){
		cell.view.layer.opacity = 0.2;
	}];
	_forceLayoutCell = NO;
	[NSTimer scheduledTimerWithTimeInterval:interval
									 target:self
								   selector:@selector(removeRowTimerTick:)
								   userInfo:@[cell, @(step_size)]
									repeats:YES];
}

- (void)removeRowTimerTick:(NSTimer *)timer{
	NSArray *arr = (NSArray *)timer.userInfo;
	ITableCell *cell = (ITableCell *)arr[0];
	CGFloat step_size = ((NSNumber *)arr[1]).floatValue;
	
	cell.height -= step_size;
	cell.contentView.style.height -= step_size;
	if(cell.contentView.style.height <= 0){
		cell.height = 0;
		
		[cell.view removeFromSuperview];
		cell.view = nil;
		cell.contentView = nil;
		[_cells removeObjectAtIndex:cell.index];
		
		_forceLayoutCell = YES;
		[self reload];
		
		[timer invalidate];
		timer = nil;
	}
}

- (void)removeRowContainsUIView:(UIView *)view{
	[self removeRowContainsUIView:view animated:YES];
}

- (void)removeRowContainsUIView:(UIView *)view animated:(BOOL)animated{
	while(view != nil){
		if([view isKindOfClass:[ITableCellView class]]){
			NSUInteger index = [[(ITableCellView *)view cell] index];
			[self removeRowAtIndex:index animated:animated];
			break;
		}
		view = view.superview;
	}
}

- (void)registerViewClass:(Class)ivClass forTag:(NSString *)tag{
	[_tagClasses setObject:ivClass forKey:tag];
	
	NSMutableArray *views = [[NSMutableArray alloc] init];
	[_tagViews setObject:views forKey:tag];
}

- (void)addIViewRow:(IView *)view{
	[self insertIViewRow:view atIndex:_cells.count defaultHeight:view.style.outerHeight];
}

- (void)addIViewRow:(IView *)view defaultHeight:(CGFloat)height{
	[self insertIViewRow:view atIndex:_cells.count defaultHeight:height];
}

- (void)addDataRow:(id)data forTag:(NSString *)tag{
	[self insertDataRow:data forTag:tag atIndex:_cells.count];
}

- (void)addDataRow:(id)data forTag:(NSString *)tag defaultHeight:(CGFloat)height{
	[self insertDataRow:data forTag:tag atIndex:_cells.count defaultHeight:height];
}

- (void)prependIViewRow:(IView *)view{
	[self insertIViewRow:view atIndex:0 defaultHeight:view.style.outerHeight];
}

- (void)prependIViewRow:(IView *)view defaultHeight:(CGFloat)height{
	[self insertIViewRow:view atIndex:0 defaultHeight:height];
}

- (void)prependDataRow:(id)data forTag:(NSString *)tag{
	[self insertDataRow:data forTag:tag atIndex:0];
}

- (void)prependDataRow:(id)data forTag:(NSString *)tag defaultHeight:(CGFloat)height{
	[self insertDataRow:data forTag:tag atIndex:0 defaultHeight:height];
}

- (void)updateIViewRow:(IView *)view atIndex:(NSUInteger)index{
	ITableCell *cell = [_cells objectAtIndex:index];
	if(!cell){
		return;
	}
	cell.contentView = view;
}

- (void)updateDataRow:(id)data forTag:(NSString *)tag atIndex:(NSUInteger)index{
	ITableCell *cell = [_cells objectAtIndex:index];
	if(!cell){
		return;
	}
	cell.tag = tag;
	cell.data = data;
	[cell.contentView setDataInternal:cell.data];
	cell.contentView.data = cell.data;
}

- (void)insertIViewRow:(IView *)view atIndex:(NSUInteger)index{
	[self insertIViewRow:view atIndex:index defaultHeight:90];
}

- (void)insertIViewRow:(IView *)view atIndex:(NSUInteger)index defaultHeight:(CGFloat)height{
	ITableCell *cell = [[ITableCell alloc] init];
	cell.contentView = view;
	[self insertCell:cell atIndex:index defaultHeight:height];
}

- (void)insertDataRow:(id)data forTag:(NSString *)tag atIndex:(NSUInteger)index{
	[self insertDataRow:data forTag:tag atIndex:index defaultHeight:90];
}

- (void)insertDataRow:(id)data forTag:(NSString *)tag atIndex:(NSUInteger)index defaultHeight:(CGFloat)height{
	ITableCell *cell = [[ITableCell alloc] init];
	cell.tag = tag;
	cell.data = data;
	[self insertCell:cell atIndex:index defaultHeight:height];
}

- (void)insertCell:(ITableCell *)cell atIndex:(NSUInteger)index defaultHeight:(CGFloat)height{
	// 先设置 height, 再设置 table. 如果弄反了, setHeight() 方法会自动更新 _contentFrame
	cell.height = height;
	cell.table = self;
	[_cells insertObject:cell atIndex:index];
	
	ITableCell *prev = nil;
	if(index > 0){
		prev = [_cells objectAtIndex:index-1];
	}
	for(NSUInteger i=index; i<_cells.count; i++){
		ITableCell *cell = [_cells objectAtIndex:i];
		if(!prev){
			cell.y = 0;
		}else{
			cell.y = prev.y + prev.height;
		}
		prev = cell;
	}
	
	_contentFrame.size.height += cell.height;
	
	// 更新 contentOffset, 以便使可视区域不变
	if(_cells.count > 1 && index <= _visibleCellIndexMin){
		CGPoint offset = _scrollView.contentOffset;
		offset.y += cell.height;
		_scrollView.contentOffset = offset;
	}
	
	[self layoutViews];
}


- (void)addDivider:(NSString *)css{
	[self addDivider:css height:15]; // 默认高度 15
}

- (void)addDivider:(NSString *)css height:(CGFloat)height{
	IView *view = [[IView alloc] init];
	[view.style set:[NSString stringWithFormat:@"height: %f; background: #efeff4;", height]];
	[view.style set:css];
	ITableCell *cell = [[ITableCell alloc] init];
	cell.isSeparator = YES;
	cell.contentView = view;
	[self insertCell:cell atIndex:_cells.count defaultHeight:view.style.outerHeight];
}

- (void)addSeparator:(NSString *)css{
	[self addDivider:css];
}

- (void)addSeparator:(NSString *)css height:(CGFloat)height{
	[self addDivider:css height:height];
}


#pragma mark - layout views

- (void)cell:(ITableCell *)cell didResizeHeightDelta:(CGFloat)delta{
	NSUInteger index = [_cells indexOfObject:cell];
	_contentFrame.size.height += delta;
	//log_debug(@"%s %d %.1f height: %.1f", __func__, (int)index, delta, _contentFrame.size.height);
	for(NSUInteger i=index; i<_cells.count; i++){
		ITableCell *cell = [_cells objectAtIndex:i];
		if(i != index){
			cell.y += delta;
		}
	}
	[self layoutViews];
}

- (void)addVisibleCellAtIndex:(NSUInteger)index{
	//log_debug(@"%s %d", __func__, (int)index);
	ITableCell *cell = [self cellForRowAtIndex:index];
	[_contentView addSubview:cell.view];
	[cell.contentView setNeedsLayout];
}

- (void)removeVisibleCellAtIndex:(NSUInteger)index{
	//log_debug(@"%s %d", __func__, (int)index);
	if(index >= _cells.count){
		return;
	}
	ITableCell *cell = [_cells objectAtIndex:index];
	if(cell.contentView){
		[cell.contentView setDataInternal:nil];
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

- (ITableCell *)cellForRowAtIndex:(NSUInteger)index{
	//log_debug(@"%s %d", __func__, (int)index);
	ITableCell *cell = [_cells objectAtIndex:index];
	if(!cell.view){
		if(cell.tag){
			NSMutableArray *views = [_tagViews objectForKey:cell.tag];
			if(views.count > 0){
				cell.view = views.lastObject;
				[views removeLastObject];
				cell.contentView = [cell.view.subviews objectAtIndex:0];
				//log_debug(@"dequeue cell for tag: %@, count: %d", cell.tag, (int)views.count);
			}else{
				cell.view = [[ITableCellView alloc] init];
				//cell.uiview.clipsToBounds = YES;
				Class cls = [_tagClasses objectForKey:cell.tag];
				if(cls){
					//log_trace(@"create new row class: %@", cls);
					cell.contentView = [[cls alloc] init];
					[cell.contentView.style set:@"width: 100%;"];
					[cell.view addSubview:cell.contentView];
				}
			}
		}else{
			cell.view = [[ITableCellView alloc] init];
			//cell.uiview.clipsToBounds = YES;
			if(cell.contentView){
				[cell.contentView.style set:@"width: 100%;"];
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
	//log_debug(@"%s", __func__);
	
	_contentFrame.origin.y = 0;
	if(_headerView){
		_contentFrame.origin.y += _headerView.style.outerHeight;
	}
	_contentFrame.size.width = self.view.frame.size.width;
	_contentView.frame = _contentFrame;

	
	CGSize scrollSize = _contentFrame.size;
	if(_headerView){
		scrollSize.height += _headerView.style.outerHeight;
	}
	if(_footerView){
		scrollSize.height += _footerView.style.outerHeight;
	}
	_scrollView.contentSize = scrollSize;

	//log_debug(@"%s frame: %.1f, offset: %.1f, size: %.1f, inset: %@", __func__, _scrollView.frame.size.height, _scrollView.contentOffset.y, _contentFrame.size.height, NSStringFromUIEdgeInsets(_scrollView.contentInset));

	[self constructVisibleCells];

	// 必须禁用动画
	[UIView setAnimationsEnabled:NO];
	[self layoutVisibleCells];
	[UIView setAnimationsEnabled:YES];
	
	[self layoutHeaderFooterRefreshControl];
	[self layoutHeaderFooterView];
}

- (void)layoutVisibleCells{
	for(NSUInteger i=_visibleCellIndexMin; i<=_visibleCellIndexMax; i++){
		ITableCell *cell = [_cells objectAtIndex:i];
		CGRect old_frame = cell.view.frame;
		CGRect frame = CGRectMake(cell.x, cell.y, _scrollView.contentSize.width, cell.height);
		if(cell.contentView && !CGRectEqualToRect(old_frame, frame)){
			cell.view.frame = frame;
			if(_forceLayoutCell){
				[cell.contentView setNeedsLayout];
			}
		}
		//log_debug(@"%d %@", (int)i, NSStringFromCGRect(cell.view.frame));
		//log_debug(@"cell#%d y=%.1f", (int)i, cell.y);

		if(cell.data && cell.contentView && !cell.contentView.data){
			[cell.contentView setDataInternal:cell.data];
			cell.contentView.data = cell.data;
		}

		if(cell.contentView && cell.contentView.style.ratioHeight > 0){
			CGRect frame = cell.view.frame;
			//UIEdgeInsets insets = cell.table.scrollView.contentInset;
			//frame.size.height = cell.table.scrollView.frame.size.height - insets.top - insets.bottom;
			frame.size.height = cell.table.view.frame.size.height;
			if(cell.view.frame.size.height != frame.size.height){
				cell.view.frame = frame;
				if(_forceLayoutCell){
					[cell.contentView setNeedsLayout];
				}
				//log_debug(@"%.1f=>%.1f", cell.height, frame.size.height);
			}
		}
	}
}

- (void)constructVisibleCells{
	CGFloat visibleHeight = _scrollView.frame.size.height - _scrollView.contentInset.top;
	CGFloat minVisibleY = _scrollView.contentOffset.y + _scrollView.contentInset.top - _contentView.frame.origin.y;
    
	//fix IOS 11 adjustedContentInset by xusion
	if (@available(iOS 11.0, *)) {
		visibleHeight = _scrollView.frame.size.height - _scrollView.adjustedContentInset.top;
		minVisibleY = _scrollView.contentOffset.y + _scrollView.adjustedContentInset.top - _contentView.frame.origin.y;
	}
    
	CGFloat maxVisibleY = minVisibleY + visibleHeight;
	NSUInteger minIndex = NSUIntegerMax;
	NSUInteger maxIndex = 0;

	//log_debug(@"visible: %.1f, min: %.1f, max: %.1f", visibleHeight, minVisibleY, maxVisibleY);
	//_scrollView.layer.borderWidth = 2;
	//_scrollView.layer.borderColor = [UIColor yellowColor].CGColor;
	
	// 预先加载不可见区域
	minVisibleY -= visibleHeight/4;
	maxVisibleY += visibleHeight/4;

	// 可优化, 不需要从0开始, 如二分查找
	for(NSUInteger i=0; i<_cells.count; i++){
		ITableCell *cell = [_cells objectAtIndex:i];
		CGFloat min_y = cell.y;
		CGFloat max_y = min_y + cell.height;
		if(min_y > maxVisibleY){
			// not visible
			break;
		}
		if(max_y < minVisibleY){
			// not visible
		}else{
			minIndex = MIN(minIndex, i);
			maxIndex = MAX(maxIndex, i);
		}
	}
	if(_visibleCellIndexMin == minIndex && _visibleCellIndexMax == maxIndex){
		return;
	}

	//log_debug(@"visible.index: [%d, %d]=>[%d, %d]", (int)_visibleCellIndexMin, (int)_visibleCellIndexMax, (int)minIndex, (int)maxIndex);
	NSUInteger low = MIN(minIndex, _visibleCellIndexMin);
	NSUInteger high = MAX(maxIndex, _visibleCellIndexMax);
	
	for(NSUInteger index=low; index<=high; index++){
		if(index >= _cells.count){
			break;
		}
		ITableCell *cell = [_cells objectAtIndex:index];
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

- (IView *)bottomBar{
	return _tableView.bottomBar;
}

- (void)setBottomBar:(IView *)bottomBar{
	_tableView.bottomBar = bottomBar;
}

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
	if(_footerView){
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
	//log_debug(@"%s", __func__);
	if(_headerView){
		CGFloat y = _scrollView.contentOffset.y + _scrollView.contentInset.top;
        
		//fix IOS 11 adjustedContentInset by xusion
		if (@available(iOS 11.0, *)) {
			y = _scrollView.contentOffset.y + _scrollView.adjustedContentInset.top;
		}
        
		if(y < 0){
			y = 0;
		}
		CGRect frame = _headerView.frame;
		//frame.size.width = _scrollView.contentSize.width;
		frame.origin.y = y;
		_headerView.frame = frame;
		
		if(_headerView.frame.size.width != _scrollView.contentSize.width){
			[_headerView setNeedsLayout];
		}
	}
	if(_footerView){
		// 锚定底部
		//CGFloat y = _scrollView.contentOffset.y + _scrollView.frame.size.height - _footerView.frame.size.height;
		// 不锚定底部
		CGFloat y = _contentFrame.size.height + _contentFrame.origin.y;
		if(_footerView.style.top != y){
			[_footerView.style set:[NSString stringWithFormat:@"top: %f", y]];
		}

		if(_footerView.frame.size.width != _scrollView.contentSize.width){
			[_footerView setNeedsLayout];
		}
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

- (IPullRefresh *)pullRefresh{
	if(!_pullRefresh){
		[self initPullRefresh];
	}
	return _pullRefresh;
}

- (void)initPullRefresh{
	if(!_pullRefresh){
		_pullRefresh = [[IPullRefresh alloc] initWithScrollView:_scrollView];
		_pullRefresh.delegate = self;
	}
	_pullRefresh.headerView = _headerRefreshControl;
	_pullRefresh.footerView = _footerRefreshControl;
	_headerRefreshControl.pullRefresh = _pullRefresh;
	_footerRefreshControl.pullRefresh = _pullRefresh;
	_headerRefreshControl.table = self;
	_footerRefreshControl.table = self;
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
        
		//fix IOS 11 adjustedContentInset by xusion
		if (@available(iOS 11.0, *)) {
			y = _scrollView.contentOffset.y + _scrollView.adjustedContentInset.top;
		}
        
		if(y < 0){
			y = 0;
		}
		CGRect frame = _headerRefreshControl.frame;
		frame.size.width = _scrollView.contentSize.width;
		frame.origin.y = y - _headerRefreshControl.frame.size.height;
		_headerRefreshWrapper.frame = frame;
		
		if(_headerRefreshControl.frame.size.width != _scrollView.contentSize.width){
			[_headerRefreshControl setNeedsLayout];
		}
	}
	
	if(_footerRefreshControl){
		CGFloat y = _scrollView.contentSize.height;
		if(_footerRefreshControl.style.top != y){
			[_footerRefreshControl.style set:[NSString stringWithFormat:@"top: %f", y]];
		}
		
		if(_footerRefreshControl.frame.size.width != _scrollView.contentSize.width){
			[_footerRefreshControl setNeedsLayout];
		}
	}
}

#pragma mark - Event hanlders

- (void)onHighlight:(IView *)view atIndex:(NSUInteger)index{
	[self onHighlight:view];
	if(_delegate && [_delegate respondsToSelector:@selector(table:onHighlight:atIndex:)]){
		[_delegate table:self onHighlight:view atIndex:index];
	}
}

- (void)onUnhighlight:(IView *)view atIndex:(NSUInteger)index{
	[self onUnhighlight:view];
	if(_delegate && [_delegate respondsToSelector:@selector(table:onUnhighlight:atIndex:)]){
		[_delegate table:self onUnhighlight:view atIndex:index];
	}
}

- (void)onClick:(IView *)view atIndex:(NSUInteger)index{
	[self onClick:view];
	if(_delegate && [_delegate respondsToSelector:@selector(table:onClick:atIndex:)]){
		[_delegate table:self onClick:view atIndex:index];
	}
}

- (void)beginRefresh:(IRefreshControl *)refreshControl{
	[refreshControl beginRefresh];
}

- (void)endRefresh:(IRefreshControl *)refreshControl{
	[refreshControl endRefresh];
	// 如果没有动画, prepend 之后RefreshControl收回时不会显示动画.
	[UIView animateWithDuration:0.2 animations:^(){
		//[self layoutHeaderFooterRefreshControl];
		//[self layoutHeaderFooterView];
		[self layoutViews];
	} completion:^(BOOL finished){
	}];
}

- (void)onRefresh:(IRefreshControl *)refreshControl state:(IRefreshState)state{
	//log_trace(@"%s %d", __func__, state);
	//[self layoutHeaderAndFooter];
	if(_delegate && [_delegate respondsToSelector:@selector(table:onRefresh:state:)]){
		[_delegate table:self onRefresh:refreshControl state:state];
	}
}

// @deprecated
- (void)onHighlight:(IView *)view{
	//log_trace(@"%s", __func__);
}

// @deprecated
- (void)onUnhighlight:(IView *)view{
	//log_trace(@"%s", __func__);
}

// @deprecated
- (void)onClick:(IView *)view{
	//log_trace(@"%s", __func__);
}

@end
