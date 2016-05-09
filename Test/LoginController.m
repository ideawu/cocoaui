/*
 Copyright (c) 2014 ideawu. All rights reserved.
 Use of this source code is governed by a license that can be
 found in the LICENSE file.
 
 @author:  ideawu
 @website: http://www.cocoaui.com/
 */

#import "LoginController.h"

@interface LoginController (){
	IImage *_logo;
	IButton *_submit;
	IView *_captcha_div;
}

@end

@implementation LoginController

- (void)viewDidLoad {
	[super viewDidLoad];
	self.navigationItem.title = @"Login";
	
	IView *view = [IView namedView:@"login"];
	[self addIViewRow:view];
	[self reload];
	
	_logo = (IImage *)[view getViewById:@"logo"];
	_submit = (IButton *)[view getViewById:@"submit"];
	_captcha_div = [view getViewById:@"captcha_div"];
	
	__weak typeof(self) me = self;
	[_submit addEvent:IEventClick handler:^(IEventType type, IView *view) {
		[me submit];
	}];
	// click on the user icon
	[_logo addEvent:IEventClick handler:^(IEventType type, IView *view) {
	}];
}

- (void)submit{
	NSLog(@"%s", __func__);
	[_captcha_div toggle];
}

@end
