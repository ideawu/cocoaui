/*
 Copyright (c) 2014 ideawu. All rights reserved.
 Use of this source code is governed by a license that can be
 found in the LICENSE file.
 
 @author:  ideawu
 @website: http://www.cocoaui.com/
 */

#import "ITablePullRefreshDemo.h"

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
	[self initHeaderFooter];

	self.pullRefresh.footerVisibleRateToRefresh = -6;

	[self loadData:20];
	
	return self;
}

- (void)loadData:(int)count{
	static int seq = 0;
	for(int i=0; i<count; i++){
		ITableRow *row = [[ITableRow alloc] initWithNumberOfColumns:3];
		[row.style set:@"height: 50; padding-top: 10; text-align: center; border-bottom: 1 solid #eee; background: #fff;"];
		[row column:0 setText:[NSString stringWithFormat:@"%d", seq]];
		[row column:1 setText:[NSString stringWithFormat:@"name-%d", seq]];
		[row column:2 setText:[NSString stringWithFormat:@"%d", rand()%50+1]];
		[self addIViewRow:row];
		seq ++;
	}
}

- (void)initHeaderFooter{
	if(!self.headerRefreshControl){
		IRefreshControl *header = [[IRefreshControl alloc] init];
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
			[self clear];
			[self loadData:20];
		}
		// load more
		if(view == self.footerRefreshControl){
			[self loadData:33];
		}
		[self reload];
		[self endRefresh:view];
	}
}

@end
