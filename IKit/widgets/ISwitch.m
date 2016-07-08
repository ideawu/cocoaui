//
//  ISwitch.m
//  IKit
//
//  Created by ideawu on 7/29/15.
//  Copyright (c) 2015 ideawu. All rights reserved.
//

#import "ISwitch.h"
#import "IViewInternal.h"
#import "IStyleInternal.h"

@implementation ISwitch

- (BOOL)isOn{
	return _uiswitch.isOn;
}

- (void)setOn:(BOOL)on animated:(BOOL)animated{
	[_uiswitch setOn:on animated:animated];
}

- (id)init{
	self = [super init];
	
	self.style.tagName = @"switch";
	//CGRect frame = CGRectMake(0, 0, [IStyle normalFontSize] * 2, [IStyle normalFontSize]);
	//_uiswitch = [[UISwitch alloc] initWithFrame:frame];
	_uiswitch = [[UISwitch alloc] init];
	[self addUIView:_uiswitch];
	
	[_uiswitch addTarget:self action:@selector(onChange:) forControlEvents:UIControlEventValueChanged];
	
	return self;
}

- (void)drawRect:(CGRect)rect{
	[super drawRect:rect];
}

- (void)layout{
	[super layout];
	// UISwitch is not resizable
	[self.style setInnerWidth:_uiswitch.frame.size.width];
	[self.style setInnerHeight:_uiswitch.frame.size.height];
}

- (void)onChange:(id)sender{
	[self fireClickEvent];
}

- (void)addEvent:(IEventType)event handler:(void (^)(IEventType event, IView *view))handler{
	[super addEvent:IEventClick handler:handler];
}

@end
