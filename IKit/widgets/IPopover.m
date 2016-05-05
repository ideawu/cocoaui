/*
 Copyright (c) 2014 ideawu. All rights reserved.
 Use of this source code is governed by a license that can be
 found in the LICENSE file.
 
 @author:  ideawu
 @website: http://www.cocoaui.com/
 */

#import "IPopover.h"
#import "IStyleInternal.h"

@interface IPopover (){
	IView *_wrapperView;
	UIView *_contentView;
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
	[self layout];
	
	CGRect frame1 = _contentView.frame;
	CGRect frame0 = frame1;
	frame0.origin.y -= frame0.size.height;
	log_debug(@"frame: %@=>%@", NSStringFromCGRect(frame0), NSStringFromCGRect(frame1));

	_contentView.frame = frame0;
	self.layer.opacity = 0;
	[UIView animateWithDuration:0.3 animations:^(){
		_contentView.frame = frame1;
		self.layer.opacity = 1;
	} completion:^(BOOL finished) {
		//log_debug(@"%f", _contentView.frame.size.width);
	}];
}

- (void)hide{
	CGRect frame = _contentView.frame;
	frame.origin.y -= frame.size.height;
	[UIView animateWithDuration:0.3 animations:^(){
		_contentView.frame = frame;
		self.layer.opacity = 0;
	} completion:^(BOOL finished) {
		[self setContentView:nil];
		[self removeFromSuperview];
		[super hide];
	}];
}

- (void)setContentView:(UIView *)view{
	if(_contentView){
		[_contentView removeFromSuperview];
	}
	_contentView = view;
	[_wrapperView addSubview:_contentView];
}

- (void)my_presentView:(UIView *)view onView:(UIView *)containerView{
	[self removeFromSuperview];
	[containerView addSubview:self];
	
	self.frame = containerView.bounds;
	[self setContentView:view];
	[self show];
}

- (void)presentView:(UIView *)view onView:(UIView *)containerView{
	[self my_presentView:view onView:containerView];
}

- (void)presentView:(UIView *)view onViewController:(UIViewController *)controller{
	if([controller isKindOfClass:[UINavigationController class]]){
		CGRect frame = [(UINavigationController *)controller navigationBar].frame;
		CGFloat offset = frame.origin.y + frame.size.height;
		[_wrapperView.style set:[NSString stringWithFormat:@"margin-top: %f", offset]];
	}
	[self my_presentView:view onView:controller.view];
}

@end
