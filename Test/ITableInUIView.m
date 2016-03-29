//
//  ITableInUIView.m
//  IKit
//
//  Created by ideawu on 3/29/16.
//  Copyright © 2016 ideawu. All rights reserved.
//

#import "ITableInUIView.h"
#import "ITablePullRefreshItem.h"
#import "IObj.h"

@interface ITableInUIView ()<ITableDelegate>{
	ITable *_table;
}
@end

@implementation ITableInUIView

- (void)viewDidLoad {
    [super viewDidLoad];
	self.navigationItem.title = @"ITablePullRefreshDemo";
	self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];

	_table = [[ITable alloc] init];
	_table.delegate = self;
	[self initHeaderFooter];
	[_table registerViewClass:[ITablePullRefreshItem class] forTag:@"item"];
	
	_table.view.layer.borderColor = [UIColor blueColor].CGColor;
	_table.view.layer.borderWidth = 1;
	
	CGFloat w = [UIScreen mainScreen].bounds.size.width * 0.7;
	CGFloat h = [UIScreen mainScreen].bounds.size.height * 0.6;
	CGFloat x = ([UIScreen mainScreen].bounds.size.width - w) / 2;
	CGFloat y = ([UIScreen mainScreen].bounds.size.height - h) / 3;
	_table.view.frame = CGRectMake(x, y, w, h);
	[self.view addSubview:_table.view];
	
	[self loadData:1];
	[_table reload];
}


/**
 * Must call ITable.endRefresh() when state is IRefreshBegin
 */
- (void)table:(ITable *)table onRefresh:(IRefreshControl *)view state:(IRefreshState)state{
	if(state == IRefreshBegin){
		// refresh
		if(view == _table.headerRefreshControl){
			// 模拟网络请求
			dispatch_after(0.2, dispatch_get_main_queue(), ^(void){
				static int seq = 1000;
				for(int i=0; i<5; i++){
					NSString *s = [NSString stringWithFormat:@"%d", seq];
					IObj *obj = [IObj stringObj:s];
					[_table prependDataRow:obj forTag:@"item"];
					seq ++;
				}
				[_table reload];
				[_table endRefresh:view];
			});
		}
		// load more
		if(view == _table.footerRefreshControl){
			[self loadData:5];
			[_table reload];
			[_table endRefresh:view];
		}
	}
}


- (void)loadData:(int)count{
	static int seq = 0;
	for(int i=0; i<count; i++){
		NSString *s = [NSString stringWithFormat:@"%d", seq];
		IObj *obj = [IObj stringObj:s];
		[_table addDataRow:obj forTag:@"item"];
		seq ++;
	}
}

- (void)initHeaderFooter{
	if(!_table.headerRefreshControl){
		IRefreshControl *header = [[IRefreshControl alloc] init];
		[header.style set:@"background: #333;"];
		_table.headerRefreshControl = header;
	}
	if(!_table.footerRefreshControl){
		IRefreshControl *footer = [[IRefreshControl alloc] init];
		[footer setStateTextForNone:@"Pull up to load more"
							  maybe:@"Release to load more"
							  begin:@"loading..."];
		[footer.style set:@"top: -40;"];
		_table.footerRefreshControl = footer;
	}
}

@end
