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
#import "IStyleSheet.h"
#import "Http.h"

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
		}
		if(event == IEventUnhighlight){
			[view.style set:@"background: #fff;"];
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
	[sheet parseCss:css];
	
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
	
	{
		/*
		NSString *xml = @"<html><head><title>404 Not Found</title></head><body bgcolor=\"white\"><center><h1>404 Not Found</h1></center><hr/><center>nginx/1.6.2</center><span>a<a>b</a>c</span></body></html>";
		NSLog(@"start");
		for(int i=0; i<10000; i++){
			IView *view = [IView viewFromXml:xml];
		}
		NSLog(@"end");
		 */
		//[self addIViewRow:view];
		//[self reload];
	}
	if(1){
		[IView loadUrl:@"http://127.0.0.1/a.xml" callback:^(IView *view) {
			NSLog(@"reload");
			[self addIViewRow:view];
			[self reload];
		}];
		
		//IView *view = [IView namedView:@"register.html"];
		//[self addIViewRow:view];
	}
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
	[self add_btn:@"IPopoverDemo"];
	
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

- (void)onClick:(IView *)view{
	NSLog(@"%s:%d %@", __func__, __LINE__, view);
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
	if([text isEqualToString:@"IPopoverDemo"]){
		controller = [[IPopoverDemo alloc] init];
	}
	[self.navigationController pushViewController:controller animated:YES];
}

@end
