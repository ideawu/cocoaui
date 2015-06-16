/*
 Copyright (c) 2014 ideawu. All rights reserved.
 Use of this source code is governed by a license that can be
 found in the LICENSE file.
 
 @author:  ideawu
 @website: http://www.cocoaui.com/
 */

#import "IRefreshControl.h"
#import "ILabel.h"
#import "IStyleInternal.h"
#import "IViewInternal.h"

@interface IRefreshControl(){
	NSString *_maybeText, *_noneText, *_beginText;
	IView *_indicatorView;
	ILabel *_label;
	IView *_indicatorWrapper;
	UIActivityIndicatorView *_indicator;
}

@end

@implementation IRefreshControl

- (id)init{
	self = [super init];
	
	_noneText = @"Pull to refresh...";
	_maybeText = @"Release to refresh";
	_beginText = @"Loading...";
	
	_contentView = [[IView alloc] init];
	_indicatorView = [[IView alloc] init];
	_indicatorWrapper = [[IView alloc] init];
	

	_indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
	_indicator.hidesWhenStopped = NO;
	_indicator.hidden = YES;
	
	[_indicatorWrapper addSubview:_indicator];
	[_indicatorWrapper hide];
	
	_label = [ILabel labelWithText:_noneText];

	[_indicatorView addSubview:_indicatorWrapper style:@"height: 20;"];
	[_indicatorView addSubview:_label style:@"height: 20; margin: 1 5 2 5;"];
	[_contentView addSubview:_indicatorView style:@"float: center;"];
	[self addSubview:_contentView style:@"width: 100%;"];
	[self.style set:@"height: 40; width: 100%; color: #666;"];

	return self;
}

- (void)setStateTextForNone:(NSString *)none maybe:(NSString *)maybe begin:(NSString *)begin{
	_noneText = none;
	_maybeText = maybe;
	_beginText = begin;
	[_label setText:_noneText];
}

- (void)setState:(IRefreshState)state{
	if(state == IRefreshNone){
		[_label setText:_noneText];
		[_indicator stopAnimating];
		_indicator.hidden = YES;
		[_indicatorWrapper hide];
		[_indicatorWrapper.style set:@"width: 1;"];
	}else if(state == IRefreshMaybe){
		[_label setText:_maybeText];
		_indicator.hidden = NO;
		[_indicatorWrapper show];
		[_indicatorWrapper.style set:@"width: 20;"];
	}else if(state == IRefreshBegin){
		[_label setText:_beginText];
		_indicator.hidden = NO;
		[_indicator startAnimating];
		[_indicatorWrapper show];
		[_indicatorWrapper.style set:@"width: 20;"];
	}
}

- (void)layout{
	//_indicator.transform = CGAffineTransformMakeScale(0.9, 0.9);
	[super layout];
	//log_debug(@"%s %@ frame: %@", __func__, self.name, NSStringFromCGRect(self.frame));

	UIColor *color = self.style.inheritedColor;
	if(color){
		_indicator.color = color;
	}
	{
		CGRect frame = _contentView.frame;
		frame.origin.y = (self.style.height - frame.size.height)/2;
		_contentView.frame = frame;
	}
	{
		CGRect frame = _indicatorWrapper.frame;
		frame.origin.y = (_label.style.height - frame.size.height)/2 + 1;
		_indicatorWrapper.frame = frame;
	}
}

@end
