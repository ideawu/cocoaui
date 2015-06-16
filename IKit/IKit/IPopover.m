/*
 Copyright (c) 2014 ideawu. All rights reserved.
 Use of this source code is governed by a license that can be
 found in the LICENSE file.
 
 @author:  ideawu
 @website: http://www.cocoaui.com/
 */

#import "IPopover.h"

@interface IPopover (){
	IView *_wrapperView;
	IView *_contentView;
}
@end

@implementation IPopover

- (id)init{
	self = [super init];
	_wrapperView = [[IView alloc] init];
	[self addSubview:_wrapperView];
	
	[self.style set:@"width: 100%; height: 100%;"];
	[_wrapperView.style set:@"width: 100%; height: 100%; background: #2000"];

	[self addEvent:IEventClick handler:^(IEventType event, IView *view) {
		[view hide];
	}];

	return self;
}

- (void)show{
	[super show];
	[self setNeedsLayout];
	[self layoutSubviews];
	
	CGRect frame1 = _contentView.frame;
	CGRect frame0 = frame1;
	frame0.origin.y -= frame0.size.height;
	//NSLog(@"frame: %@=>%@", NSStringFromCGRect(frame0), NSStringFromCGRect(frame1));

	_contentView.frame = frame0;
	_wrapperView.layer.opacity = 0;
	[UIView animateWithDuration:0.3 animations:^(){
		_contentView.frame = frame1;
		_wrapperView.layer.opacity = 1;
	} completion:^(BOOL finished) {
		//NSLog(@"%s", __func__);
	}];
}

- (void)hide{
	CGRect frame = _contentView.frame;
	frame.origin.y -= frame.size.height;
	[UIView animateWithDuration:0.3 animations:^(){
		_contentView.frame = frame;
		_wrapperView.layer.opacity = 0;
	} completion:^(BOOL finished) {
		[self setContentView:nil];
		[self removeFromSuperview];
		[super hide];
	}];
}

- (void)setContentView:(IView *)view{
	if(_contentView){
		[_contentView removeFromSuperview];
	}
	if(view){
		[_wrapperView addSubview:view];
	}
	_contentView = view;
}

- (void)my_presentView:(IView *)view onView:(UIView *)containerView{
	[self removeFromSuperview];
	[containerView addSubview:self];
	
	[self setContentView:view];
	[self show];
}

- (void)presentView:(IView *)view onView:(UIView *)containerView{
	[_wrapperView.style set:@"margin-top: 0"];
	[self my_presentView:view onView:containerView];
}

- (void)presentView:(IView *)view onViewController:(UIViewController *)controller{
	if([controller isKindOfClass:[UINavigationController class]]){
		CGRect frame = [(UINavigationController *)controller navigationBar].frame;
		CGFloat offset = frame.origin.y + frame.size.height;
		[_wrapperView.style set:[NSString stringWithFormat:@"margin-top: %f", offset]];
	}
	[self my_presentView:view onView:controller.view];
}

@end
