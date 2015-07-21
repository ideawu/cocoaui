/*
 Copyright (c) 2014 ideawu. All rights reserved.
 Use of this source code is governed by a license that can be
 found in the LICENSE file.
 
 @author:  ideawu
 @website: http://www.cocoaui.com/
 */

#import "ITableClickToRefresh.h"

@interface ITableClickToRefresh ()

@end

@implementation ITableClickToRefresh

- (id)init{
	self = [super init];
	self.navigationItem.title = @"ITableClickToRefresh";
	self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
	
	{
		IView *view = [[IView alloc] init];
		[view.style set:@"height: 1200; background: #fff; margin: 4 10;"];
		[self addIViewRow:view];

		{
			ITableRow *headerRow = [[ITableRow alloc] initWithNumberOfColumns:3];
			[headerRow.style set:@"height: 30; font-weight: bold; text-align: center; background: #6cf;"];
			[headerRow column:0 setText:@"Id"];
			[headerRow column:1 setText:@"Name"];
			[headerRow column:2 setText:@"Age"];
			self.headerView = headerRow;
		}
		
		{
			IButton *btn = [IButton buttonWithText:@"Click to Refresh(Header)"];
			[view addSubview:btn style:@"float: center; margin-top: 100; padding: 5 8; color: #fff; background: #f36145"];
			
			__weak typeof(self) me = self;
			[btn bindEvent:IEventClick handler:^(IEventType event, IView *view) {
				[me.pullRefresh beginHeaderRefresh];
			}];
		}
		
		{
			IButton *btn = [IButton buttonWithText:@"Click to Refresh(Footer)"];
			[view addSubview:btn style:@"float: center; margin-top: 100; padding: 5 8; color: #fff; background: #f36145"];
			
			__weak typeof(self) me = self;
			[btn bindEvent:IEventClick handler:^(IEventType event, IView *view) {
				[me.pullRefresh beginFooterRefresh];
			}];
		}
	}

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

	return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)onRefresh:(IRefreshControl *)view state:(IRefreshState)state{
	NSString *n = view == self.headerRefreshControl? @"header" : @"footer";
	NSLog(@"%@ %d", n, (int)state);
	if(state == IRefreshBegin){
		// refresh
		[self performSelector:@selector(afterReloadData:) withObject:view afterDelay:2.0];
		return;
	}
	[super onRefresh:view state:state];
}

- (void)afterReloadData:(IRefreshControl *)view{
	[self endRefresh:view];
}

@end
