//
//  ITableFixedHeaderDemo.m
//  IKit
/*
 Copyright (c) 2014 ideawu. All rights reserved.
 Use of this source code is governed by a license that can be
 found in the LICENSE file.
 
 @author:  ideawu
 @website: http://www.cocoaui.com/
 */

#import "ITableFixedHeaderDemo.h"

@implementation ITableFixedHeaderDemo

- (id)init{
	self = [super init];
	self.navigationItem.title = @"ITableFixedHeaderDemo";
	self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];

	{
		ITableRow *headerRow = [[ITableRow alloc] initWithNumberOfColumns:4];
		[headerRow.style set:@"height: 30; font-weight: bold; text-align: center; background: #6cf;"];
		[headerRow column:0 setText:@"Id"];
		[headerRow column:1 setText:@"Name"];
		[headerRow column:2 setText:@"Age"];
		[headerRow column:3 setText:@"Opt"];
		self.headerView = headerRow;
	}
	
	[self initHeaderFooter];
	[self loadData:50];
	
	return self;
}

- (void)loadData:(int)count{
	__weak typeof(self) me = self;

	static int seq = 0;
	for(int i=0; i<count; i++, seq++){
		ITableRow *row = [[ITableRow alloc] initWithNumberOfColumns:4];
		[row.style set:@"height: 60; text-align: center; border-bottom: 1 solid #eee; background: #fff;"];
		[row column:0 setText:[NSString stringWithFormat:@"%d", seq+1]];
		[row column:1 setText:[NSString stringWithFormat:@"name-%d", seq+1]];
		[row column:2 setText:[NSString stringWithFormat:@"%d", rand()%50+1]];
		
		IButton *btn = [IButton buttonWithText:@"Delete"];
		[btn.style set:@"float: center; valign: middle; padding: 6 8; color: #fff; background: #f36145; border-radius: 3;"];
		btn.tag = seq;
		[btn bindEvent:IEventClick handler:^(IEventType event, IView *view) {
			[me removeRowContainsUIView:btn animated:YES];
		}];
		[row setView:btn atColumn:3];
		
		[self addIViewRow:row];
	}
}

- (void)initHeaderFooter{
//	if(!self.headerRefreshControl){
//		IRefreshControl *header = [[IRefreshControl alloc] init];
//		[header.style set:@"background: #333;"];
//		self.headerRefreshControl = header;
//	}
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
			// 模拟网络请求
			dispatch_after(0.2, dispatch_get_main_queue(), ^(void){
				[self reload];
				[self endRefresh:view];
			});
		}
		// load more
		if(view == self.footerRefreshControl){
			[self loadData:30];
			[self reload];
			[self endRefresh:view];
		}
	}
}

- (void)onClick:(IView *)view atIndex:(NSUInteger)index{
	log_debug(@"%s %d", __func__, (int)index);
}

@end
