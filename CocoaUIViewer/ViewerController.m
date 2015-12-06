//
//  ViewerController.m
//  CocoaUIViewer
//
//  Created by ideawu on 4/12/15.
//  Copyright (c) 2015 ideawu. All rights reserved.
//

#import "ViewerController.h"
#import "IObj/Http.h"
#import "Config.h"

@interface ViewerController(){
	BOOL loading;
}

@end

@implementation ViewerController

- (void)viewDidLoad {
	[super viewDidLoad];
	self.navigationItem.title = @"CocoaUI 界面预览";
	UIBarButtonItem *refreshBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
																				target:self
																				action:@selector(load)];
	self.navigationItem.rightBarButtonItem = refreshBtn;

	loading = NO;
	[self load];

	Config *conf = [[Config alloc] init];
	int64_t interval = conf.interval;
	if(interval > 0){
		[self performSelector:@selector(autoload) withObject:nil afterDelay:interval];
	}
}

- (void)autoload{
	if(self.parentViewController == nil && self.navigationController == nil){
		return;
	}

	Config *conf = [[Config alloc] init];
	int64_t interval = conf.interval;
	if(interval > 0){
		[self performSelector:@selector(autoload) withObject:nil afterDelay:interval];
	}
	[self load];
}

- (void)load{
	if(loading){
		NSLog(@"loading");
		return;
	}
	//NSLog(@"%s", __func__);
	
	Config *conf = [[Config alloc] init];
	NSString *url = conf.url;
	//NSString *url = @"http://127.0.0.1/cocoaui.xml";
	
	static int num = 0;
	if(num ++ % 100 == 1){
		//NSLog(@"%@ %d", url, (int)conf.interval);
	}

	__weak typeof(self) me = self;

	/*
	IView *view = [IView namedView:@"datasource"];
	[me clear];
	[me addIViewRow:view];
	[me reload];
	return;
	 */
	
	loading = YES;
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
	[IView loadUrl:url callback:^(IView *view) {
		[me clear];
		[me addIViewRow:view];
		[me reload];
		
		loading = NO;
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	}];

}

@end
