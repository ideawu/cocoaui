//
//  ITablePullRefreshItem.m
//  IKit
//
//  Created by ideawu on 3/29/16.
//  Copyright © 2016 ideawu. All rights reserved.
//

#import "ITablePullRefreshItem.h"
#import "IObj.h"

@implementation ITablePullRefreshItem
- (id)init{
	self = [super init];
	IView *view = [IView namedView:@"ITablePullRefreshItem"];
	[self addSubview:view];
	
	_num = (ILabel *)[view getViewById:@"seq"];
	_btn_1 = (IButton *)[view getViewById:@"btn_1"];
	_btn_2 = (IButton *)[view getViewById:@"btn_2"];
	_btn_3 = (IButton *)[view getViewById:@"btn_3"];
	_btn_4 = (IButton *)[view getViewById:@"btn_4"];
	_div = (IView *)[view getViewById:@"div"];
	
	__weak typeof(self) me = self;
	[_btn_1 addEvent:IEventClick handler:^(IEventType event, IView *view) {
		NSString *s = me.num.text;
		if(s.length > 2){
			s = [s substringToIndex:s.length - 2];
			me.num.text = s;
			
			IObj *obj = (IObj *)me.data;
			obj.strval = s;
		}
	}];
	[_btn_2 addEvent:IEventClick handler:^(IEventType event, IView *view) {
		NSString *s = me.num.text;
		s = [s stringByAppendingFormat:@"\na"];
		me.num.text = s;
		
		IObj *obj = (IObj *)me.data;
		obj.strval = s;
	}];
	
	IView *div2 = (IView *)[view getViewById:@"div2"];
	
	[_btn_3 addEvent:IEventClick handler:^(IEventType event, IView *view) {
		me.div.style.width -= 20;
//		[me.div.style set:[NSString stringWithFormat:@"width: %f", me.div.style.width - 20]];
		[div2.style removeClass:@"a"];
	}];
	[_btn_4 addEvent:IEventClick handler:^(IEventType event, IView *view) {
		me.div.style.width += 20;
//		[me.div.style set:[NSString stringWithFormat:@"width: %f", me.div.style.width + 20]];
		[div2.style addClass:@"a"];
	}];
	
	
	NSArray *arr = @[@"x", @"y", @"z"];
	for(NSString *s in arr){
		ILabel *label = [ILabel labelWithText:s];
		[label.style addClass:s];
		[div2 addSubview:label];
	}
	
	return self;
}

- (void)setData:(id)data{
	[super setData:data];
	IObj *obj = (IObj *)self.data;
	_num.text = obj.strval;
}

@end


////////////////////////////////////////////////
