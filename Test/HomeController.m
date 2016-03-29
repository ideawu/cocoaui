/*
 Copyright (c) 2014 ideawu. All rights reserved.
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

@implementation HomeController

- (void)add_btn:(NSString *)text{
	IButton *btn = [IButton buttonWithText:text];
	[btn.style set:@"margin-bottom: 0; width: 100%; height: 40; background: #fff; border-bottom: 1px solid #ddd;"];
	//[btn.button addTarget:self action:@selector(click:) forControlEvents:UIControlEventTouchUpInside];
	[self addIViewRow:btn];
	
	__weak typeof(self) me = self;
	[btn addEvent:IEventHighlight|IEventUnhighlight|IEventClick handler:^(IEventType event, IView *view) {
		NSLog(@"%d", event);
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
	NSString *css = @"   .a \n{\n    width: 100%; } ";
	IStyleSheet *sheet = [[IStyleSheet alloc] init];
	[sheet parseCss:css baseUrl:nil];
	
	[super viewDidLoad];
	
	self.navigationItem.title = @"Home";
	self.navigationController.navigationBar.translucent = NO;
	self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
	
	/*
	IView *view = [[IView alloc] init];
	[view.style set:@"height: 100; background: #ff3;"];
	IView *sub = [[IView alloc] init];
	[sub.style set:@"width: 100; height: 50; background: #ccf;"];
	[view addSubview:sub];
	[self addIViewRow:view];
	 //[view bindEvent:IEventClick handler:^(IEventType event, IView *view) {
	 //	NSLog(@"%s:%d %@", __func__, __LINE__, view);
	 //}];
	 [sub bindEvent:IEventClick handler:^(IEventType event, IView *view) {
		NSLog(@"%s:%d %@", __func__, __LINE__, view);
	 }];
	*/
	
#if 0
	{
		NSString *xml = @"<html><head><title>404 Not Found</title></head><body bgcolor=\"white\"><center><h1>404 Not Found</h1></center><hr/><center>nginx/1.6.2</center><span>a<a>b</a>c</span></body></html>";
		NSLog(@"start");
		for(int i=0; i<10000; i++){
			IView *view = [IView viewFromXml:xml];
		}
		NSLog(@"end");
	}
#endif
	
#if 0
	{
		NSString *s = @"padding: 2; border: 1 solid #333; margin: 3;";
		IView *view = [[IView alloc] init];
		[view addSubview:[ILabel labelWithText:@"aaabbbaaaa"] style:s];
		[view addSubview:[ILabel labelWithText:@"aaabbbaaa"] style:s];
		[view addSubview:[ILabel labelWithText:@"aaabbbaaa"] style:s];
		[view addSubview:[ILabel labelWithText:@"中国人在的要国为中国人在的要国为中国人在的要国为"] style:s];
		[view addSubview:[ILabel labelWithText:@"aaabbbaaawww"] style:s];
		[self addIViewRow:view];
	}
#endif

#if 0
	{
		NSString *xml = @"<div><div id=\"pan\" style=\"background: url(coupon_ic_up.png); width: 100%; margin: 10; height: 100;\"><span style=\"float: center; valign: middle;\">Drag me</span></div></div>";
		IView *view = [IView viewFromXml:xml];
		IView *pan = [view getViewById:@"pan"];
		[self addIViewRow:view];
		[view addEvent:IEventHighlight|IEventUnhighlight|IEventClick handler:^(IEventType event, IView *view) {
			NSLog(@"%d", event);
			if(event == IEventHighlight){
				[pan setNeedsDisplay];
				[pan.style set:@"padding: 8; background: #ffe url(coupon_ic_down.png)"];
			}
			if(event == IEventUnhighlight){
				[pan.style set:@"padding: 8; background: #0fff url(coupon_ic_up.png)"];
			}
		}];
		return;
	}
#endif
	
	/*
	{
		http_get_raw(@"http://www.cocoaui.com/", nil, ^(NSData *data) {
			NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
			NSLog(@"%@", str);
			IView *view = [IView viewFromXml:str];
			[self addIViewRow:view];
			[self reload];
		});
	}
	*/
	
	[self add_btn:@"Login"];
	[self add_btn:@"ITableFixedHeaderDemo"];
	[self add_btn:@"ITablePullRefreshDemo"];
	[self add_btn:@"ITableClickToRefresh"];
	[self add_btn:@"Test"];
	[self add_btn:@"IPopoverDemo"];
	[self add_btn:@"ITableInUIView"];

	[self addSeparator:@"height: 8;"];
	[self add_btn:@"Detect memory leak"];
	
	[self addSeparator:@"height: 8;"];
	
	// 测试内存泄露
	//[self autoload];
}

- (void)autoload{
	[self performSelector:@selector(autoload) withObject:nil afterDelay:0.1];
	[self load];
}

- (void)load{
	IView *view = [IView new];
	for(int i=0; i<1000; i++){
		ILabel *label = [ILabel labelWithText:@"aaaaaaa"];
		[view addSubview:label style:@"background: #f33;"];
	}
}

- (void)onClick:(IView *)view atIndex:(NSUInteger)index{
	NSLog(@"%s:%d %d:%@", __func__, __LINE__, (int)index, view);
}

- (void)click:(UIButton *)btn{
	NSString *text = btn.titleLabel.text;
	NSLog(@"click %@", text);
	UIViewController *controller;
	if([text isEqualToString:@"Login"]){
		controller = [[LoginController alloc] init];
	}
	if([text isEqualToString:@"ITableFixedHeaderDemo"]){
		controller = [[ITableFixedHeaderDemo alloc] init];
	}
	if([text isEqualToString:@"ITablePullRefreshDemo"]){
		controller = [[ITablePullRefreshDemo alloc] init];
	}
	if([text isEqualToString:@"ITableClickToRefresh"]){
		controller = [[ITableClickToRefresh alloc] init];
	}
	if([text isEqualToString:@"Test"]){
		controller = [[TestController alloc] init];
	}
	if([text isEqualToString:@"IPopoverDemo"]){
		controller = [[IPopoverDemo alloc] init];
	}
	if([text isEqualToString:@"ITableInUIView"]){
		controller = [[ITableInUIView alloc] init];
	}
	if([text isEqualToString:@"Detect memory leak"]){
		NSString *xml = @"<html><head><title>404 Not Found</title></head><body bgcolor=\"white\"><center><h1>404 Not Found</h1></center><hr/><center>nginx/1.6.2</center><span>a<a>b</a>c</span></body></html>";
		NSLog(@"start");
		IView *parent = [[IView alloc] init];
		for(int i=0; i<1000; i++){
			IView *view = [IView viewFromXml:xml];
			[parent addSubview:view];
		}
		parent = nil;
		NSLog(@"end");
		return;
	}
	[self.navigationController pushViewController:controller animated:YES];
}

@end
