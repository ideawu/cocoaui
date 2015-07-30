//
//  DataSourceController.m
//  CocoaUIViewer
//
//  Created by ideawu on 4/12/15.
//  Copyright (c) 2015 ideawu. All rights reserved.
//

#import "DataSourceController.h"
#import "ViewerController.h"
#import "Config.h"

@interface DataSourceController (){
	IButton *_submit;
	IInput *_url;
	IInput *_interval;
}

@end

@implementation DataSourceController

- (void)viewDidLoad {
    [super viewDidLoad];
	self.navigationItem.title = @"设置";

	IView *view = [IView namedView:@"datasource"];
	[self addIViewRow:view];
	[self reload];

	_url = (IInput *)[view getViewById:@"url"];
	_interval = (IInput *)[view getViewById:@"interval"];
	_submit = (IButton *)[view getViewById:@"submit"];
	
	Config *conf = [[Config alloc] init];
	_url.value = conf.url;
	_interval.value = [NSString stringWithFormat:@"%d", (int)conf.interval];
	
	//_interval.textField.textAlignment = NSTextAlignmentCenter;
	
	__weak typeof(self) me = self;
	[_submit addEvent:IEventClick handler:^(IEventType type, IView *view) {
		[me submit];
	}];
}

- (void)submit{
	NSString *url = _url.value;
	int64_t interval = _interval.value.intValue;
	
	Config *conf = [[Config alloc] init];
	conf.url = url;
	conf.interval = interval;
	[conf save];

	[self.navigationController pushViewController:[[ViewerController alloc] init] animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
