/*
 Copyright (c) 2014 ideawu. All rights reserved.
 Use of this source code is governed by a license that can be
 found in the LICENSE file.
 
 @author:  ideawu
 @website: http://www.cocoaui.com/
 */

#import "ITablePullRefreshDemo.h"
#import "IObj.h"

@interface ITablePullRefreshItem : IView{
}
@property ILabel *num;
@property IButton *btn_1;
@property IButton *btn_2;
@property IButton *btn_3;
@property IButton *btn_4;
@property IView *div;
@end
@implementation ITablePullRefreshItem
- (id)init{
	self = [super init];
	IView *view = [IView namedView:@"ITablePullRefreshItem"];
	[self addSubview:view];
	
	_num = (ILabel *)[view getViewById:@"seq"];
	_btn_1 = (IButton *)[view getViewById:@"btn_1"];
	_btn_2 = (IButton *)[view getViewById:@"btn_2"];
	_btn_3 = (IButton *)[view getViewById:@"btn_3"];
	_btn_4 = (IButton *)[view getViewById:@"btn_4"];
	_div = (IView *)[view getViewById:@"div"];
	
	__weak typeof(self) me = self;
	[_btn_1 addEvent:IEventClick handler:^(IEventType event, IView *view) {
		NSString *s = me.num.text;
		if(s.length > 2){
			s = [s substringToIndex:s.length - 2];
			me.num.text = s;

			IObj *obj = (IObj *)me.data;
			obj.strval = s;
		}
	}];
	[_btn_2 addEvent:IEventClick handler:^(IEventType event, IView *view) {
		NSString *s = me.num.text;
		s = [s stringByAppendingFormat:@"\na"];
		me.num.text = s;
		
		IObj *obj = (IObj *)me.data;
		obj.strval = s;
	}];
	
	IView *div2 = (IView *)[view getViewById:@"div2"];

	[_btn_3 addEvent:IEventClick handler:^(IEventType event, IView *view) {
		//me.div.style.width -= 20;
		//[div2.style removeClass:@"a"];
	}];
	[_btn_4 addEvent:IEventClick handler:^(IEventType event, IView *view) {
		me.div.style.width += 20;
		[div2.style addClass:@"a"];
	}];
	
	
	NSArray *arr = @[@"x", @"y", @"z"];
	for(NSString *s in arr){
		ILabel *label = [ILabel labelWithText:s];
		[label.style addClass:s];
		[div2 addSubview:label];
	}

	
	return self;
}

- (void)setData:(id)data{
	[super setData:data];
	IObj *obj = (IObj *)self.data;
	_num.text = obj.strval;
}

@end


////////////////////////////////////////////////


@interface ITablePullRefreshDemo (){
	int _seq;
}
@end

@implementation ITablePullRefreshDemo

- (id)init{
	self = [super init];
	self.navigationItem.title = @"ITablePullRefreshDemo";
	self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
	
	{
		ITableRow *headerRow = [[ITableRow alloc] initWithNumberOfColumns:3];
		[headerRow.style set:@"height: 30; font-weight: bold; text-align: center; background: #6cf;"];
		[headerRow column:0 setText:@"Id"];
		[headerRow column:1 setText:@"Name"];
		[headerRow column:2 setText:@"Age"];
		self.headerView = headerRow;
	}
	{
		self.pullRefresh.footerTriggerMode = IRefreshTriggerPull;
		ILabel *label = [ILabel labelWithText:@"footer"];
		[label.style set:@"padding: 10; width: 100%; background: #cc6; text-align: center;"];
		self.footerView = label;
	}
	[self initHeaderFooter];

	[self registerViewClass:[ITablePullRefreshItem class] forTag:@"item"];

	//self.pullRefresh.footerVisibleRateToRefresh = -1;

	[self loadData:1];
	
	return self;
}

- (void)loadData:(int)count{
	static int seq = 0;
	for(int i=0; i<count; i++){
		NSString *s = [NSString stringWithFormat:@"%d", seq];
		IObj *obj = [IObj stringObj:s];
		[self addDataRow:obj forTag:@"item"];
		seq ++;
	}
}

- (void)initHeaderFooter{
	if(!self.headerRefreshControl){
		IRefreshControl *header = [[IRefreshControl alloc] init];
		[header.style set:@"background: #333;"];
		self.headerRefreshControl = header;
	}
	if(!self.footerRefreshControl){
		IRefreshControl *footer = [[IRefreshControl alloc] init];
		[footer setStateTextForNone:@"Pull up to load more"
							  maybe:@"Release to load more"
							  begin:@"loading..."];
		[footer.style set:@"top: -40;"];
		self.footerRefreshControl = footer;
	}
}

- (void)onRefresh:(IRefreshControl *)view state:(IRefreshState)state{
	if(state == IRefreshBegin){
		// refresh
		if(view == self.headerRefreshControl){
			[self performSelector:@selector(reloadData) withObject:nil afterDelay:0.2];
			return;
		}
		// load more
		if(view == self.footerRefreshControl){
			[self loadData:5];
		}
		[self reload];
		[self endRefresh:view];
	}
}

- (void)onClick:(IView *)view atIndex:(NSUInteger)index{
	NSLog(@"%s %d", __func__, (int)index);
	//[self removeCellAtIndex:index];
	//[self reload];
}

- (void)reloadData{
	//[self clear];
	//[self loadData:20];
	
	static int seq = 1000;
	for(int i=0; i<5; i++){
		NSString *s = [NSString stringWithFormat:@"%d", seq];
		IObj *obj = [IObj stringObj:s];
		[self prependDataRow:obj forTag:@"item"];
		seq ++;
	}
	
	
	[self reload];
	[self endRefresh:self.headerRefreshControl];
}

@end
