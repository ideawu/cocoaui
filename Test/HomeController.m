/*
 Copyright (c) 2014-2017 ideawu. All rights reserved.
 Use of this source code is governed by a license that can be
 found in the LICENSE file.
 
 @author:  ideawu
 @website: http://www.cocoaui.com/
 */

#import "HomeController.h"
#import "LoginController.h"
#import "ITableFixedHeaderDemo.h"
#import "ITablePullRefreshDemo.h"
#import "ITableClickToRefresh.h"
#import "IPopoverDemo.h"
#import "TestController.h"
#import "IStyleSheet.h"
#import "Http.h"
#import "ITableInUIView.h"
#import "ISelectDemo.h"
#import "ITableNestedDemo.h"

@interface HomeController(){
	NSArray *_config;
}
@end

@implementation HomeController

- (void)add_btn:(NSString *)text{
	IButton *btn = [IButton buttonWithText:text];
	[btn.style set:@"margin-bottom: 0; width: 100%; height: 40; background: #fff; border-bottom: 1px solid #ddd;"];
	//[btn.button addTarget:self action:@selector(click:) forControlEvents:UIControlEventTouchUpInside];
	[self addIViewRow:btn];
	
	__weak typeof(self) me = self;
	[btn addEvent:IEventHighlight|IEventUnhighlight|IEventClick handler:^(IEventType event, IView *view) {
		log_debug(@"%d", event);
		if(event == IEventHighlight){
			[view.style set:@"background: #ffe;"];
			//[view.style set:@"padding: 8; background: #ffe url(ic_down.png)"];
		}
		if(event == IEventUnhighlight){
			[view.style set:@"background: #fff;"];
			//[view.style set:@"padding: 8; background: #0fff url(ic_up.png)"];
		}
		if(event == IEventClick){
			IButton *ib = (IButton *)view;
			[me click:ib.button];
		}
	}];
}

- (void)viewDidLoad {
	[super viewDidLoad];
	self.navigationItem.title = @"Home";
	self.navigationController.navigationBar.translucent = NO;
	self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
	
	_config = @[
				@[@"Login Page", [LoginController class]],
				@[@"ITable with Fixed Header", [ITableFixedHeaderDemo class]],
				@[@"ITable Pull to Refresh", [ITablePullRefreshDemo class]],
				@[@"ITable Click to Refresh", [ITableClickToRefresh class]],
				@[@"ITable in UIView", [ITableInUIView class]],
				@[@"Nested ITable", [ITableNestedDemo class]],
				@[@"divider", @"height: 18;"],
				@[@"Popover", [IPopoverDemo class]],
				@[@"Select/Dropdown Menu", [ISelectDemo class]],
				@[@"divider", @"height: 18;"],
				@[@"Detect memory leak", [ISelectDemo class]],
				];
	
	for(NSArray *item in _config){
		NSString *key = item[0];
		if([key isEqualToString:@"divider"]){
			NSString *val = [item[1] description];
			[self addSeparator:val];
		}else{
			[self add_btn:key];
		}
	}
}

- (void)onClick:(IView *)view atIndex:(NSUInteger)index{
	log_debug(@"%s:%d %d:%@", __func__, __LINE__, (int)index, view);
}

- (void)click:(UIButton *)btn{
	NSString *text = btn.titleLabel.text;
	log_debug(@"click %@", text);
	
	UIViewController *controller;
	for(NSArray *item in _config){
		NSString *key = item[0];
		if([key isEqualToString:text]){
			Class clz = item[1];
			controller = [[clz alloc] init];
			break;
		}
	}

	if([text isEqualToString:@"Detect memory leak"]){
		NSString *xml = @"<html><head><title>404 Not Found</title></head><body bgcolor=\"white\"><center><h1>404 Not Found</h1></center><hr/><center>nginx/1.6.2</center><span>a<a>b</a>c</span></body></html>";
		log_debug(@"start");
		IView *parent = [[IView alloc] init];
		for(int i=0; i<1000; i++){
			IView *view = [IView viewFromXml:xml];
			[parent addSubview:view];
		}
		parent = nil;
		log_debug(@"end");
		return;
	}
	[self.navigationController pushViewController:controller animated:YES];
}

@end
