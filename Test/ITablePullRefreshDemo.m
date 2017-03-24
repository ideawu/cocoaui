/*
 Copyright (c) 2014 ideawu. All rights reserved.
 Use of this source code is governed by a license that can be
 found in the LICENSE file.
 
 @author:  ideawu
 @website: http://www.cocoaui.com/
 */

#import "ITablePullRefreshDemo.h"
#import "IObj.h"
#import "ITablePullRefreshItem.h"


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
		ILabel *label = [ILabel labelWithText:@"footer"];
		[label.style set:@"padding: 10; width: 100%; background: #cc6; text-align: center;"];
		self.footerView = label;
	}
	{
		ILabel *label = [ILabel labelWithText:@"BottomBar"];
		[label.style set:@"padding: 10; height: 70; width: 100%; background: #6cf; text-align: center;"];
		self.bottomBar = label;
	}
	[self initHeaderFooter];

	[self registerViewClass:[ITablePullRefreshItem class] forTag:@"item"];

	//self.pullRefresh.footerVisibleRateToRefresh = -1;

	[self loadData:10];
	
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
		self.footerRefreshControl.triggerMode = IRefreshTriggerPull;
	}
}

- (void)onRefresh:(IRefreshControl *)view state:(IRefreshState)state{
	if(state == IRefreshBegin){
		// refresh
		if(view == self.headerRefreshControl){
			// 模拟网络请求
			dispatch_after(1.5, dispatch_get_main_queue(), ^(void){
				static int seq = 1000;
				for(int i=0; i<5; i++){
					NSString *s = [NSString stringWithFormat:@"%d", seq];
					IObj *obj = [IObj stringObj:s];
					[self prependDataRow:obj forTag:@"item"];
					seq ++;
				}
				[self reload];
				[self endRefresh:self.headerRefreshControl];
			});
		}
		// load more
		if(view == self.footerRefreshControl){
			dispatch_after(0.5, dispatch_get_main_queue(), ^(void){
				[self loadData:5];
				[self reload];
				[self endRefresh:view];
			});
		}
	}
}

- (void)prependData{
}

- (void)onClick:(IView *)view atIndex:(NSUInteger)index{
	log_debug(@"%s %d", __func__, (int)index);
	IObj *obj = view.data;
	obj.strval = @"clicked\nwww\naaa";
	[self updateDataRow:obj forTag:@"item" atIndex:index];
	//[self removeRowAtIndex:index];
	[self reload];
}

@end
