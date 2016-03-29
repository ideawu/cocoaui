/*
 Copyright (c) 2014 ideawu. All rights reserved.
 Use of this source code is governed by a license that can be
 found in the LICENSE file.
 
 @author:  ideawu
 @website: http://www.cocoaui.com/
 */

#import "IButton.h"
#import "IViewInternal.h"
#import "IStyleInternal.h"

@interface IButton (){
	UIButton *_button;
	NSString *_text;
}
@end;

@implementation IButton

+ (IButton *)buttonWithText:(NSString *)text{
	IButton *ret = [[IButton alloc] init];
	[ret setText:text];
	return ret;
}

- (id)init{
	static UIFont *defaultFont = nil;
	if(defaultFont == nil){
		defaultFont = [UIFont systemFontOfSize:([UIFont systemFontSize] + 1)];
	}

	self = [super init];
	[self.style setResizeWidth];
	self.style.tagName = @"button";

	//_btn = [[UIButton alloc] init];
	//_button = [UIButton buttonWithType:UIButtonTypeSystem];
	_button = [UIButton buttonWithType:UIButtonTypeCustom];
	_button.titleLabel.font = defaultFont;

	[self addUIView:_button];
	return self;
}

- (NSString *)text{
	return _text;
}

- (void)setText:(NSString *)text{
	_text = text;
	[_button setTitle:_text forState:UIControlStateNormal];
	[self setNeedsLayout];
}

- (void)drawRect:(CGRect)rect {
	static UIColor *defaultColor = nil;
	static UIColor *defaultHighlightedColor = nil;
	if(defaultColor == nil){
		defaultColor = [UIColor colorWithRed:0 green:0.478431 blue:1 alpha:1];
		defaultHighlightedColor = [UIColor colorWithRed:0 green:0.478431 blue:1 alpha:0.3];
	}
	//log_debug(@"%@ %s", self.name, __func__);
	
	UIColor *color = self.style.inheritedColor;
	if(color){
		CGFloat r, g, b, a;
		[color getRed:&r green:&g blue:&b alpha:&a];
		a *= 0.4;
		UIColor *highlight = [UIColor colorWithRed:r green:g blue:b alpha:a];
		[_button setTitleColor:color forState:UIControlStateNormal];
		[_button setTitleColor:highlight forState:UIControlStateHighlighted];
	}else{
		[_button setTitleColor:defaultColor forState:UIControlStateNormal];
		[_button setTitleColor:defaultHighlightedColor forState:UIControlStateHighlighted];
	}

	[super drawRect:rect];
}

- (void)layout{
	//log_debug(@"%@ %s %@", self.name, __func__, _button.titleLabel.text);
	
	UIFont *font = self.style.inheritedFont;
	if(font){
		_button.titleLabel.font = font;
	}
	[_button sizeToFit]; // iOS 7 必须先进行 button 布局
	_button.titleLabel.text = _text;
	[_button.titleLabel sizeToFit];
	//log_debug(@"%s %@", __func__, NSStringFromCGSize(_button.titleLabel.frame.size));

	// 不用 UIButton 的 frame, 而是 titleLabel 的
	if(self.style.resizeWidth){
		[self.style setInnerWidth:_button.titleLabel.frame.size.width];
	}
	if(self.style.resizeHeight){
		[self.style setInnerHeight:_button.titleLabel.frame.size.height];
	}

	// 先做自定义布局, 再进行父类布局
	[super layout];
}

- (BOOL)fireEvent:(IEventType)event{
	if(!_button.enabled){
		return NO;
	}else{
		return [super fireEvent:event];
	}
}

- (void)onClick{
	[self fireUnhighlightEvent];
	[self fireClickEvent];
}

- (void)addEvent:(IEventType)event handler:(void (^)(IEventType event, IView *view))handler{
	[super addEvent:event handler:handler];
	if(event & IEventClick){
		[_button removeTarget:self action:@selector(onClick) forControlEvents:UIControlEventTouchUpInside];
		[_button addTarget:self action:@selector(onClick) forControlEvents:UIControlEventTouchUpInside];
	}
	if(event & IEventHighlight){
		[_button removeTarget:self action:@selector(fireHighlightEvent) forControlEvents:UIControlEventTouchDown|UIControlEventTouchDragEnter];
		[_button addTarget:self action:@selector(fireHighlightEvent) forControlEvents:UIControlEventTouchDown|UIControlEventTouchDragEnter];
	}
	if(event & IEventUnhighlight){
		[_button removeTarget:self action:@selector(fireUnhighlightEvent) forControlEvents:UIControlEventTouchDragExit];
		[_button addTarget:self action:@selector(fireUnhighlightEvent) forControlEvents:UIControlEventTouchDragExit];
	}
}

@end
